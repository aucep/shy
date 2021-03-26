import 'dart:ui';

import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart' hide Element, Page;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:html/dom.dart' show Document, Element;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:html/parser.dart' show parse;
import 'package:full_screen_image/full_screen_image.dart';

//code-splitting
import '../appDrawer.dart';
import '../models/pageData.dart';
import '../util/nav.dart';
import '../util/fimHttp.dart';
import '../util/sharedPrefs.dart';
import 'story.dart';

class HomeScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var page = useState(Page<Home>());
    final body = page.value?.body;

    refresh() async {
      Document doc;
      final start = DateTime.now();
      if (kIsWeb) {
        doc = parse(await rootBundle.loadString('saved_html/home.html'));
      } else {
        doc = await fetchDoc('');
      }
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
                    StoryCardList(body.featured, refresh),
                    StoryCardList(body.newly, refresh),
                    StoryCardList(body.updated, refresh),
                    StoryCardList(body.popular, refresh),
                  ],
                ),
          drawer: AppDrawer(data: page.value.drawer, refresh: refresh),
        ));
  }
}

class Home {
  final List<StoryCardData> popular;
  final List<StoryCardData> newly;
  final List<StoryCardData> updated;
  final List<StoryCardData> featured;

  Home({this.popular, this.newly, this.updated, this.featured});

  static Home fromHome(Document doc) {
    final popularList = doc.querySelectorAll("#popular_stories.story-card-list .story-card");
    final newList = doc.querySelectorAll("#new_stories.story-card-list .story-card");
    final updatedList = doc.querySelectorAll("#latest_stories.story-card-list .story-card");
    final featuredList = doc.querySelectorAll(".featured_box > .right > .featured_story");
    return Home(
      popular: popularList.map((c) => StoryCardData.fromCard(c)).toList(),
      newly: newList.map((c) => StoryCardData.fromCard(c)).toList(),
      updated: updatedList.map((c) => StoryCardData.fromCard(c)).toList(),
      featured: featuredList.map((c) => StoryCardData.fromCard(c)).toList(),
    );
  }

  static Page<Home> page(Document doc) {
    return Page<Home>(drawer: AppDrawerData.fromDoc(doc), body: Home.fromHome(doc));
  }
}

class StoryCard extends StatelessWidget {
  final StoryCardData data;
  StoryCard({this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      elevation: 3,
      child: Material(
        child: InkWell(
          onTap: () =>
              Navigator.of(context).pushNamedIfNew('/story', args: StoryArgs(data.storyId)),
          child: Container(
            margin: EdgeInsets.all(8),
            width: 400,
            child: IntrinsicHeight(
              child: Column(
                children: [
                  Row(children: [
                    ContentRating(data.contentRating),
                    Container(width: 5),
                    Flexible(
                      child: Text(
                        data.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ]),
                  Divider(),
                  Expanded(
                    child: Row(
                      children: [
                        data.imageUrl.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(3, 0, 8, 0),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxHeight: 100, maxWidth: 100),
                                  child: ExpandableImage(data.imageUrl),
                                ),
                              )
                            : Container(),
                        Expanded(child: Text(data.description)),
                      ],
                    ),
                  ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InfoChip(data.authorName),
                      IntrinsicWidth(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InfoChip(data.wordcount),
                            InfoChip(data.viewcount),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StoryCardData {
  final String title,
      description,
      authorName,
      imageUrl,
      wordcount,
      viewcount,
      likes,
      dislikes,
      rating,
      contentRating;
  final String authorId, storyId;

  StoryCardData({
    this.title,
    this.authorName,
    this.authorId,
    this.description,
    this.imageUrl,
    this.wordcount,
    this.viewcount,
    this.likes,
    this.dislikes,
    this.rating,
    this.contentRating,
    this.storyId,
  });

  static StoryCardData fromCard(Element card) {
    final bool c = card.attributes["class"] == "story-card";
    final storyLink = card.querySelector(c ? ".story_link" : ".title > a");
    final image = card.querySelector(".story_image");
    final desc = card.querySelector(c ? ".short_description" : ".description");
    final authorLink =
        card.querySelector(c ? ".story-card__author" : ".author") ?? card.querySelector(".author");
    final info = card.querySelector(c ? ".story-card__info" : ".info");
    final ratingBar = c ? card.querySelector(".rating-bar") : null;
    final contentRatingSpan = card.querySelector(".${c ? "story-card__" : ""}title > span");

    return StoryCardData(
      title: storyLink.innerHtml,
      storyId: storyLink.attributes["href"].split("/")[2],
      imageUrl: image != null ? image.attributes["src"] ?? image.attributes["data-src"] : "",
      description: (c ? desc.nodes[desc.nodes.length == 1 ? 0 : 2] : desc.nodes.last).text.trim(),
      authorName: authorLink.innerHtml,
      authorId: authorLink.attributes["href"].split("/")[2],
      wordcount: info.nodes[c ? 4 : 3].text.trim(),
      viewcount: (c ? info.nodes.last : info.nodes[5]).text.trim(),
      likes: c
          ? info.nodes.length == 14
              ? info.nodes[7].text.trim()
              : ""
          : info.nodes[9].text.trim(),
      dislikes: c
          ? info.nodes.length == 14
              ? info.nodes[10].text.trim()
              : ""
          : info.nodes.last.text.trim(),
      rating: ratingBar != null
          ? ratingBar.firstChild.attributes["style"].replaceFirst("width:", "")
          : "",
      contentRating: contentRatingSpan.innerHtml,
    );
  }
}

class InfoChip extends StatelessWidget {
  final label;
  InfoChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: label is Widget ? label : Text('$label'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      labelPadding: EdgeInsets.zero,
    );
  }
}

class IconChip extends StatelessWidget {
  final label;
  final IconData icon;
  final double padding;
  IconChip(this.icon, this.label, {this.padding});

  @override
  Widget build(BuildContext context) {
    return Badge(
      toAnimate: false,
      badgeContent: IntrinsicWidth(
          child: Row(children: [FaIcon(icon, size: 12), label is Widget ? label : Text('$label')])),
      shape: BadgeShape.square,
      badgeColor: Theme.of(context).chipTheme.backgroundColor,
      borderRadius: BorderRadius.circular(3),
      elevation: 0,
      padding: Pad(all: padding ?? 4),
    );
  }
}

class StoryCardList extends StatelessWidget {
  final List<StoryCardData> data;
  final refresh;
  StoryCardList(this.data, this.refresh);
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refresh,
      child: Scrollbar(
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
          children: data.map((c) => StoryCard(data: c)).toList(),
        ),
      ),
    );
  }
}

class ContentRating extends StatelessWidget {
  final String contentRating;
  ContentRating(this.contentRating);

  @override
  Widget build(BuildContext context) {
    return Chip(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      label: Text(contentRating),
      labelPadding: EdgeInsets.symmetric(horizontal: 5),
      backgroundColor: contentRating == 'E'
          ? Color(0xff78ac40)
          : contentRating == 'T'
              ? Color(0xffffb400)
              : Color(0xffc03d2f),
    );
  }
}

class ExpandableImage extends StatelessWidget {
  final String url;
  ExpandableImage(this.url);

  @override
  Widget build(BuildContext context) {
    return sharedPrefs.showImages ? Container(
      child: FullScreenWidget(
        child: Hero(tag: url, child: Image.network(url, fit: BoxFit.contain)),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        backgroundIsTransparent: true,
      ),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
    ):Container();
  }
}
