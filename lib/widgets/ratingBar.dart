import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

//code-splitting
import '../models/rating.dart';
import '../util/showSnackbar.dart';
import 'chips.dart';

class RatingBar extends HookWidget {
  final RatingBarData rating;
  final bool loggedIn;
  RatingBar({this.rating, this.loggedIn});

  @override
  Widget build(BuildContext context) {
    final change = useState(false);

    if (rating.disabled) {
      return InfoChip('ratings disabled');
    } else if (!loggedIn) {
      return RowSuper(
        children: [
          IconChip(Icons.thumb_up, rating.likes),
          Container(width: 6),
          IconChip(Icons.thumb_down, rating.dislikes),
        ],
      );
    } else {
      return RowSuper(
        children: [
          ButtonChip(
            icon: Icons.thumb_up,
            color: rating.liked ? Colors.green : null,
            label: rating.likes,
            onPressed: () async {
              final err = await rating.like();
              if (err != null) {
                showSnackbar(context, 'err: $err');
                return;
              }
              change.value = !change.value;
            },
          ),
          Container(width: 6),
          ButtonChip(
            icon: Icons.thumb_down,
            color: rating.disliked ? Colors.red : null,
            label: rating.dislikes,
            onPressed: () async {
              final err = await rating.dislike();
              if (err != null) {
                showSnackbar(context, 'err: $err');
                return;
              }
              change.value = !change.value;
            },
          ),
        ],
      );
    }
  }
}
