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
  InfoChip(this.label, {this.padding, this.color});

  @override
  Widget build(BuildContext context) {
    return Badge(
      toAnimate: false,
      badgeContent: label is Widget ? label : Text('$label'),
      shape: BadgeShape.square,
      badgeColor: color ?? Theme.of(context).chipTheme.backgroundColor,
      borderRadius: BorderRadius.circular(3),
      elevation: 0,
      padding: Pad(all: padding ?? 4),
    );
  }
}

class IconChip extends StatelessWidget {
  final label;
  final IconData icon;
  final double padding;
  IconChip(this.icon, this.label, {this.padding});

  @override
  Widget build(BuildContext context) {
    return InfoChip(
      RowSuper(
        fill: false,
        children: [
          FaIcon(icon, size: 12),
          label is Widget ? label : Text(' $label'),
        ],
      ),
    );
  }
}

class ButtonChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final void Function() onPressed;
  ButtonChip({this.icon, this.color, this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InfoChip(
      icon == null
          ? TextButton(
              child: Text(label),
              onPressed: onPressed,
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(Pad(all: 12)),
                minimumSize: MaterialStateProperty.all<Size>(Size.zero),
                foregroundColor: MaterialStateProperty.all<Color>(
                  color ?? Theme.of(context).textTheme.bodyText1.color,
                ),
              ),
            )
          : TextButton.icon(
              icon: Icon(
                icon,
                color: color,
                size: Theme.of(context).textTheme.bodyText1.fontSize,
              ),
              label: Text(label),
              onPressed: onPressed,
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(Pad(all: 12)),
                minimumSize: MaterialStateProperty.all<Size>(Size.zero),
                foregroundColor: MaterialStateProperty.all<Color>(
                  color ?? Theme.of(context).textTheme.bodyText1.color,
                ),
              ),
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
    return IconChip(FontAwesomeIcons.penNib, label);
  }
}

class DateChip extends StatelessWidget {
  final String label;
  const DateChip(this.label);

  @override
  Widget build(BuildContext context) {
    return IconChip(FontAwesomeIcons.calendar, label);
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
