//dart
import 'dart:convert' show jsonDecode;

import 'package:html/dom.dart' show Document;

//flutter
import 'package:flutter/material.dart';

import 'package:badges/badges.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';

//local
import 'screens/chapter.dart';
import 'widgets/userModal.dart';
import 'models/bookshelf.dart';
import 'util/index.dart';

class AppDrawer extends HookWidget {
  final AppDrawerData data;
  final void Function() refresh;
  AppDrawer({this.data, this.refresh});

  /*void _logout() async {
    await http.ajaxRequest('logout', 'POST');
    sharedPrefs.sessionToken = '';
    sharedPrefs.signingKey = '';
    refresh();
  }*/

  @override
  Widget build(BuildContext context) {
    final data = this.data ??
        AppDrawerData(
          loggedIn: false,
          avatarUrl: '',
        );
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: data.bgColor),
            child: Row(
              children: [
                Center(
                  child: Column(
                    children: data.loggedIn
                        ? [
                            if (sharedPrefs.showImages && data.avatarUrl != null)
                              InkWell(
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  builder: (_) =>
                                      UserModal(data.userId, (msg) => showSnackbar(context, msg)),
                                  enableDrag: true,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: kElevationToShadow[2],
                                    border: Border.all(color: Colors.white, width: 3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  foregroundDecoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 3),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Image.network(data.avatarUrl, height: 96),
                                ),
                              ),
                            Text(
                              data.username,
                              style: Theme.of(context).textTheme.headline5.copyWith(
                                    color: data.bgColor.computeLuminance() > 0.5
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                            ),
                          ]
                        : [Text('not logged in')],
                  ),
                ),
                if (!data.loggedIn) Spacer(),
                if (!data.loggedIn)
                  OutlinedButton(
                    child: Text('login'),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => LoginDialog(refresh: refresh),
                    ),
                  ),
              ],
            ),
          ),
          DrawerRouteItem(title: 'Stories', route: '/'),
          DrawerRouteItem(title: 'News', route: '/'),
          DrawerRouteItem(
            title: 'Chapter',
            route: '/chapter',
            arguments: ChapterArgs(storyId: '395988', chapterNum: 1),
          ),
          if (data?.shelves != null)
            if (data.shelves.length > 0) BookshelvesTile(shelves: data.shelves),
          ThemeTile(),
          //tree shaking hack/fix
          Opacity(
            opacity: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FaIcon(FontAwesomeIcons.solidBookmark),
                FaIcon(FontAwesomeIcons.youtube),
                FaIcon(FontAwesomeIcons.addressCard)
              ],
            ),
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
  final String username, avatarUrl, userId;
  final Color bgColor;
  final List<BookshelfData> shelves;

  AppDrawerData(
      {this.loggedIn, this.username, this.avatarUrl, this.bgColor, this.userId, this.shelves});

  static AppDrawerData fromDoc(Document doc) {
    final Map<String, dynamic> htmlConfig = jsonDecode(
        doc.querySelector('.navigation-drawer-container').attributes['data-html-config']);

    final Map<String, dynamic> user = htmlConfig['user'];
    final List<dynamic> shelves = htmlConfig['bookshelves'];
    final rgb = user['backgroundColor']
        .replaceFirst('rgb(', '')
        .replaceFirst(')', '')
        .split(',')
        .map((s) => int.parse(s))
        .toList();
    return AppDrawerData(
        loggedIn: htmlConfig['loggedIn'],
        username: user['name'],
        avatarUrl: user['avatar'],
        userId: user['url'].split('/')[2],
        bgColor: Color.fromARGB(
          255,
          rgb[0],
          rgb[1],
          rgb[2],
        ),
        shelves: shelves
            .map(
              (s) => BookshelfData.fromMap(s),
            )
            .toList());
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
      title: Text('Log in'),
      content: SingleChildScrollView(
        padding: Pad(horizontal: 8),
        child: Form(
          key: _formKey,
          child: IntrinsicHeight(
            child: Column(
              children: [
                TextFormField(
                    decoration:
                        InputDecoration(labelText: 'Username:', icon: Icon(Icons.account_circle)),
                    validator: (v) {
                      if (v.isEmpty) return 'Must have username';
                      username = v;
                      return null;
                    }),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Password:', icon: Icon(Icons.lock)),
                    validator: (v) {
                      if (v.isEmpty) return 'Must have password';
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
                        title: Text('Remember me'),
                        onChanged: state.didChange,
                        value: state.value)),
              ],
            ),
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          child: Text('Submit'),
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              final err = await _login(username, password, rememberMe);
              //golang, baby
              if (err != null) {
                showSnackbar(context, 'error: $err');
              } else {
                Navigator.pop(context);
                refresh();
              }
            }
          },
        ),
      ],
    );
  }

  Future<String> _login(String username, String password, bool rememberMe) async {
    final resp = await http.ajaxRequest('login', 'POST', body: {
      'username': username,
      'password': password,
      'keep_logged_in': rememberMe.toString(),
    });
    final json = resp.json;

    if (json.containsKey('error')) {
      final err = json['error'];
      print(err);
      return err;
    }
    match(s) => RegExp('(?<=$s=(?!.*$s)).+?(?=\;)').firstMatch(resp.setCookie).group(0);
    sharedPrefs.sessionToken = match('session_token');
    sharedPrefs.signingKey = json['signing_key'];
    return null;
  }
}

class BookshelvesTile extends StatelessWidget {
  final List<BookshelfData> shelves;
  BookshelvesTile({this.shelves});

  final GlobalKey libraryKey = GlobalKey();
  final GlobalKey hiddenShelvesKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    //hide shelves?
    List<BookshelfData> hiddenShelves;
    final hidableShelves = sharedPrefs.hidableShelves;
    if (hidableShelves) {
      hiddenShelves = shelves.extractHidden();
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
      title: Text('Library'),
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
                child: ShelfIcon(s.icon),
                badgeContent: Text('${s.numUnread}', style: TextStyle(fontSize: 11)),
                padding: Pad(all: 3),
              )
            : ShelfIcon(s.icon),
        title: Text(s.name),
        onTap: () {
          print(s.icon.icon);
          showSnackbar(context, 'bookshelf screen not implemented yet');
        });
  }
}

class ShelfIcon extends StatelessWidget {
  final BookshelfIcon icon;
  ShelfIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return icon.isPony
        ? Text(icon.icon, style: TextStyle(fontSize: 20, color: icon.color))
        : FaIcon(icons[icon.icon.trim()] ?? FontAwesomeIcons.airbnb, color: icon.color);
  }
}

class ThemeTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = AdaptiveTheme.of(context);
    return ListTile(
      title: Text('theme: ' + theme.mode.name),
      onTap: () => theme.toggleThemeMode(),
    );
  }
}
