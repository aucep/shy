import 'package:shared_preferences/shared_preferences.dart';

//this is totally taken from that one dev.to article
//https://dev.to/simonpham/using-sharedpreferences-in-flutter-effortlessly-3e29
//thanks, effort levels dropping
class SharedPrefs {
  static SharedPreferences _sp;
  init() async => _sp ??= await SharedPreferences.getInstance();

  String get sessionToken => _sp.getString(keySessionToken) ?? "";
  set sessionToken(String v) => _sp.setString(keySessionToken, v);

  String get signingKey => _sp.getString(keySigningKey) ?? "";
  set signingKey(String v) => _sp.setString(keySigningKey, v);

  clear() {
    _sp.clear();
  }
}

final sharedPrefs = SharedPrefs();

//##key names##
//auth
const keySessionToken = "session_token";
const keySigningKey = "signing_key";
//