import 'package:badges/badges.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:equatable/equatable.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:shy/util/snackbar.dart';

//code-splitting
import '../appDrawer.dart';
import '../models/pageData.dart';
import '../models/story.dart';
import '../models/tags.dart';
import '../models/chapter.dart';
import '../widgets/cheatTitle.dart';
import '../widgets/shelvesModal.dart';
import '../util/fimHttp.dart';
import '../util/sharedPrefs.dart';
import 'chapter.dart';
import 'home.dart';

class StoryArgs extends Equatable {
  final String id;
  const StoryArgs(this.id);

  @override
  List<Object> get props => [id];
}

class StoryScreen extends HookWidget {
  final StoryArgs args;
  const StoryScreen(this.args);

  @override
  Widget build(BuildContext context) {
    var page = useState(Page<Story>());
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

    void raiseError(String err) => showSnackbar(context, 'err: $err');

    useEffect(() {
      refresh();
      return;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: CheatTitle('story'),
      ),
      body: body == null
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: refresh,
              child: Scrollbar(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, i) => i == 0
                      ? Padding(
                          padding: Pad(all: 8),
                          child: Column(children: [
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
                            if (body != null) Ratings(body),
                            Container(height: 6),
                            StoryTagList(tags: body.tags),
                            Divider(),
                            IconButton(
                              icon: Icon(Icons.library_add_outlined),
                              onPressed: () => showModalBottomSheet(
                                context: context,
                                builder: (_) => AddToShelvesModal(body, raiseError),
                              ),
                            ),
                            if (body?.imageUrl != null && sharedPrefs.showImages)
                              ConstrainedBox(
                                constraints: BoxConstraints(maxHeight: 200, maxWidth: 200),
                                child: IntrinsicWidth(
                                  child: Card(
                                      child: IntrinsicWidth(child: ExpandableImage(body.imageUrl))),
                                ),
                              ),
                            Card(
                              child: Padding(
                                padding: EdgeInsets.all(8),
                                child: HtmlWidget(body.description),
                              ),
                            ),
                            Divider(),
                            Text(
                                '${body.chapters.length} Chapter${body.chapters.length > 1 ? 's' : ''}'),
                          ]))
                      : ChapterRow(
                          row: body.chapters[i - 1],
                          storyId: args.id,
                          chapterNum: i,
                          loggedIn: page.value.drawer.loggedIn,
                        ),
                  itemCount: body.chapters != null ? body.chapters.length + 1 : 1,
                ),
              ),
            ),
      drawer: AppDrawer(data: page.value.drawer, refresh: refresh),
    );
  }
}

class StoryTagList extends StatelessWidget {
  final StoryTags tags;

  const StoryTagList({this.tags});

  @override
  Widget build(BuildContext context) {
    List<Badge> badges = [];
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
    badges.addAll(tags.series.map(toBadge));
    color = 0xd6605a;
    if (tags.warning != null) badges.addAll(tags.warning.map(toBadge));
    color = 'genre';
    if (tags.genre != null) badges.addAll(tags.genre.map(toBadge));
    color = 0x4b4b4b;
    if (tags.content != null) badges.addAll(tags.content.map(toBadge));
    color = 0x23b974;
    if (tags.character != null) badges.addAll(tags.character.map(toBadge));

    return WrapSuper(
      children: badges,
      alignment: WrapSuperAlignment.center,
      spacing: 6,
      lineSpacing: 6,
    );
  }
}

class ChapterRow extends HookWidget {
  final bool loggedIn;
  final Chapter row;
  final String storyId;
  final int chapterNum;

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
                    await row.setRead(!row.read);
                    updatingRead.value = false;
                  })
          : null,
      title: Row(
        children: [
          Expanded(child: Text(row.title)),
          Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              InfoChip(row.date),
              IconChip(FontAwesomeIcons.penNib, ' ${row.wordcount}'),
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

class Ratings extends HookWidget {
  final Story story;
  Ratings(this.story);

  @override
  Widget build(BuildContext context) {
    return WrapSuper(
      alignment: WrapSuperAlignment.center,
      children: [
        IconChip(FontAwesomeIcons.solidComments, ' ${story.totalViews}'),
        IconChip(FontAwesomeIcons.chartBar, ' ${story.comments}'),
      ],
      spacing: 6,
      lineSpacing: 6,
    );
  }
}
