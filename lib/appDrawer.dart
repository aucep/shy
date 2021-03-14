import 'dart:convert' show jsonDecode;

import 'package:badges/badges.dart';
import 'package:brotli/brotli.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:html/dom.dart' show Document;
import 'package:html_unescape/html_unescape_small.dart';
//code-splitting
import 'screens/chapter.dart';
import 'util/fimHttp.dart';
import 'util/sharedPrefs.dart';

class AppDrawer extends HookWidget {
  final AppDrawerData data;
  final void Function() refresh;
  AppDrawer({this.data, this.refresh});

  void _logout() async {
    await http.post("https://www.fimfiction.net/ajax/logout");
    sharedPrefs.sessionToken = "";
    sharedPrefs.signingKey = "";
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    final data = this.data ??
        AppDrawerData(
          loggedIn: false,
          avatarUrl: "",
        );
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      /*if (data.avatarUrl != null)
                        Image.network(data.avatarUrl, width: 90, height: 90),*/
                      Text(data.username ?? "not logged in"),
                    ],
                  ),
                ),
                Spacer(),
                data.loggedIn
                    ? OutlinedButton(
                        child: Text("log out"),
                        onPressed: _logout,
                      )
                    : OutlinedButton(
                        child: Text("login"),
                        onPressed: () => showDialog(
                              context: context,
                              builder: (context) => LoginDialog(refresh: refresh),
                            )),
              ],
            ),
          ),
          DrawerRouteItem(title: "Stories", route: "/"),
          DrawerRouteItem(title: "Groups", route: "/"),
          DrawerRouteItem(title: "News", route: "/"),
          DrawerRouteItem(
            title: "Chapter",
            route: "/chapter",
            arguments: ChapterScreenArgs(storyId: 395988, chapterNum: 1),
          ),
          if (data?.shelves != null)
            if (data.shelves.length > 0) Bookshelves(shelves: data.shelves),
        ],
      ),
    );
  }
}

class DrawerRouteItem extends StatelessWidget {
  final String title;
  final String route;
  final dynamic arguments;

  DrawerRouteItem({this.title, this.route, this.arguments});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(title),
        onTap: () => {
              if (ModalRoute.of(context).settings.name != route)
                Navigator.pushNamed(context, route, arguments: arguments)
            });
  }
}

class AppDrawerData {
  final bool loggedIn;
  final String username, avatarUrl, bgColor, userId;
  final List<BookshelfData> shelves;

  AppDrawerData(
      {this.loggedIn, this.username, this.avatarUrl, this.bgColor, this.userId, this.shelves});

  static AppDrawerData fromDoc(Document doc) {
    final htmlConfig = jsonDecode(
        doc.querySelector(".navigation-drawer-container").attributes["data-html-config"]);

    final user = htmlConfig["user"];
    final List<dynamic> shelves = htmlConfig["bookshelves"];
    return AppDrawerData(
        loggedIn: htmlConfig["loggedIn"],
        username: user["name"],
        avatarUrl: user["avatar"],
        userId: user["url"].split("/")[2],
        bgColor: user["backgroundColor"],
        shelves: shelves
            .map(
              (s) => BookshelfData.fromMap(s),
            )
            .toList());
  }
}

class BookshelfData {
  String name;
  final String icon, iconStyle, iconType;
  final int numUnread, id;

  BookshelfData({this.name, this.numUnread, this.icon, this.iconStyle, this.iconType, this.id});

  static BookshelfData fromMap(s) {
    final unesc = HtmlUnescape();

    final iconHtml = s['iconHtml'].split('"');
    final iconType = iconHtml[1];
    final iconClasses = iconHtml[3].split(' ');

    return BookshelfData(
      name: s['name'],
      icon: iconType == 'font-awesome'
          ? iconClasses.last
          : unesc.convert(iconHtml.last.split('>')[2].replaceFirst(r'</span', '') + ";"),
      iconStyle: s['style'],
      iconType: iconType,
      id: int.parse(s['url'].split('/')[2]),
      numUnread: int.parse(s['numUnread'].toString()),
    );
  }
}

class LoginDialog extends HookWidget {
  final _formKey = GlobalKey<FormState>();
  final void Function() refresh;
  LoginDialog({this.refresh});

