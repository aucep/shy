import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'chips.dart';

class StoryTitle extends StatelessWidget {
  final String contentRating, title;
  final bool hot, center;
  StoryTitle({
    this.contentRating,
    this.title,
    this.hot = false,
    this.center = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: center ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              if (contentRating != null) ContentRating(contentRating),
              if (contentRating != null) Container(width: 5),
              Flexible(
                child: Tooltip(
                  child: TextOneLine(
                    title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  message: title,
                ),
              ),
            ],
          ),
        ),
        if (hot)
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
