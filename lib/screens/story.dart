import 'package:badges/badges.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:equatable/equatable.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
//code-splitting
import '../appDrawer.dart';
import '../util/pageData.dart';
import 'home.dart';

class StoryArgs extends Equatable {
  final int id;
  const StoryArgs(this.id);

  @override
  List<Object> get props => [id];
}

class StoryScreen extends HookWidget {
  final StoryArgs args;
  const StoryScreen(this.args);

  @override
  Widget build(BuildContext context) {
    var page = useState(PageData<Story>());
    final body = page.value?.body;

    refresh() async {
      Document doc;
      final start = DateTime.now();
      if (kIsWeb) {
        doc = parse(await rootBundle.loadString('saved_html/story.html'));
      } else {
        doc = await fetchDoc('story/${args.id}');
      }
      var elapsed = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      print('doc after $elapsed ms');
      page.value = Story.page(doc);
      elapsed = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      print('parsed after $elapsed ms');
    }

    useEffect(() {
      refresh();
      return;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: Text('story'),
      ),
      body: body == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refresh,
              child: Scrollbar(
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(8),
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        ContentRating(body.contentRating),
                        Container(width: 5),
                        Text(
                          body.title,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                      ],
                    ),
                    Divider(),
                    StoryTags(
                      series: body.seriesTags,
                      warning: body.warningTags,
                      genre: body.genreTags,
                      content: body.contentTags,
                      character: body.characterTags,
                    ),
                    Divider(),
                    if (body?.imageUrl != null)
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 200, maxWidth: 200),
                        child: IntrinsicWidth(
                          child: Card(child: IntrinsicWidth(child: ExpandableImage(body.imageUrl))),
                        ),
                      ),
                    Card(
                        child: Padding(
                      padding: EdgeInsets.all(8),
                      child: HtmlWidget(body.description),
                    )),
                  ],
                ),
              ),
            ),
      drawer: AppDrawer(data: page.value.drawer, refresh: refresh),
    );
  }
}

class Story {
  final String title, description, imageUrl, contentRating;
  final List<String> seriesTags, warningTags, genreTags, contentTags, characterTags;
  final List<String> chapterNames;
  final String completedStatus, approvedDate, totalWordcount, viewInfo, likes, dislikes;

  const Story(
      {this.likes,
      this.dislikes,
      this.viewInfo,
      this.seriesTags,
      this.genreTags,
      this.warningTags,
      this.characterTags,
      this.contentTags,
      this.chapterNames,
      this.completedStatus,
      this.approvedDate,
      this.totalWordcount,
      this.title,
      this.description,
      this.imageUrl,
      this.contentRating});

  static Story fromStory(Document doc) {
    final story = doc.querySelector('.story_container');

    //top
    final title = story.querySelector('.story_name');
    final description = story.querySelector('.description-text');
    final image = story.querySelector('.story_container__story_image > img');
    final contentRating = story.querySelector('.title > a');

    //info
    final ratings = story.querySelector('.rating_container');
    final viewInfo = ratings.children[6];
    final likes = ratings.querySelector('.likes');
    final dislikes = ratings.querySelector('.dislikes');

    final footer = story.querySelector('.chapters-footer');
    final completedStatus = footer.children[1];
    final approvedDate = footer.children[2].children.last;
    final wordcount = footer.children.last.children.first;

    //tags
    final tags = story.querySelector('.story-tags');
    final seriesTags = tags.querySelectorAll('.tag-series');
    final warningTags = tags.querySelectorAll('.tag-warning');
    final genreTags = tags.querySelectorAll('.tag-genre');
    final contentTags = tags.querySelectorAll('.tag-content');
    final characterTags = tags.querySelectorAll('.tag-character');

    //chapter
    final chapters = story.querySelector('.chapters');

    return Story(
      title: title.innerHtml,
      description: description.innerHtml,
      imageUrl: image.attributes['data-src'],
      contentRating: contentRating.innerHtml,
      viewInfo: viewInfo.attributes['title'],
      likes: likes.innerHtml,
      dislikes: dislikes.innerHtml,
      completedStatus: completedStatus.innerHtml,
      approvedDate: approvedDate.innerHtml,
      totalWordcount: wordcount.innerHtml,
      seriesTags: seriesTags.map((t) => t.innerHtml).toList(),
      warningTags: warningTags.map((t) => t.innerHtml).toList(),
      genreTags: genreTags.map((t) => t.innerHtml).toList(),
      contentTags: contentTags.map((t) => t.innerHtml).toList(),
      characterTags: characterTags.map((t) => t.innerHtml).toList(),
      chapterNames: chapters.children
          .map((c) => c
              .children[0] //div
              .children[1] //div.title-box
              .children[0] //a.chapter-title
              .innerHtml)
          .toList(),
    );
  }

  static PageData<Story> page(Document doc) {
    return PageData<Story>(drawer: AppDrawerData.fromDoc(doc), body: Story.fromStory(doc));
  }
}

class StoryTags extends StatelessWidget {
  final List<String> series, warning, genre, content, character;

  const StoryTags({this.series, this.warning, this.genre, this.content, this.character});

  @override
  Widget build(BuildContext context) {
    List<Badge> tags = [];
    Map<String, int> genreColors = {
      'Adventure': 0x6fb859,
      'Comedy': 0xf59c00,
      'Dark': 0xb93737,
      'Horror': 0xb93737,
      'Romance': 0xcd58a7,
    };
    dynamic color; //series color
    Badge toBadge(String tag) {
      final badgeColor = Color(
        0xff000000 +
            (color == 'genre'
                ? genreColors.containsKey(tag)
                    ? genreColors[tag]
                    : 0x4f91d6 //default genre tag color
                : color),
      );
      print(badgeColor);
      return Badge(
        toAnimate: false,
        badgeContent: Text(tag, style: TextStyle(color: Colors.white)),
        shape: BadgeShape.square,
        badgeColor: badgeColor,
        padding: EdgeInsets.all(4),
      );
    }

    color = 0xb159d0;
    tags.addAll(series.map(toBadge));
    color = 0xeb6a63;
    tags.addAll(warning.map(toBadge));
    color = 'genre';
    tags.addAll(genre.map(toBadge));
    color = 0x4b4b4b;
    tags.addAll(content.map(toBadge));
    color = 0x27cc80;
    tags.addAll(character.map(toBadge));

    return WrapSuper(
      children: tags,
      alignment: WrapSuperAlignment.center,
      spacing: 6,
      lineSpacing: 6,
    );
  }
}
