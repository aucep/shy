import 'package:flutter/material.dart';
//Code-splitting
import 'util/sharedPrefs.dart';
import 'screens/home.dart';
import 'screens/chapter.dart';
import 'screens/story.dart';

void main() async {
  //everyone puts this here so... yeah
  WidgetsFlutterBinding.ensureInitialized();
  //now everyone has the same storage instance
  await sharedPrefs.init();
  //finally, we're at the app
  runApp(MaterialApp(
    title: 'shy',
    initialRoute: '/',
    onGenerateRoute: (RouteSettings settings) {
      var routes = <String, WidgetBuilder>{
        '/': (_) => HomeScreen(),
        '/chapter': (_) =>
            ChapterScreen(settings.arguments ?? ChapterArgs(chapterNum: 1, storyId: '395988')),
        '/story': (_) => StoryScreen(settings.arguments ?? StoryArgs('395988')),
      };
      WidgetBuilder builder = routes[settings.name];
      return MaterialPageRoute(builder: (ctx) => builder(ctx), settings: settings);
    },
    theme: ThemeData(),
    debugShowCheckedModeBanner: false,
  ));
}
