import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//code-splitting
import '../util/showSnackbar.dart';
import '../widgets/userModal.dart';

class InfoChip extends StatelessWidget {
  final label;
  final String tooltip;
  final double padding;
  final Color backgroundColor;
  final IconData icon;
  const InfoChip(this.label, {this.padding, this.backgroundColor, this.icon, this.tooltip});
  const InfoChip.icon(this.icon, this.label, {this.padding, this.backgroundColor, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final label = this.label is Widget ? this.label : Text(this.label.trim());
    return Tooltip(
      message: tooltip ?? this.label,
      child: Badge(
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
        badgeColor: backgroundColor ?? Theme.of(context).chipTheme.backgroundColor,
        borderRadius: BorderRadius.circular(3),
        elevation: 0,
        padding: Pad(all: padding ?? 4),
      ),
    );
  }
}

class ButtonChip extends StatelessWidget {
  final IconData icon;
  final Color textColor, backgroundColor;
  final String label;
  final double padding;
  final void Function() onTap, onLongPress;
  const ButtonChip({
    this.icon,
    this.textColor,
    this.backgroundColor,
    this.label,
    this.padding,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(this.label, style: textColor == null ? null : TextStyle(color: textColor));
    return InfoChip(
      InkWell(
        child: Padding(
            child: icon == null
                ? label
                : Row(
                    children: [
                      FaIcon(icon, size: 12, color: textColor),
                      Container(width: 4),
                      label,
                    ],
                  ),
            padding: Pad(all: padding ?? 4)),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
      padding: 0,
      backgroundColor: backgroundColor,
      tooltip: this.label,
    );
  }
}

class ContentRating extends StatelessWidget {
  final String rating;
  const ContentRating(this.rating);

  static const colors = {
    'E': Color(0xff78ac40),
    'T': Color(0xffffb400),
    'M': Color(0xffc03d2f),
  };

  static const fullRating = {
    'E': 'Rated Everyone',
    'T': 'Rated Teen',
    'M': 'Rated Mature',
  };

  @override
  Widget build(BuildContext context) {
    return InfoChip(
      Text(rating, overflow: TextOverflow.visible),
      backgroundColor: colors[rating],
      tooltip: fullRating[rating],
    );
  }
}

class CompletedStatus extends StatelessWidget {
  final String status;
  const CompletedStatus(this.status);

  static const colors = {
    'Complete': Color(0xff63bd40),
    'Incomplete': Color(0xfff7a616),
    'Cancelled': Color(0xffee5555),
    'On Hiatus': Color(0xffbd7b40),
  };

  @override
  Widget build(BuildContext context) {
    return InfoChip(status, backgroundColor: colors[status]);
  }
}

class IconChip extends StatelessWidget {
  final IconData icon;
  final String label, tooltipPrefix, tooltipSuffix;
  final bool trim;
  IconChip(
      {this.icon, this.label, this.tooltipPrefix = '', this.tooltipSuffix = '', this.trim = true});
  IconChip.words(
    this.label, {
    this.icon = FontAwesomeIcons.penNib,
    this.tooltipPrefix = '',
    this.tooltipSuffix = ' words',
    this.trim = true,
  });
  IconChip.views(
    this.label, {
    this.icon = FontAwesomeIcons.solidEye,
    this.tooltipPrefix = '',
    this.tooltipSuffix = ' views',
    this.trim = true,
  });
  IconChip.date(
    this.label, {
    this.icon = FontAwesomeIcons.calendar,
    this.tooltipPrefix = 'Published ',
    this.tooltipSuffix = '',
    this.trim = false,
  });
  IconChip.comments(
    this.label, {
    this.icon = FontAwesomeIcons.solidComments,
    this.tooltipPrefix = '',
    this.tooltipSuffix = ' comments',
    this.trim = true,
  });

  @override
  Widget build(BuildContext context) {
    final label = trim ? this.label.split(' ').first : this.label;
    return InfoChip.icon(icon, label, tooltip: '$tooltipPrefix$label$tooltipSuffix');
  }
}

class UserChip extends StatelessWidget {
  final String name, id;
  const UserChip({this.name, this.id});

  @override
  Widget build(BuildContext context) {
    return ButtonChip(
      label: name,
      onTap: () => showModalBottomSheet(
        context: context,
        builder: (_) => UserModal(id, (msg) => showSnackbar(context, msg)),
        enableDrag: true,
      ),
      onLongPress: () => showSnackbar(context, 'author screen not implemented yet'),
    );
  }
}
