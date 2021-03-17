import 'package:badges/badges.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide Element;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/dom.dart' show Document, Element;
import 'package:html/parser.dart' show parse;
import 'package:equatable/equatable.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:html_unescape/html_unescape_small.dart';
//code-splitting
import '../appDrawer.dart';
import '../util/pageData.dart';
import 'chapter.dart';
import 'home.dart';

import '../util/fimHttp.dart';

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
                    Center(
                      child: IntrinsicWidth(
                        child: Row(
                          children: [
                            ContentRating(body.contentRating),
                            Container(width: 5),
                            Expanded(
                              child: Text(
                                body.title,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      ),
                    ),
                    Divider(),
                    if (body.chapters != null)
                      ExpansionTile(
                        initiallyExpanded: true,
                        title: Text(
                            '${body.chapters.length} Chapter${body.chapters.length > 1 ? 's' : ''}'),
                        children: body.chapters
                            .asMap()
                            .entries
                            .map((e) => ChapterRow(
                                  row: e.value,
                                  storyId: args.id,
                                  chapterNum: e.key + 1,
                                  loggedIn: page.value.drawer.loggedIn,
                                ))
                            .toList(),
                      ),
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
  final List<ChapterRowData> chapters;
  final String completedStatus,
      approvedDate,
      totalWordcount,
      viewInfo,
      commentCount,
      likes,
      dislikes;

  const Story(
      {this.likes,
      this.dislikes,
      this.viewInfo,
      this.commentCount,
      this.seriesTags,
      this.genreTags,
      this.warningTags,
      this.characterTags,
      this.contentTags,
      this.chapters,
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
    final offset = ratings.nodes[0].text.trim() == 'Ratings Disabled' ? 0 : 3;
    final viewInfo = ratings.children[3 + offset];
    final commentCount = ratings.children[1 + offset];
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
    final chapters = story.querySelector('.chapters').children;
    //chapters.removeWhere((c) => c.querySelector('.chapter-title') == null);
    //removeWhere is not implemented, fuck me
    List<int> indexesToRemove = [];
    chapters.asMap().forEach((i, c) {
      if (c.querySelector('.chapter-title') == null) indexesToRemove.add(i);
    });
    for (var i = 0; i < indexesToRemove.length; i++) {
      final index = indexesToRemove[i] - i;
      chapters.removeAt(index);
    }

    List<String> tagNames(List<Element> tags) => tags.map((t) => t.innerHtml).toList();

    return Story(
      title: title.innerHtml,
      description: description.innerHtml,
      imageUrl: image != null ? image.attributes['data-src'] : null,
      contentRating: contentRating.innerHtml,
      viewInfo: viewInfo.attributes['title'],
      commentCount: commentCount.attributes['title'],
      likes: likes?.innerHtml,
      dislikes: dislikes?.innerHtml,
      completedStatus: completedStatus.innerHtml,
      approvedDate: approvedDate.innerHtml,
      totalWordcount: wordcount.innerHtml,
      seriesTags: tagNames(seriesTags),
      warningTags: tagNames(warningTags),
      genreTags: tagNames(genreTags),
      contentTags: tagNames(contentTags),
      characterTags: tagNames(characterTags),
      chapters: chapters.map((c) => ChapterRowData.fromStoryRow(c)).toList(),
    );
  }

  static PageData<Story> page(Document doc) {
    return PageData<Story>(drawer: AppDrawerData.fromDoc(doc), body: Story.fromStory(doc));
  }

  Story copyWith({List<ChapterRowData> chapters}) => Story(
        likes: this.likes,
        dislikes: this.dislikes,
        viewInfo: this.viewInfo,
        seriesTags: this.seriesTags,
        genreTags: this.genreTags,
        warningTags: this.warningTags,
        characterTags: this.characterTags,
        contentTags: this.contentTags,
        chapters: chapters ?? this.chapters,
        completedStatus: this.completedStatus,
        approvedDate: this.approvedDate,
        totalWordcount: this.totalWordcount,
        title: this.title,
        description: this.description,
        imageUrl: this.imageUrl,
        contentRating: this.contentRating,
      );
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
      'Drama': 0x895fd6,
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
    color = 0xd6605a;
    if (warning != null) tags.addAll(warning.map(toBadge));
    color = 'genre';
    if (genre != null) tags.addAll(genre.map(toBadge));
    color = 0x4b4b4b;
    if (content != null) tags.addAll(content.map(toBadge));
    color = 0x23b974;
    if (character != null) tags.addAll(character.map(toBadge));

    return WrapSuper(
      children: tags,
      alignment: WrapSuperAlignment.center,
      spacing: 6,
      lineSpacing: 6,
    );
  }
}

class ChapterRow extends HookWidget {
  final bool loggedIn;
  final ChapterRowData row;
  final int storyId, chapterNum;

  ChapterRow({this.loggedIn, this.row, this.storyId, this.chapterNum});

  @override
  Widget build(BuildContext context) {
    final updatingRead = useState(false);
    return ListTile(
      leading: loggedIn
          ? updatingRead.value
              ? CircularProgressIndicator()
              : IconButton(
                  icon: Icon(row.read ? Icons.check_box_outlined : Icons.check_box_outline_blank),
                  onPressed: () async {
                    updatingRead.value = true;
                    print(await row.setRead(!row.read));
                    updatingRead.value = false;
                  })
          : null,
      title: RowSuper(
        children: [
          Text(row.title),
          RowSpacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InfoChip(row.date),
              InfoChip('${row.wordcount} words'),
            ],
          ),
        ],
      ),
      onTap: () => Navigator.pushNamed(
        context,
        '/chapter',
        arguments: ChapterScreenArgs(
          storyId: storyId,
          chapterNum: chapterNum,
        ),
      ),
    );
  }
}

class ChapterRowData {
  final String title, date, wordcount;
  bool read;
  final int id;
  ChapterRowData({this.title, this.date, this.wordcount, this.read, this.id});

  static ChapterRowData fromStoryRow(Element row) {
    final unesc = HtmlUnescape();
    final title = row.querySelector('.chapter-title');
    final date = row.querySelector('.date');
    final wordcount = row.querySelector('.word-count-number');
    final readIcon = row.querySelector('.chapter-read-icon');
    return ChapterRowData(
      title: unesc.convert(title.innerHtml),
      date: date.nodes[1].text,
      wordcount: wordcount.innerHtml.trim(),
      read: readIcon != null ? readIcon.classes.contains('chapter-read') : null,
      id: readIcon != null ? int.parse(readIcon.id.replaceFirst('chapter_read_', '')) : null,
    );
  }

  Future<bool> setRead(bool changedTo) async {
    final resp = await http.ajaxRequest('chapters/$id/read', changedTo ? 'POST' : 'DELETE');
    print(resp);
    read = resp['read'];
    return read;
  }
}
