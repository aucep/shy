import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
//Code-splitting
import 'util/sharedPrefs.dart';
import 'screens/home.dart';
import 'screens/chapter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.init();
  runApp(ProviderScope(
      child: MaterialApp(
    title: "fimfic",
    initialRoute: "/",
    onGenerateRoute: (RouteSettings settings) {
      var routes = <String, WidgetBuilder>{
        "/": (_) => HomeScreen(),
        "/chapter": (_) => ChapterScreen(settings.arguments),
      };
      WidgetBuilder builder = routes[settings.name];
      return MaterialPageRoute(builder: (ctx) => builder(ctx), settings: settings);
    },
    theme: ThemeData.light(),
    debugShowCheckedModeBanner: false,
  )));
}