  @override
  Widget build(BuildContext context) {
    String username, password;
    bool rememberMe;

    return AlertDialog(
      title: Text("Log in"),
      content: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Form(
          key: _formKey,
          child: IntrinsicHeight(
            child: Column(
              children: [
                TextFormField(
                    decoration:
                        InputDecoration(labelText: "Username:", icon: Icon(Icons.account_circle)),
                    validator: (v) {
                      if (v.isEmpty) return "Must have username";
                      username = v;
                      return null;
                    }),
                TextFormField(
                    decoration: InputDecoration(labelText: "Password:", icon: Icon(Icons.lock)),
                    validator: (v) {
                      if (v.isEmpty) return "Must have password";
                      password = v;
                      return null;
                    },
                    //password things
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false),
                FormField(
                    initialValue: true,
                    validator: (v) {
                      rememberMe = v;
                      return null;
                    },
                    builder: (state) => CheckboxListTile(
                        title: Text("Remember me"),
                        onChanged: state.didChange,
                        value: state.value)),
              ],
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          child: Text("Submit"),
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              final err = await _login(username, password, rememberMe);
              if (err.isEmpty) {
                Navigator.pop(context);
                refresh();
              } else {
                Flushbar(
                  message: "error: $err",
                  duration: Duration(seconds: 4),
                  animationDuration: Duration(milliseconds: 350),
                ).show(context);
              }
            }
          },
        ),
      ],
    );
  }

  Future<String> _login(String username, String password, bool rememberMe) async {
    final resp = await http.post("https://www.fimfiction.net/ajax/login", body: {
      "username": username,
      "password": password,
      "keep_logged_in": rememberMe.toString(),
    });
    print("${resp.headers['content-encoding']} encoding"); //gzip already covered by http.dart
    String body;
    switch (resp.headers['content-encoding']) {
      case "br":
        body = brotli.decodeToString(resp.bodyBytes);
        break;
      default:
        body = resp.body;
    }
    final bodyJson = jsonDecode(body);
    if (bodyJson.containsKey("error")) {
      print(bodyJson["error"]);
      return bodyJson["error"];
    }
    final setCookie = resp.headers["set-cookie"];
    match(s) => RegExp("(?<=$s=(?!.*$s)).+?(?=\;)").firstMatch(setCookie).group(0);
    sharedPrefs.sessionToken = match("session_token");
    sharedPrefs.signingKey = bodyJson["signing_key"];
    return "";
  }
}

class Bookshelves extends StatelessWidget {
  final List<BookshelfData> shelves;
  Bookshelves({this.shelves});

  final GlobalKey libraryKey = GlobalKey();
  final GlobalKey hiddenShelvesKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    //hide shelves?
    List<BookshelfData> hiddenShelves;
    final hidableShelves = sharedPrefs.hidableShelves;
    if (hidableShelves) {
      final prefix = sharedPrefs.shelfHidePrefix;
      //extract all shelves with prefix
      hiddenShelves = shelves.where((s) => s.name.startsWith(prefix)).toList();
      shelves.removeWhere((s) => s.name.startsWith(prefix));

      if (sharedPrefs.shelfTrimHidePrefix) {
        //trim prefix
        hiddenShelves.forEach((s) => s.name = s.name.replaceFirst(prefix, ''));
      }
    }

    //shelves to tiles
    List<Widget> shelfTiles = shelves.map<Widget>((s) => ShelfTile(s)).toList();

    //add (hidden shelves->tiles)
    if (hidableShelves) {
      final hiderTile = ExpansionTile(
        leading: FaIcon(FontAwesomeIcons.book),
        title: Text('Hidden shelves'),
        children: hiddenShelves.map((s) => ShelfTile(s)).toList(),
        key: hiddenShelvesKey,
        onExpansionChanged: (v) {
          if (v) _scrollIntoView(hiddenShelvesKey);
        },
      );
      shelfTiles.add(hiderTile);
    }
    return ExpansionTile(
      title: Text("Library"),
      children: shelfTiles,
      initiallyExpanded: sharedPrefs.showShelves,
      key: libraryKey,
      onExpansionChanged: (v) {
        sharedPrefs.showShelves = v;
        if (v) _scrollIntoView(libraryKey);
      },
    );
  }

  _scrollIntoView(GlobalKey key) async {
    final keyContext = key.currentContext;
    if (keyContext != null) {
      await Future.delayed(Duration(milliseconds: 220));
      Scrollable.ensureVisible(keyContext,
          duration: Duration(milliseconds: 200),
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
    }
  }
}

class ShelfTile extends StatelessWidget {
  final BookshelfData s;
  ShelfTile(this.s);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: s.numUnread > 0
            ? Badge(
                child: ShelfIcon(icon: s.icon, type: s.iconType),
                badgeContent: Text('${s.numUnread}', style: TextStyle(fontSize: 11)),
                padding: EdgeInsets.all(3),
              )
            : ShelfIcon(icon: s.icon, type: s.iconType),
        title: Text(s.name),
        onTap: () {});
  }
}

class ShelfIcon extends StatelessWidget {
  final String icon, style, type;
  ShelfIcon({this.icon, this.style, this.type});

  @override
  Widget build(BuildContext context) {
    return type == 'font-awesome'
        ? FaIcon(FontAwesomeIcons.book)
        : Text(icon, style: TextStyle(fontSize: 20));
  }
}
