import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//code-splitting
import '../appDrawer.dart';
import '../models/chapter.dart';
import '../models/pageData.dart';
import '../models/story.dart';
import '../util/fimHttp.dart';
import '../util/sharedPrefs.dart';
import '../util/showSnackbar.dart';
import '../widgets/cheatTitle.dart';
import '../widgets/chips.dart';
import '../widgets/expandableImage.dart';
import '../widgets/ratingBar.dart';
import '../widgets/shelvesModal.dart';
import '../widgets/storyTags.dart';
import '../widgets/storyTitle.dart';
import '../widgets/storyCard.dart';
import 'chapter.dart';

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
    var page = useState(PageData<StoryData>());
    final body = page.value?.body;
    final loggedIn = page.value?.drawer?.loggedIn ?? false;

    refresh() async {
      final start = DateTime.now();
      final doc = await fetchDoc('story/${args.id}');
      var elapsed = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      print('doc after $elapsed ms');
      page.value = StoryData.page(doc);
      elapsed = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      print('parsed after $elapsed ms');
    }

    void raiseError(String err) => showSnackbar(context, 'err: $err');

    useEffect(() {
      refresh();
      return;
    }, const []);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: CheatTitle(
            body != null
                ? StoryTitle(
                    center: true,
                    contentRating: body.contentRating,
                    title: body.title,
                    hot: body.hot,
                  )
                : 'story/${args.id}',
          ),
          actions: [
            if (loggedIn)
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => AddToShelvesModal(body, raiseError),
                ),
              ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: "Story"),
              Tab(text: "Chapters"),
              Tab(text: "Related"),
            ],
          ),
        ),
        body: body == null
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  StoryTab(
                    body: body,
                    loggedIn: loggedIn,
                    refresh: refresh,
                  ),
                  ChaptersTab(
                    body: body,
                    storyId: args.id,
                    loggedIn: loggedIn,
                    refresh: refresh,
                  ),
                  RelatedStoriesTab(
                    related: body.relatedStories,
                    refresh: refresh,
                  ),
                ],
              ),
        drawer: AppDrawer(data: page.value.drawer, refresh: refresh),
      ),
    );
  }
}

class StoryTab extends StatelessWidget {
  final StoryData body;
  final bool loggedIn;
  final void Function() refresh;
  const StoryTab({this.body, this.loggedIn, this.refresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: Padding(
        padding: Pad(all: 8),
        child: Scrollbar(
          child: ListView(
            physics: AlwaysScrollableScrollPhysics(), //you know, i have no idea what this does
            children: [
              Divider(),
              StoryInfo(story: body, loggedIn: loggedIn),
              Container(height: 6),
              StoryTagList(tags: body.tags),
              Divider(),
              if (body.imageUrl != null && sharedPrefs.showImages)
                Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: IntrinsicWidth(
                        child: Card(child: IntrinsicWidth(child: ExpandableImage(body.imageUrl))),
                      ),
                    ),
                    Divider(),
                  ],
                ),
              Card(
                child: Padding(
                  padding: Pad(all: 8),
                  child: HtmlWidget(body.description),
                ),
              ),
              Divider(),
              ChaptersInfo(
                completedStatus: body.completedStatus,
                date: body.approvedDate,
                wordcount: body.wordcount,
                chapterCount: body.chapters.length,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChaptersTab extends StatelessWidget {
  final StoryData body;
  final String storyId;
  final bool loggedIn;
  final void Function() refresh;
  ChaptersTab({this.body, this.storyId, this.loggedIn, this.refresh});

  @override
  Widget build(BuildContext context) {
    final chapters = ListTile.divideTiles(
      context: context,
      tiles: body.chapters
          .asMap()
          .map(
            //this is a stupid
            (k, v) => MapEntry(
              k,
              ChapterRow(
                row: v,
                storyId: storyId,
                chapterNum: k + 1,
                loggedIn: loggedIn,
              ),
            ),
          )
          .values,
    ).toList();

    return RefreshIndicator(
      onRefresh: refresh,
      child: Scrollbar(
        child: ListView.builder(
          padding: Pad(vertical: 8),
          itemBuilder: (_, i) => i == 0
              ? Column(
                  children: [
                    Divider(),
                    ChaptersInfo(
                      completedStatus: body.completedStatus,
                      date: body.approvedDate,
                      wordcount: body.wordcount,
                      chapterCount: body.chapters.length,
                    ),
                    Container(
                      //why
                      height: 8,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 0),
                        ),
                      ),
                    ),
                  ],
                )
              : i > chapters.length
                  ? Container(
                      // FUCKING MURDER ME OH MY GOD
                      height: 8,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Theme.of(context).dividerColor, width: 0),
                        ),
                      ),
                    )
                  : chapters[i - 1],
          itemCount: chapters.length + 2,
        ),
      ),
    );
  }
}

