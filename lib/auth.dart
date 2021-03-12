import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//todo: figure out what do to with this file

final authProvider = ChangeNotifierProvider((ref) => AuthNotifier());

class AuthNotifier extends ChangeNotifier {
  String sessionToken = "";
  String signingKey = "";

  Future<String> login(String username, String password, bool rememberMe) async {
    final resp = await http.post("https://www.fimfiction.net/ajax/login", body: {
      "username": username,
      "password": password,
      "keep_logged_in": rememberMe.toString(),
    });
    final body = jsonDecode(resp.body);
    if (body.containsKey("error")) {
      print(body["error"]);
      return body["error"];
    }
    final setCookie = resp.headers["set-cookie"];
    match(s) => RegExp("(?<=$s=(?!.*$s)).+?(?=\;)").firstMatch(setCookie).group(0);
    this.sessionToken = match("session_token");
    this.signingKey = body["signing_key"];
    store();
    notifyListeners();
    return "";
  }

  void logout() {
    //http.post("https://www.fimfiction.net/ajax/logout");
    sessionToken = "";
    signingKey = "";
    notifyListeners();
  }

  void load() async {
    final previousToken = this.sessionToken;
    final previousKey = this.signingKey;
    print("getting: ${DateTime.now().millisecondsSinceEpoch / 10}");
    final box = await SharedPreferences.getInstance();
    print("got: ${DateTime.now().millisecondsSinceEpoch / 10}");
    if (box.containsKey("session_token") && box.containsKey("signing_key")) {
      this.sessionToken = box.get("session_token");
      this.signingKey = box.get("signing_key");
    } else {
      this.sessionToken = "";
      this.signingKey = "";
    }
    if (previousToken != this.sessionToken || previousKey != this.signingKey) notifyListeners();
  }

  void store() async {
    final box = await SharedPreferences.getInstance();
    box.setString("session_token", this.sessionToken);
    box.setString("signing_key", this.signingKey);
  }
}
