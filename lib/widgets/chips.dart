import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//code-splitting
import '../util/showSnackbar.dart';

class InfoChip extends StatelessWidget {
  final label;
  final double padding;
  final Color color;
  final IconData icon;
  InfoChip(this.label, {this.padding, this.color, this.icon});
  InfoChip.icon(this.icon, this.label, {this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    final label = this.label is Widget ? this.label : Text(this.label);
    return Badge(
      toAnimate: false,
      badgeContent: icon == null
          ? label
          : RowSuper(
              fill: false,
              children: [
                FaIcon(icon, size: 12),
                Container(width: 4),
                label,
              ],
            ),
      shape: BadgeShape.square,
      badgeColor: color ?? Theme.of(context).chipTheme.backgroundColor,
      borderRadius: BorderRadius.circular(3),
      elevation: 0,
      padding: Pad(all: padding ?? 4),
    );
  }
}

class ButtonChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final double padding;
  final void Function() onPressed;
  ButtonChip({this.icon, this.color, this.label, this.padding, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final label = Text(this.label, style: color == null ? null : TextStyle(color: color));
    return InfoChip(
      InkWell(
        child: Padding(
            child: icon == null
                ? label
                : Row(
                    children: [
                      FaIcon(icon, size: 12, color: color),
                      Container(width: 4),
                      label,
                    ],
                  ),
            padding: Pad(all: padding ?? 4)),
        onTap: onPressed,
      ),
      padding: 0,
    );
  }
}

class ContentRating extends StatelessWidget {
  final String rating;
  ContentRating(this.rating);

  @override
  Widget build(BuildContext context) {
    return InfoChip(
      Text(rating, overflow: TextOverflow.visible),
      color: rating == 'E'
          ? const Color(0xff78ac40)
          : rating == 'T'
              ? const Color(0xffffb400)
              : const Color(0xffc03d2f),
    );
  }
}

class CompletedStatus extends StatelessWidget {
  final String status;
  CompletedStatus(this.status);

  @override
  Widget build(BuildContext context) {
    return InfoChip(
      status,
      color: status == 'Complete'
          ? Color(0xff63bd40)
          : status == 'Incomplete'
              ? Color(0xfff7a616)
              : status == 'Cancelled'
                  ? Color(0xffee5555)
                  : Color(0xff4444dd), //Hiatus
    );
  }
}

class WordcountChip extends StatelessWidget {
  final String label;
  const WordcountChip(this.label);

  @override
  Widget build(BuildContext context) {
    return InfoChip.icon(FontAwesomeIcons.penNib, label);
  }
}

class DateChip extends StatelessWidget {
  final String label;
  const DateChip(this.label);

  @override
  Widget build(BuildContext context) {
    return InfoChip.icon(FontAwesomeIcons.calendar, label);
  }
}

class AuthorChip extends StatelessWidget {
  final String name, id;
  const AuthorChip({this.name, this.id});

  @override
  Widget build(BuildContext context) {
    return ButtonChip(
      label: name,
      onPressed: () {
        showSnackbar(context, 'author screen not implemented yet');
      },
    );
  }
}
