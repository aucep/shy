import 'dart:convert' show jsonDecode;

import 'package:brotli/brotli.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:html/dom.dart' show Document;
//code-splitting
import 'screens/chapterScreen.dart';
import 'util/fimHttp.dart';
import 'util/sharedPrefs.dart';

class AppDrawer extends HookWidget {
  final AppDrawerData data;
  final void Function() refresh;
  AppDrawer({this.data, this.refresh});

  void logout() async {
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
                      if (data.avatarUrl != null)
                        Image.network(data.avatarUrl, width: 90, height: 90),
                      Text(data.username ?? "not logged in"),
                    ],
                  ),
                ),
                Spacer(),
                data.loggedIn
                    ? OutlinedButton(
                        child: Text("log out"),
                        onPressed: logout,
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
            arguments: ChapterScreenArgs("395988", "1"),
          ),
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
  final List<Bookshelf> shelves;

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
              (s) => Bookshelf.fromMap(s),
            )
            .toList());
  }
}

class Bookshelf {
  final String name, icon, style;
  final int numUnread, id;

  Bookshelf({this.name, this.numUnread, this.icon, this.style, this.id});

  static Bookshelf fromMap(s) {
    return Bookshelf(
        name: s["name"],
        icon: s["iconHtml"],
        id: int.parse(s["url"].split("/")[2]),
        numUnread: int.parse(s["numUnread"].toString()),
        style: s["style"]);
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
              final err = await login(username, password, rememberMe);
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

  Future<String> login(String username, String password, bool rememberMe) async {
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
