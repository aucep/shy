import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

//code-splitting
import '../models/bars.dart';
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
          InfoChip.icon(Icons.thumb_up, rating.likes),
          Container(width: 6),
          InfoChip.icon(Icons.thumb_down, rating.dislikes),
        ],
      );
    } else {
      return RowSuper(
        children: [
          ButtonChip(
            icon: Icons.thumb_up,
            textColor: rating.liked ? Colors.green : null,
            label: rating.likes,
            onTap: () async {
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
            textColor: rating.disliked ? Colors.red : null,
            label: rating.dislikes,
            onTap: () async {
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
