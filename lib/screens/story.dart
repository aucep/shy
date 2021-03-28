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
    var page = useState(PageData<StoryData>());
    final body = page.value?.body;

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

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: CheatTitle('story'),
        actions: [
          IconButton(
            icon: Icon(Icons.book),
            onPressed: () => showModalBottomSheet(
              context: context,
              builder: (_) => AddToShelvesModal(body, raiseError),
            ),
          ),
        ],
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
                            if (body != null) InfoRow(body),
                            Container(height: 6),
                            StoryTagList(tags: body.tags),
                            Divider(),
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
        arguments: ChapterArgs(
          storyId: storyId,
          chapterNum: chapterNum,
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final StoryData story;
  InfoRow(this.story);

  @override
  Widget build(BuildContext context) {
    return WrapSuper(
      alignment: WrapSuperAlignment.center,
      children: [
        if (story.hot) FaIcon(FontAwesomeIcons.fire),
        RatingBar(story.rating),
        IconChip(FontAwesomeIcons.solidComments, ' ${story.comments}'),
        IconChip(FontAwesomeIcons.eye, ' ${story.totalViews.replaceAll(',', '')}'),
        IconChip(FontAwesomeIcons.calendar, ' ${story.approvedDate}')
      ],
      spacing: 6,
      lineSpacing: 6,
    );
  }
}
