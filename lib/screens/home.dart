//flutter
import 'package:flutter/material.dart' hide Element, Page;

import 'package:flutter_hooks/flutter_hooks.dart';

//local
import '../appDrawer.dart';
import '../widgets/storyCard.dart';
import '../models/pageData.dart';
import '../models/home.dart';
import '../util/fimHttp.dart';

class HomeScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var page = useState(PageData<Home>());
    final body = page.value?.body;

    refresh() async {
      final start = DateTime.now();
      final doc = await fetchDoc('');
      var elapsed = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      print('doc after $elapsed ms');
      page.value = Home.page(doc);
      elapsed = DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      print('parsed after $elapsed ms');
    }

    useEffect(() {
      refresh();
      return;
    }, const []);
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Home"),
            bottom: TabBar(
              tabs: [
                Tab(text: "Featured"),
                Tab(text: "New"),
                Tab(text: "Updated"),
                Tab(text: "Popular"),
              ],
            ),
          ),
          body: body == null
              ? Center(child: CircularProgressIndicator())
              : TabBarView(
                  children: [
                    StoryCardList(data: body.featured, refresh: refresh),
                    StoryCardList(data: body.newlyAdded, refresh: refresh),
                    StoryCardList(data: body.updated, refresh: refresh),
                    StoryCardList(data: body.popular, refresh: refresh),
                  ],
                ),
          drawer: AppDrawer(data: page.value.drawer, refresh: refresh),
        ));
  }
}
