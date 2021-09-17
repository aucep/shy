//flutter
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

//local
import '../appDrawer.dart';
import '../models/story.dart';
import '../models/bookshelf.dart';
import '../util/sharedPrefs.dart';
import '../util/showSnackbar.dart';

class AddToShelvesModal extends HookWidget {
  final StoryData story;
  final void Function(String) showSnackbarFromParent;
  AddToShelvesModal(this.story, this.showSnackbarFromParent);

  final GlobalKey hiddenShelvesKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final shelfData = useState(<BookshelfData>[]);
    final error = useState('');
    final loading = useState(true);
    final shelves = shelfData.value;

    refresh() async {
      loading.value = true;
      final data = await story.getShelves();
      if (data.runtimeType == String) {
        error.value = data;
      } else {
        shelfData.value = data;
      }
      loading.value = false;
    }

    useEffect(() {
      refresh();
      return null;
    }, const []);

    if (!loading.value) {
      if (error.value.isNotEmpty) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pop();
          showSnackbarFromParent(error.value);
        });
        return Container();
      }
      var hiddenShelves = <BookshelfData>[];
      final hidableShelves = sharedPrefs.hidableShelves;
      if (hidableShelves) {
        hiddenShelves = shelves.extractHidden();
      }

      //shelves to tiles
      List<Widget> shelfTiles =
          shelves.map<Widget>((s) => ShelfTile(shelf: s, storyId: story.id)).toList();

      //add (hidden shelves->tiles)
      if (hidableShelves && hiddenShelves.length > 0) {
        final hiderTile = ExpansionTile(
          leading: FaIcon(FontAwesomeIcons.book),
          title: Text('Hidden shelves'),
          children: ListTile.divideTiles(
            context: context,
            tiles: hiddenShelves.map((s) => ShelfTile(shelf: s, storyId: story.id)),
          ).toList(),
          key: hiddenShelvesKey,
          onExpansionChanged: (v) {
            if (v) _scrollIntoView(hiddenShelvesKey);
          },
        );
        shelfTiles.add(hiderTile);
      }

      return ListView(children: ListTile.divideTiles(context: context, tiles: shelfTiles).toList());
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  _scrollIntoView(GlobalKey key) async {
    final keyContext = key.currentContext;
    if (keyContext != null) {
      await Future.delayed(Duration(milliseconds: 220));
      Scrollable.ensureVisible(keyContext,
          duration: Duration(milliseconds: 200),
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
    }
  }
}

class ShelfTile extends HookWidget {
  final BookshelfData shelf;
  final String storyId;
  ShelfTile({this.shelf, this.storyId});

  @override
  Widget build(BuildContext context) {
    final loading = useState(false);
    return ListTile(
        leading: ShelfIcon(shelf.icon),
        trailing: loading.value
            ? CircularProgressIndicator()
            : Icon(shelf.added ? Icons.check_box : Icons.check_box_outline_blank),
        title: Text(shelf.name),
        enabled: !loading.value,
        onTap: () async {
          loading.value = true;
          String err;
          if (shelf.added) {
            err = await shelf.removeStory(storyId);
          } else {
            err = await shelf.addStory(storyId);
          }
          if (err != null) {
            showSnackbar(context, 'err: $err');
          }
          loading.value = false;
        });
  }
}
