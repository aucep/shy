//dart
import 'package:html/dom.dart';

//flutter
import 'package:flutter/widgets.dart' show Color;

//local
import '../util/fimHttp.dart';

class UserData {
  final String name, id, imageUrl, description;
  final bool online;
  final String lastOnline, lastOnlineVerbose;
  final Color color;
  bool following;
  UserData({
    this.name,
    this.id,
    this.imageUrl,
    this.description,
    this.online,
    this.lastOnline,
    this.lastOnlineVerbose,
    this.following,
    this.color,
  });

  ///from infocard element (response from api)
  static UserData fromInfoCard(Element doc) {
    //lower ancestor for further searches
    final cardContent = doc.querySelector('.card-content');
    //userLink -> name
    final userLink = cardContent.querySelector('[data-no-user-popup]');
    //image -> imageUrl
    final image = doc.querySelector('.avatar');
    //onlineStatus -> online, lastOnline, lastOnlineVerbose
    final onlineStatus = cardContent.querySelector('.online-status');
    final online = onlineStatus.className.split(' ').contains('online');
    final lastOnline = online ? null : onlineStatus.children.first;
    //watchButton -> id, following
    final watchButton = doc.querySelector('.button_user_watch');
    //info -> description
    final info = cardContent.querySelector('.info');
    //topInfo ->
    final topInfo = doc.querySelector('.top-info');
    final rgb = topInfo.attributes['style']
        .replaceFirst('background-color:rgb(', '')
        .replaceFirst(');', '')
        .split(',')
        .map((s) => int.parse(s))
        .toList();

    return UserData(
        name: userLink.innerHtml,
        imageUrl: image.attributes['data-src'],
        online: online,
        lastOnline: online ? 'now' : lastOnline.innerHtml,
        lastOnlineVerbose: online ? 'now' : lastOnline.attributes['title'],
        id: userLink.attributes['href'].split('/')[2],
        following: watchButton == null ? null : watchButton.attributes['data-watch'] == 'true',
        description: info.innerHtml,
        color: Color.fromARGB(
          255,
          rgb[0],
          rgb[1],
          rgb[2],
        ));
  }

  //action but mostly a constructor
  static getInfoCard(String id) async {
    print('getting infocard for user $id');
    final resp = await http.ajaxRequest(
      'users/$id/infocard',
      'POST',
      signSet: false,
    );

    if (resp.is404 ?? false) {
      return '404';
    }

    final json = resp.json;
    if (json.containsKey('error')) {
      final err = json['error'];
      print(err);
      return err;
    }

    return UserData.fromInfoCard(Element.html(json['content']));
  }

  //actions

}
