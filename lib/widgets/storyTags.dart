import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import '../models/storyTags.dart';

class StoryTagList extends StatelessWidget {
  final StoryTags tags;
  final bool center, leading, trailing;

  const StoryTagList({
    this.tags,
    this.center = true,
    this.leading = false,
    this.trailing = false,
  });

  static const genreColors = {
    'Adventure': Color(0xff6fb859),
    'Comedy': Color(0xfff59c00),
    'Drama': Color(0xff895fd6),
    'Dark': Color(0xffb93737),
    'Horror': Color(0xffb93737),
    'Romance': Color(0xffcd58a7),
  };

  @override
  Widget build(BuildContext context) {
    List<Badge> badges = [];

    dynamic color; //series color
    Badge toBadge(String tag) {
      final badgeColor = color == 'genre'
          ? genreColors.containsKey(tag)
              ? genreColors[tag]
              : Color(0xff4f91d6) //default genre tag color
          : Color(0xff000000 + color);

      return Badge(
        toAnimate: false,
        badgeContent: Text(tag, style: TextStyle(color: Colors.white, fontSize: 13)),
        shape: BadgeShape.square,
        badgeColor: badgeColor,
        padding: EdgeInsets.all(3),
        borderRadius: BorderRadius.circular(3),
        elevation: 0,
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
      wrapType: center ? WrapType.balanced : WrapType.fit,
      alignment: center ? WrapSuperAlignment.center : WrapSuperAlignment.left,
      spacing: 4,
      lineSpacing: 4,
    );
  }
}
