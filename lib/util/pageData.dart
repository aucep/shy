import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' show Document;
import 'package:html/parser.dart' show parse;
import 'package:brotli/brotli.dart';
//code-splitting
import '../appDrawer.dart';
import 'fimHttp.dart';

Future<Document> fetchDoc(String path) async {
  print("fetching /$path");
  final start = DateTime.now();
  final resp = await http.get("https://fimfiction.net/$path");
  final elapsed = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
  print("downloaded after $elapsed ms");

  print(resp.headers['content-encoding']); //gzip, zlib already covered by http.dart
  String body;
  switch (resp.headers['content-encoding']) {
    case "br":
      body = utf8.decode(brotli.decodeToString(resp.bodyBytes).codeUnits);
      break;
    default:
      body = resp.body;
  }

  return parse(body);
}

class PageData<T> {
  final AppDrawerData drawer;
  final T body;

  PageData({this.drawer, this.body});
}

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
//it's quiet in here