import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';

//code-splitting
import '../util/sharedPrefs.dart';

class ExpandableImage extends StatelessWidget {
  final String url;
  ExpandableImage(this.url);

  @override
  Widget build(BuildContext context) {
    return sharedPrefs.showImages
        ? Container(
            child: FullScreenWidget(
              child: Hero(tag: url, child: Image.network(url, fit: BoxFit.contain)),
              backgroundColor: Color.fromARGB(0, 0, 0, 0),
              backgroundIsTransparent: true,
            ),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            clipBehavior: Clip.antiAlias,
          )
        : Container();
  }
}
