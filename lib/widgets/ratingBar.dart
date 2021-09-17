//flutter
import 'package:flutter/material.dart';

import 'package:flutter_hooks/flutter_hooks.dart';

//local
import '../widgets/chips.dart';
import '../models/bars.dart';
import '../util/showSnackbar.dart';

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
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoChip.icon(Icons.thumb_up, rating.likes),
          Container(width: 6),
          InfoChip.icon(Icons.thumb_down, rating.dislikes),
        ],
      );
    } else {
      return Row(
        mainAxisSize: MainAxisSize.min,
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
