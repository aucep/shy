import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:scroll_app_bar/scroll_app_bar.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
//code-splitting
import '../appDrawer.dart';
import '../util/pageData.dart';
import '../auth.dart';

//fimfiction.net/story/[storyID]/[chapterNum]
class ChapterScreenArgs {
  final String storyID;
  final String chapterNum;

  ChapterScreenArgs(this.storyID, this.chapterNum);
}

class ChapterScreen extends HookWidget {
  final ChapterScreenArgs args;
  ChapterScreen(this.args);

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();
    final auth = useProvider(authProvider);
    var chapterNum = useState(args.chapterNum);

    var page = useState(PageData<Chapter>());
    final body = page.value?.body;
    refresh() async {
      Document doc;
      if (kIsWeb) {
        doc = parse(await rootBundle.loadString("saved_html/chapter.html"));
      } else {
        doc = await fetchDoc("story/${args.storyID}/$chapterNum/");
      }

      page.value = Chapter.page(doc);
    }

    useEffect(() {
      refresh();
      return null;
    }, [auth, chapterNum]);

    return Scaffold(
      appBar: ScrollAppBar(
        controller: controller,
        titleSpacing: 0,
        title: CheatTitle("loading story/${args.chapterNum}/${args.storyID}/"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: body == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refresh, child: Paragraphs(html: body.paragraphs, controller: controller)),
      drawer: AppDrawer(data: page.value.drawer),
      endDrawer: Drawer(
          child: ListView(
        children: [DrawerHeader(child: Center(child: Text("right drawer")))],
      )),
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

class ChapterStory {
  final String title,
      description, //could be html! hopefully not
      authorName,
      authorId;
  final List<String> chapterTitles;
  final String storyId;

  ChapterStory(
      {this.title,
      this.authorName,
      this.authorId,
      this.description,
      this.chapterTitles,
      this.storyId});

  static ChapterStory fromChapter(Document doc) {
    final infoContainer = doc.querySelector(".info-container");
    final storyLink = infoContainer.querySelector("div > h1 > a");
    final authorLink = infoContainer.querySelector(".author > a");
    final description = infoContainer.querySelector("div > div > p");
    final chapters =
        doc.querySelector(".chapter-selector ul").children.where((t) => t != null).toList();
    return ChapterStory(
        title: storyLink.innerHtml,
        storyId: storyLink.attributes["href"].split("/")[2],
        authorName: authorLink.innerHtml,
        authorId: authorLink.attributes["href"].split("/")[2],
        description: description.innerHtml,
        chapterTitles:
            chapters.map((t) => t.querySelector(".chapter-selector__title").innerHtml).toList());
  }
}

class Chapter {
  final ChapterStory story; //in right drawer
  final String title, note;
  final bool notePosition;
  final List<String> paragraphs;

  Chapter({this.story, this.title, this.note, this.notePosition, this.paragraphs});

  static Chapter fromChapter(Document doc) {
    final title = doc.querySelector("#chapter_title");
    final authorsNote = doc.querySelector('.authors-note');
    final notePosition = authorsNote?.attributes["style"].startsWith("margin-top");
    final body = doc.querySelector("#chapter-body > div");
    final paragraphs = body.children.map((p) => p.outerHtml).toList();
    return Chapter(
      story: ChapterStory.fromChapter(doc),
      title: title.innerHtml,
      note: authorsNote?.innerHtml ?? "",
      notePosition: notePosition,
      paragraphs: paragraphs,
    );
  }

  static PageData<Chapter> page(Document doc) {
    return PageData<Chapter>(drawer: AppDrawerData.fromDoc(doc), body: Chapter.fromChapter(doc));
  }
}
