import 'package:flutter/material.dart';

class CheatTitle extends StatelessWidget {
  final String title;
  CheatTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (Navigator.canPop(context))
          IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        IconButton(icon: Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer()),
        Expanded(child: Center(child: Text(title))),
      ],
    );
  }
}
