import 'package:html/dom.dart' show Document;

//code-splitting
import '../models/story.dart';
import '../appDrawer.dart';
import 'pageData.dart';

class Home {
  final List<StoryData> popular, newlyAdded, updated, featured;

  Home({this.popular, this.newlyAdded, this.updated, this.featured});

  static Home fromHome(Document doc) {
    final popularList = doc.querySelectorAll("#popular_stories.story-card-list .story-card");
    final newList = doc.querySelectorAll("#new_stories.story-card-list .story-card");
    final updatedList = doc.querySelectorAll("#latest_stories.story-card-list .story-card");
    final featuredList = doc.querySelectorAll(".featured_box > .right > .featured_story");
    return Home(
      popular: popularList.map((c) => StoryData.fromStoryCard(c)).toList(),
      newlyAdded: newList.map((c) => StoryData.fromStoryCard(c)).toList(),
      updated: updatedList.map((c) => StoryData.fromStoryCard(c)).toList(),
      featured: featuredList.map((c) => StoryData.fromStoryCard(c)).toList(),
    );
  }

  static PageData<Home> page(Document doc) {
    return PageData<Home>(drawer: AppDrawerData.fromDoc(doc), body: Home.fromHome(doc));
  }
}
