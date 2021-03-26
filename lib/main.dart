import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
//Code-splitting
import 'util/sharedPrefs.dart';
import 'screens/home.dart';
import 'screens/chapter.dart';
import 'screens/story.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sharedPrefs.init();
  runApp(ProviderScope(
      child: MaterialApp(
    title: 'fimfic',
    initialRoute: '/story',
    onGenerateRoute: (RouteSettings settings) {
      var routes = <String, WidgetBuilder>{
        '/': (_) => HomeScreen(),
        '/chapter': (_) => ChapterScreen(
            settings.arguments ?? ChapterScreenArgs(chapterNum: 1, storyId: '395988')),
        '/story': (_) => StoryScreen(settings.arguments ?? StoryArgs('395988')),
      };
      WidgetBuilder builder = routes[settings.name];
      return MaterialPageRoute(builder: (ctx) => builder(ctx), settings: settings);
    },
    theme: ThemeData(),
    debugShowCheckedModeBanner: false,
  )));
}
