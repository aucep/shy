import 'package:html/dom.dart' show Document;

//code-splitting
import '../models/storyCard.dart';
import '../appDrawer.dart';
import 'pageData.dart';

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

  static PageData<Home> page(Document doc) {
    return PageData<Home>(drawer: AppDrawerData.fromDoc(doc), body: Home.fromHome(doc));
  }
}
