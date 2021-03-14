import 'package:flutter/widgets.dart';

//thanks jglatre @ stackoverflow
extension NavigatorStateExtension on NavigatorState {
  void pushNamedIfNew(String routeName, {Object args}) {
    if (!isCurrent(routeName, args: args)) {
      pushNamed(routeName, arguments: args);
    }
  }

  bool isCurrent(String routeName, {Object args}) {
    bool isCurrent = false;
    popUntil((route) {
      if (route.settings.name == routeName && route.settings.arguments == args) {
        isCurrent = true;
      }
      return true;
    });
    return isCurrent;
  }
}
