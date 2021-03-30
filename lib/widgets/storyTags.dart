import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import '../models/storyTags.dart';

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