class ChapterRow extends HookWidget {
  final bool loggedIn;
  final ChapterData row;
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
                  icon: Icon(row.read ? Icons.check_box : Icons.check_box_outline_blank),
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
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                DateChip(row.date),
                WordcountChip(row.wordcount),
              ],
            ),
          ),
        ],
      ),
      onTap: () => Navigator.pushNamed(
        context,
        '/chapter',
        arguments: ChapterArgs(
          storyId: storyId,
          chapterNum: chapterNum,
        ),
      ),
    );
  }
}

class StoryInfo extends StatelessWidget {
  final StoryData story;
  final bool loggedIn;
  StoryInfo({this.story, this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return WrapSuper(
      alignment: WrapSuperAlignment.center,
      children: [
        AuthorChip(name: story.authorName, id: story.authorId),
        RatingBar(rating: story.rating, loggedIn: loggedIn),
        InfoChip.icon(FontAwesomeIcons.solidComments, story.comments),
        InfoChip.icon(FontAwesomeIcons.eye, story.totalViews),
      ],
      spacing: 6,
      lineSpacing: 6,
    );
  }
}

class ChaptersInfo extends StatelessWidget {
  final String completedStatus, date, wordcount;
  final int chapterCount;
  const ChaptersInfo({this.completedStatus, this.date, this.wordcount, this.chapterCount});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        CompletedStatus(completedStatus),
        WordcountChip(wordcount),
        DateChip(date),
        InfoChip('$chapterCount Chapter${chapterCount > 1 ? 's' : ''}'),
      ],
    );
  }
}

class RelatedStoriesTab extends StatelessWidget {
  final RelatedStoriesData related;
  final void Function() refresh;
  RelatedStoriesTab({this.related, this.refresh});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Expanded(
            child: TabBarView(
              children: [
                related.alsoLiked.length > 0
                    ? StoryCardList(
                        data: related.alsoLiked,
                        refresh: refresh,
                      )
                    : None(refresh),
                related.similar.length > 0
                    ? StoryCardList(
                        data: related.similar,
                        refresh: refresh,
                      )
                    : None(refresh),
                related.author.length > 0
                    ? StoryCardList(
                        data: related.author,
                        refresh: refresh,
                      )
                    : None(refresh),
              ],
            ),
          ),
          Material(
            color: ThemeData().primaryColor,
            child: SizedBox(
              height: kTextTabBarHeight,
              child: TabBar(
                labelPadding: Pad(
                    vertical:
                        (kTextTabBarHeight - Theme.of(context).textTheme.subtitle1.fontSize) / 2),
                tabs: [
                  Text('Also Liked'),
                  Text('Similar'),
                  Text('Author'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class None extends StatelessWidget {
  final void Function() refresh;
  None(this.refresh);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Container(
            alignment: Alignment.center,
            height: box.maxHeight,
            child: Opacity(
              opacity: 0.5,
              child: Text(
                'none!',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
