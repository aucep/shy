import 'package:flutter/material.dart';

//code-splitting
import '../screens/story.dart';
import '../models/story.dart';
import '../util/nav.dart';
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
          onTap: () => Navigator.of(context).pushNamedIfNew('/story', args: StoryArgs(data.id)),
          child: Container(
            margin: EdgeInsets.all(8),
            width: 400,
            child: IntrinsicHeight(
              child: Column(
                children: [
                  StoryTitle(contentRating: data.contentRating, title: data.title),
                  Divider(),
                  Expanded(
                    child: Row(
                      children: [
                        data.imageUrl.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(3, 0, 8, 0),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 100, maxWidth: 100),
                                  child: ExpandableImage(data.imageUrl),
                                ),
                              )
                            : Container(),
                        Expanded(child: Text(data.description)),
                      ],
                    ),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AuthorChip(name: data.authorName, id: data.authorId),
                      Spacer(),
                      WordcountChip(data.wordcount),
                      Container(width: 6),
                      InfoChip(data.recentViews),
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
