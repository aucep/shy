import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

//code-splitting
import '../screens/debug.dart';
import '../util/nav.dart';

class IntentNavigator extends StatelessWidget {
  final Widget child;
  const IntentNavigator({this.child});

  @override
  Widget build(BuildContext context) {
    navigate(Uri uri) {
      if (uri.host == "www.fimfiction.com" || uri.host == "fimfiction.com")
        Navigator.of(context).pushNamedIfNew('/debug', args: DebugArgs(uri));
    }

    ReceiveSharingIntent.getTextStreamAsUri().listen(navigate);
    ReceiveSharingIntent.getInitialTextAsUri().then(navigate);
    return child;
  }
}
