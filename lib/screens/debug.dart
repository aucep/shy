import 'package:flutter/material.dart';

import '../appDrawer.dart';

class DebugArgs {
  final Uri uri;
  const DebugArgs(this.uri);
}

class DebugScreen extends StatelessWidget {
  final DebugArgs args;
  const DebugScreen(this.args);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Debug')),
      body: Text('host: ${args.uri.host} & path: ${args.uri.pathSegments}'),
      drawer: AppDrawer(data: AppDrawerData()),
    );
  }
}
