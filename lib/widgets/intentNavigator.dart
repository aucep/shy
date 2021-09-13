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
      if (uri.host == 'www.fimfiction.net')
        Navigator.of(context).pushNamedIfNew('/debug', args: DebugArgs(uri));
      if (uri.host.isNotEmpty)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('host: "${uri.host}", path: ${uri.pathSegments}')));
    }

    ReceiveSharingIntent.getTextStreamAsUri().listen(navigate);
    ReceiveSharingIntent.getInitialTextAsUri().then(navigate);
    return child;
  }
}
