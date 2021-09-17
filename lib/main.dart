//flutter
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:adaptive_theme/adaptive_theme.dart';

//local
import 'screens/index.dart';
import 'widgets/intentNavigator.dart';
import 'util/sharedPrefs.dart';

void main() async {
  //everyone puts this here so... yeah
  WidgetsFlutterBinding.ensureInitialized();
  //now everyone has the same storage instance
  await sharedPrefs.init();
  //get previous theme
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  //finally, we're at the app
  runApp(ShyApp(prevThemeMode: savedThemeMode));
}

class ShyApp extends StatelessWidget {
  final AdaptiveThemeMode prevThemeMode;
  const ShyApp({this.prevThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light(),
      dark: ThemeData.dark(),
      initial: prevThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'shy',
        theme: theme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          final routes = <String, WidgetBuilder>{
            '/': (_) => HomeScreen(),
            '/chapter': (_) =>
                ChapterScreen(settings.arguments ?? ChapterArgs(chapterNum: 1, storyId: '395988')),
            '/story': (_) => StoryScreen(settings.arguments ?? StoryArgs('395988')),
          };
          WidgetBuilder builder = routes[settings.name];
          return MaterialPageRoute(
            builder: (ctx) => ScrollConfiguration(
              behavior: ScrollConfiguration.of(ctx)
                  .copyWith(dragDevices: PointerDeviceKind.values.toSet()),
              child: IntentNavigator(child: builder(ctx)),
            ),
            settings: settings,
          );
        },
      ),
    );
  }
}
