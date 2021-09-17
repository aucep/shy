//flutter
import 'package:flutter/material.dart';

import 'package:full_screen_image/full_screen_image.dart';

//local
import '../util/sharedPrefs.dart';

class ExpandableImage extends StatelessWidget {
  final String url;
  ExpandableImage(this.url);

  @override
  Widget build(BuildContext context) {
    return sharedPrefs.showImages
        ? Container(
            foregroundDecoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(4)),
            child: FullScreenWidget(
              child: Hero(tag: url, child: Image.network(url, fit: BoxFit.contain)),
              backgroundColor: Color.fromARGB(0, 0, 0, 0),
              backgroundIsTransparent: true,
            ),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(4)),
            clipBehavior: Clip.antiAlias,
          )
        : Container();
  }
}
