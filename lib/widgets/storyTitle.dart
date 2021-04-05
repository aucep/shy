import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'chips.dart';

class StoryTitle extends StatelessWidget {
  final String contentRating, title;
  final bool hot, center;
  StoryTitle({this.contentRating, this.title, this.hot, this.center});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: center ?? false ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (contentRating != null)
          Row(
            children: [
              ContentRating(contentRating),
              Container(width: 5),
            ],
          ),
        Flexible(
          child: InkWell(
            onTap: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            child: TextOneLine(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (hot ?? false)
          Padding(
            padding: Pad(left: 5),
            child: FaIcon(
              FontAwesomeIcons.fire,
              size: 18,
              color: Colors.deepOrange,
            ),
          ),
      ],
    );
  }
}
