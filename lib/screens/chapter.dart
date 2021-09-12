import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

//code-splitting
import '../appDrawer.dart';
import '../models/pageData.dart';
import '../models/chapter.dart';
import '../models/story.dart';
import '../util/nav.dart';
import '../util/fimHttp.dart';
import '../widgets/cheatTitle.dart';
import 'story.dart';

///fimfiction.net/story/:storyId/:chapterNum/
class ChapterArgs extends Equatable {
  final String storyId;
  final int chapterNum;

  ChapterArgs({this.storyId, this.chapterNum});

  @override
  List<Object> get props => [storyId, chapterNum];
}

class ChapterScreen extends HookWidget {
  final ChapterArgs args;
  ChapterScreen(this.args);

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    var chapterNum = useState(args.chapterNum);

    var loading = useState(false);
    var page = useState(PageData<ChapterData>());
    final body = page.value?.body;
    refresh() async {
      loading.value = true;
      final start = DateTime.now();
      final doc = await fetchDoc('story/${args.storyId}/${chapterNum.value}/');
      var elapsed = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      print('doc after $elapsed ms');
      page.value = ChapterData.page(doc);
      elapsed = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      print('parsed after $elapsed ms');
      loading.value = false;
    }

    useEffect(() {
      refresh();
      return null;
    }, [chapterNum.value]);

    return SafeArea(
      child: Scaffold(
        appBar: ScrollAppBar(
          controller: controller,
          titleSpacing: 0,
          title: CheatTitle(body?.title ?? 'story/${args.storyId}/${chapterNum.value}/'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: loading.value == true || body == null
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: refresh,
                child: Paragraphs(
                  html: body.body,
                  controller: controller,
                ),
              ),
        drawer: AppDrawer(data: page.value?.drawer, refresh: refresh),
        endDrawer: body != null
            ? ChapterDrawer(story: body.story, chapterNum: chapterNum, chapterTitle: body.title)
            : Drawer(),
      ),
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
        padding: Pad(all: 16),
        //i moved the padding inside because it looks better
        controller: controller,
        children: html
            .map(
              (p) => Padding(
                padding: Pad(vertical: 8),
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
  final StoryData story;
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
