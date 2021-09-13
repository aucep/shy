import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

//code-splitting
import '../screens/story.dart';

class IntentNavigator extends StatelessWidget {
  final Widget child;
  const IntentNavigator({this.child});

  @override
  Widget build(BuildContext context) {
    ReceiveSharingIntent.getTextStreamAsUri().listen((Uri uri) {
      Navigator.of(context).pushNamed('/story', arguments: StoryArgs('22178'));
    });
    return child;
  }
}
