import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

//code-splitting
import '../appDrawer.dart';
import '../models/pageData.dart';
import '../models/chapter.dart';
import '../models/story.dart';
import 'story.dart';
import '../util/nav.dart';
import '../util/fimHttp.dart';
import '../widgets/cheatTitle.dart';

//fimfiction.net/story/[storyID]/[chapterNum]/
class ChapterScreenArgs extends Equatable {
  final String storyId;
  final int chapterNum;

  ChapterScreenArgs({this.storyId, this.chapterNum});

  @override
  List<Object> get props => [storyId, chapterNum];
}

class ChapterScreen extends HookWidget {
  final ChapterScreenArgs args;
  ChapterScreen(this.args);

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    var chapterNum = useState(args.chapterNum);
    var page = useState(Page<Chapter>());
    var loading = useState(false);

    final body = page.value?.body;
    refresh() async {
      loading.value = true;
      Document doc;
      if (kIsWeb) {
        doc = parse(await rootBundle.loadString('saved_html/chapter.html'));
      } else {
        doc = await fetchDoc('story/${args.storyId}/${chapterNum.value}/');
      }

      page.value = Chapter.page(doc);
      loading.value = false;
    }

    useEffect(() {
      refresh();
      return null;
    }, [chapterNum.value]);

    return Scaffold(
      appBar: ScrollAppBar(
        controller: controller,
        titleSpacing: 0,
        title: CheatTitle('story/${args.storyId}/${chapterNum.value}/'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: loading.value == true || body == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refresh,
              child: Paragraphs(
                html: body.paragraphs,
                controller: controller,
              ),
            ),
      drawer: AppDrawer(data: page.value?.drawer, refresh: refresh),
      endDrawer: body != null
          ? ChapterDrawer(story: body.story, chapterNum: chapterNum, chapterTitle: body.title)
          : Drawer(),
    );
  }
}

class Paragraphs extends StatelessWidget {
  final List<String> html;
  final ScrollController controller;
  Paragraphs({this.html, this.controller});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        //i moved the padding inside because it looks better
        controller: controller,
        children: html
            .map(
              (p) => Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: HtmlWidget(
                  p,
                  textStyle: TextStyle(height: 1.8),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class ChapterDrawer extends HookWidget {
  final Story story;
  final ValueNotifier<int> chapterNum;
  final String chapterTitle;
  ChapterDrawer({this.story, this.chapterNum, this.chapterTitle});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(children: [
        DrawerHeader(
          child: ListView(children: [
            TextButton(
              child: Text(
                story.title,
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
              onPressed: () =>
                  Navigator.of(context).pushNamedIfNew('/story', args: StoryArgs(story.id)),
            ),
            Text(story.description),
          ]),
        ),
        Center(
          child: Text(
            chapterTitle,
            style: TextStyle(
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        story.chapters.length > 0
            ? ButtonBar(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: chapterNum.value == 1 ? null : () => chapterNum.value--,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed:
                      chapterNum.value == story.chapters.length ? null : () => chapterNum.value++,
                )
              ])
            : Container(),
      ]),
    );
  }
}
