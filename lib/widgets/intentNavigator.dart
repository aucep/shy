import 'package:flutter/material.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

//code-splitting
import '../screens/chapter.dart';
import '../screens/story.dart';
import '../util/nav.dart';

class IntentNavigator extends StatelessWidget {
  final Widget child;
  const IntentNavigator({this.child});

  @override
  Widget build(BuildContext context) {
    navigate(Uri uri) {
      if (uri.host != 'www.fimfiction.net') return;

      final push = Navigator.of(context).pushNamedIfNew;
      final path = uri.pathSegments;

      if (path.isEmpty)
        push('/');
      else {
        switch (path[0]) {
          case 'story':
            if (path.length >= 2 && path.length < 4)
              push('/story', args: StoryArgs(path[1]));
            else if (path.length >= 4 && path.length < 6)
              push('/chapter',
                  args: ChapterArgs(
                    storyId: path[1],
                    chapterNum: int.tryParse(path[2]) ?? 1,
                  ));
            break;
          //more to come
        }
      }
    }

    ReceiveSharingIntent.getTextStreamAsUri().listen(navigate);
    ReceiveSharingIntent.getInitialTextAsUri().then(navigate);
    return child;
  }
}
