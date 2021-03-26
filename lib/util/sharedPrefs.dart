import 'package:get_storage/get_storage.dart';

//this is totally taken from that one dev.to article
//https://dev.to/simonpham/using-sharedpreferences-in-flutter-effortlessly-3e29
//thanks, effort levels dropping
class SharedPrefs {
  static GetStorage _sp;
  init() async {
    await GetStorage.init();
    _sp ??= GetStorage();
  }

  //auth

  String get sessionToken => _sp.read(keySessionToken) ?? "";
  set sessionToken(String v) => _sp.write(keySessionToken, v);

  String get signingKey => _sp.read(keySigningKey) ?? "";
  set signingKey(String v) => _sp.write(keySigningKey, v);

  //drawer

  // shelves
  bool get showShelves => _sp.read(keyShowShelves) ?? true;
  set showShelves(bool v) => _sp.write(keyShowShelves, v);

  //  hiding shelves
  bool get hidableShelves => _sp.read(keyHidableShelves) ?? true;
  set hidableShelves(bool v) => _sp.write(keyHidableShelves, v);

  String get shelfHidePrefix => _sp.read(keyShelfHidePrefix) ?? "#";
  set shelfHidePrefix(String v) => _sp.write(keyShelfHidePrefix, v);

  bool get shelfTrimHidePrefix => _sp.read(keyShelfTrimHidePrefix) ?? true;
  set shelfTrimHidePrefix(bool v) => _sp.write(keyShelfTrimHidePrefix, v);

  //global life-savers
  bool get showImages => _sp.read(keyShowImages) ?? true;
  set showImages(bool v) => _sp.write(keyShowImages, v);

  clear() {
    _sp.erase();
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
//global
const keyShowImages = "show_images";
