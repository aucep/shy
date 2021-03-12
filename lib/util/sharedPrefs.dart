import 'package:shared_preferences/shared_preferences.dart';

//this is totally taken from that one dev.to article
//https://dev.to/simonpham/using-sharedpreferences-in-flutter-effortlessly-3e29
//thanks, effort levels dropping
class SharedPrefs {
  static SharedPreferences _sp;
  init() async => _sp ??= await SharedPreferences.getInstance();

  //auth

  String get sessionToken => _sp.getString(keySessionToken) ?? "";
  set sessionToken(String v) => _sp.setString(keySessionToken, v);

  String get signingKey => _sp.getString(keySigningKey) ?? "";
  set signingKey(String v) => _sp.setString(keySigningKey, v);

  //drawer

  // shelves
  bool get showShelves => _sp.getBool(keyShowShelves) ?? true;
  set showShelves(bool v) => _sp.setBool(keyShowShelves, v);

  //  hiding shelves
  bool get hidableShelves => _sp.getBool(keyHidableShelves) ?? true;
  set hidableShelves(bool v) => _sp.setBool(keyHidableShelves, v);

  //   
  String get shelfHidePrefix => _sp.getString(keyShelfHidePrefix) ?? "#";
  set shelfHidePrefix(String v) => _sp.setString(keyShelfHidePrefix, v);

  bool get shelfTrimHidePrefix => _sp.getBool(keyShelfTrimHidePrefix) ?? true;
  set shelfTrimHidePrefix(bool v) => _sp.setBool(keyShelfTrimHidePrefix, v);

  clear() {
    _sp.clear();
  }
}

final sharedPrefs = SharedPrefs();

//##key names## i should probably just merge this into SharedPrefs
//auth
const keySessionToken = "session_token";
const keySigningKey = "signing_key";
//drawer
const keyShowShelves = "show_shelves";
const keyHidableShelves = "hidable_shelves";
const keyShelfHidePrefix = "shelf_hide_prefix";
const keyShelfTrimHidePrefix = "shelf_trim_hide_prefix";