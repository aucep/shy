import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InfoChip extends StatelessWidget {
  final label;
  final double padding;
  InfoChip(this.label, {this.padding});

  @override
  Widget build(BuildContext context) {
    return Badge(
      toAnimate: false,
      badgeContent: label is Widget ? label : Text('$label'),
      shape: BadgeShape.square,
      badgeColor: Theme.of(context).chipTheme.backgroundColor,
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
    return Badge(
      toAnimate: false,
      badgeContent: IntrinsicWidth(
        child: Row(
          children: [
            FaIcon(icon, size: 12),
            label is Widget ? label : Text('$label'),
          ],
        ),
      ),
      shape: BadgeShape.square,
      badgeColor: Theme.of(context).chipTheme.backgroundColor,
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
  final void Function() onPressed;
  ButtonChip({this.icon, this.color, this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InfoChip(
      TextButton.icon(
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
