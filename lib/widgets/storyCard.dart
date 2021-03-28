import 'package:flutter/material.dart';

//code-splitting
import '../screens/story.dart';
import '../screens/home.dart';
import '../models/storyCard.dart';
import '../util/nav.dart';
import 'chips.dart';
import 'expandableImage.dart';

class StoryCard extends StatelessWidget {
  final StoryCardData data;
  StoryCard({this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 3,
      child: Material(
        child: InkWell(
          onTap: () =>
              Navigator.of(context).pushNamedIfNew('/story', args: StoryArgs(data.storyId)),
          child: Container(
            margin: EdgeInsets.all(8),
            width: 400,
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Row(children: [
                    ContentRating(data.contentRating),
                    Container(width: 5),
                    Flexible(
                      child: Text(
                        data.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ]),
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
                      InfoChip(data.authorName),
                      IntrinsicWidth(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InfoChip(data.wordcount),
                            InfoChip(data.viewcount),
                          ],
                        ),
                      ),
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
  final List<StoryCardData> data;
  final refresh;
  StoryCardList(this.data, this.refresh);
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: Scrollbar(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
          children: data.map((c) => StoryCard(data: c)).toList(),
        ),
      ),
    );
  }
}
