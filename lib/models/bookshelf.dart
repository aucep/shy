import 'package:flutter/widgets.dart' show Color;
import 'package:html/dom.dart';
//code-splitting
import '../util/fimHttp.dart';

class Bookshelf {
  String name;
  final BookshelfIcon icon;
  final String id;
  //for drawer library
  final int numUnread;
  //for add to shelves modal
  final String description;
  int stories;
  bool added;

  Bookshelf({
    this.name,
    this.description,
    this.numUnread,
    this.icon,
    this.id,
    this.stories,
    this.added,
  });

  static Bookshelf fromMap(s) {
    final icon = Element.html(s['iconHtml']);

    return Bookshelf(
      name: s['name'],
      icon: BookshelfIcon.fromIcon(icon),
      id: s['url'].split('/')[2],
      numUnread: int.parse(s['numUnread'].toString()),
    );
  }

  static List<Bookshelf> fromPopupList(Element doc) {
    final shelves = doc.querySelector('#bookshelves-popup-list');
    return shelves.children.map((s) => Bookshelf.fromPopupItem(s)).toList();
  }

  static Bookshelf fromPopupItem(Element doc) {
    final item = doc.children.first;
    final name = item.querySelector('.name');
    final stories = item.querySelector('.num_stories');
    final icon = item.querySelector('.bookshelf-icon-element');
    return Bookshelf(
      name: name.innerHtml,
      description: doc.attributes['title'],
      id: item.attributes['data-bookshelf'],
      stories: int.parse(stories.innerHtml),
      added: item.attributes['data-added'] == '1',
      icon: BookshelfIcon.fromIcon(icon),
    );
  }

  //actions
  Future<String> addStory(String storyId) async {
    final resp = await http.ajaxRequest('bookshelves/$id/items', 'POST', body: {'story': storyId});
    final json = resp.json;
    if (json.containsKey('error')) return json['error'];

    stories = json['num_added'];
    added = json['added'];
    return null;
  }

  Future<String> removeStory(String storyId) async {
    final resp = await http.ajaxRequest('bookshelves/$id/items/$storyId', 'DELETE');
    final json = resp.json;
    if (json.containsKey('error')) return json['error'];

    stories = json['num_added'];
    added = json['added'];
    return null;
  }
}

class BookshelfIcon {
  final String icon;
  final bool isPony;
  final Color color;
  const BookshelfIcon({this.icon, this.isPony, this.color});

  static BookshelfIcon fromIcon(Element icon) {
    final isPony = icon.attributes['data-icon-type'] == 'pony-emoji';
    return BookshelfIcon(
      icon: isPony ? icon.text.trim() : icon.className.split(' ')[0],
      isPony: isPony,
      color: hexToColor(icon.attributes['style']
          .replaceFirst(isPony ? 'font-family:PonyEmoji; color:#' : 'color:#', '')),
    );
  }

  //https://stackoverflow.com/questions/50381968/flutter-dart-convert-hex-color-string-to-color
  static Color hexToColor(String code) {
    return new Color(int.parse(code.substring(0, 6), radix: 16) + 0xFF000000);
  }
}
