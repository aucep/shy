import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:shy/widgets/storyTags.dart';

//code-splitting
import '../screens/story.dart';
import '../models/story.dart';
import 'chips.dart';
import 'expandableImage.dart';
import 'storyTitle.dart';

class StoryCard extends StatelessWidget {
  final StoryData data;
  StoryCard({this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 3,
      child: Material(
        child: InkWell(
          onTap: () => Navigator.of(context).pushNamed('/story', arguments: StoryArgs(data.id)),
          child: Container(
            margin: EdgeInsets.all(8),
            width: 400,
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StoryTitle(contentRating: data.contentRating, title: data.title),
                  if (data.tags.series.isNotEmpty) Divider(),
                  StoryTagList(
                    tags: data.tags,
                    center: false,
                  ),
                  Divider(),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        data.imageUrl.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(3, 0, 8, 0),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 120, maxWidth: 120),
                                  child: ExpandableImage(data.imageUrl),
                                ),
                              )
                            : Container(),
                        Expanded(
                          child: Text(data.description),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  WrapSuper(
                    spacing: 4,
                    lineSpacing: 4,
                    children: [
                      UserChip(name: data.authorName, id: data.authorId),
                      IconChip.words(data.wordcount),
                      IconChip.views(data.recentViews),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StoryCardList extends StatelessWidget {
  final List<StoryData> data;
  final refresh;
  StoryCardList({this.data, this.refresh});
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: Scrollbar(
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
          itemBuilder: (_, i) => StoryCard(data: data[i]),
          itemCount: data.length,
        ),
      ),
    );
  }
}
