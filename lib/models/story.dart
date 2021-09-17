//dart
import 'package:html/dom.dart';

//local
import '../appDrawer.dart';
import '../models/index.dart';
import '../util/fimHttp.dart';
import '../util/unescape.dart';

class StoryData {
  final String title, description, imageUrl, contentRating;
  final String authorName, authorId;
  final StoryTags tags;
  final List<ChapterData> chapters;
  final String completedStatus, approvedDate, wordcount;
  final bool hot;
  final RatingBarData rating;
  final String recentViews, totalViews, comments;
  final RelatedStoriesData relatedStories;
  final String id;

  StoryData({
    this.relatedStories,
    this.hot,
    this.rating,
    this.recentViews,
    this.totalViews,
    this.comments,
    this.authorName,
    this.authorId,
    this.tags,
    this.chapters,
    this.completedStatus,
    this.approvedDate,
    this.wordcount,
    this.title,
    this.description,
    this.imageUrl,
    this.contentRating,
    this.id,
  });

  //this type of element actually shows up in [author stories] pages as well
  //for storyscreen
  static StoryData fromStoryPage(Document doc) {
    //lower ancestors for further searches
    final story = doc.querySelector('.story_container');
    final infoContainer = doc.querySelector('.info-container');
    final footer = story.querySelector('.chapters-footer');
    //title -> title, id
    final title = story.querySelector('.story_name');
    final id = title.attributes['href'].split('/')[2];
    //authorlink -> authorName, authorId
    final authorLink = infoContainer.querySelector('h1 > a');
    //desc -> description
    final desc = story.querySelector('.description-text');
    //image -> imageUrl
    final image = story.querySelector('.story_container__story_image > img');
    //contentRating -> contentRating
    final contentRating = story.querySelector('.title > a');
    //completedStatus -> completedStatus
    final completedStatus = footer.querySelector('[class*="status"]');
    //approvedDate -> approvedDate
    final approvedDate = footer.querySelector('.approved-date').children.last;
    //wordcount -> wordcount
    final wordcount = footer.children.last.children.first;
    //tags -> storyTags
    final tags = story.querySelector('.story-tags');
    //chapters -> chapters
    final chapters = story.querySelector('.chapters').children.toList();
    // thank u cherry <3
    chapters.removeWhere((c) => c.querySelector('.chapter-title') == null);
    //ratingContainer -> hot, rating, comments, recentViews, totalViews
    final ratingContainer = story.querySelector('.rating_container');
    final infoBar = InfoBarData.fromRatingBar(ratingContainer);
    //relatedStories -> relatedStories
    final relatedStories = doc.querySelector('.related-stories');

    return StoryData(
      title: title.innerHtml,
      id: id,
      authorName: authorLink.innerHtml,
      authorId: authorLink.attributes['href'].split('/')[2],
      description: desc.innerHtml,
      imageUrl: image != null ? image.attributes['data-src'] : null,
      contentRating: contentRating.innerHtml,
      completedStatus: completedStatus.innerHtml.trim(),
      approvedDate: approvedDate.innerHtml,
      wordcount: wordcount.innerHtml,
      tags: StoryTags.fromTags(tags),
      chapters: chapters.map((c) => ChapterData.fromStoryRow(c)).toList(),
      hot: infoBar.hot,
      rating: infoBar.rating,
      comments: infoBar.comments,
      recentViews: infoBar.recentViews,
      totalViews: infoBar.totalViews,
      relatedStories: RelatedStoriesData.fromTabs(relatedStories),
    );
  }

  static PageData<StoryData> page(Document doc) {
    return PageData<StoryData>(
        drawer: AppDrawerData.fromDoc(doc), body: StoryData.fromStoryPage(doc));
  }

  //from chapter page's story header
  //for chapterscreen drawer
  static StoryData fromChapterHeader(Document doc) {
    //lower ancestor for further searches
    final infoContainer = doc.querySelector('.info-container');
    //storyLink -> title, id
    final storyLink = infoContainer.querySelector('div > h1 > a');
    final id = storyLink.attributes['href'].split('/')[2];
    //authorLink -> authorName, authorId
    final authorLink = infoContainer.querySelector('.author > a');
    //desc -> description
    final desc = infoContainer.querySelector('div > div > p');
    //chapterSelector -> chapters
    final chapterSelector = doc.querySelector('.chapter-selector ul');
    final chapters =
        chapterSelector == null ? [] : chapterSelector.children.where((t) => t != null).toList();
    //ratingContainer -> hot, rating, comments, recentViews, totalViews
    final ratingContainer = doc.querySelector('.rating_container');
    final infoBar = InfoBarData.fromRatingBar(ratingContainer);

    return StoryData(
      title: storyLink.innerHtml,
      id: id,
      authorName: authorLink.innerHtml,
      authorId: authorLink.attributes['href'].split('/')[2],
      description: desc.innerHtml,
      chapters: chapters.map((c) => ChapterData.fromChapterRow(c)).toList(),
      hot: infoBar.hot,
      rating: infoBar.rating,
      comments: infoBar.comments,
      recentViews: infoBar.recentViews,
      totalViews: infoBar.totalViews,
    );
  }

  //for storycardlist (home, story[, chapter?])
  static StoryData fromStoryCard(Element card) {
    //check whether this is a featured story or a story card (they are set up a little differently)
    final bool c = card.attributes["class"] == "story-card";
    //link -> title, id
    final storyLink = card.querySelector(c ? ".story_link" : ".title > a");
    //image -> imageUrl
    final image = card.querySelector(".story_image");
    //desc -> description
    final desc = card.querySelector(c ? ".short_description" : ".description");
    //authorLink -> authorName, authorId
    final authorLink =
        card.querySelector(c ? ".story-card__author" : ".author") ?? card.querySelector(".author");
    //info -> wordcount, recentViews, rating
    final info = card.querySelector(c ? ".story-card__info" : ".info");
    //contentRating -> contentRating
    final contentRating = card.querySelector(c ? ".story-card__title > span" : ".title > span");

    return StoryData(
      title: unescape(storyLink.innerHtml),
      id: storyLink.attributes["href"].split("/")[2],
      imageUrl: image != null ? image.attributes["src"] ?? image.attributes["data-src"] : "",
      description: (c ? desc.nodes[desc.nodes.length == 1 ? 0 : 2] : desc.nodes.last).text.trim(),
      authorName: authorLink.innerHtml,
      authorId: authorLink.attributes["href"].split("/")[2],
      wordcount: info.nodes[c ? 4 : 3].text.trim(),
      recentViews: (c ? info.nodes.last : info.nodes[5]).text.trim(),
      rating: RatingBarData(
        likes: c
            ? info.nodes.length == 14
                ? info.nodes[7].text.trim()
                : ''
            : info.nodes[9].text.trim(),
        dislikes: c
            ? info.nodes.length == 14
                ? info.nodes[10].text.trim()
                : ''
            : info.nodes.last.text.trim(),
      ),
      contentRating: contentRating.innerHtml,
      tags: StoryTags.fromTags(card),
    );
  }

  //actions

  //returns String error or List<Bookshelf> result
  Future<dynamic> getShelves() async {
    print('getting shelves for story $id');
    final resp = await http.ajaxRequest(
      'bookshelves/add-story-popup?story=$id',
      'GET',
      signSet: false,
    );

    if (resp.is404 ?? false) {
      return '404';
    }

    final json = resp.json;
    if (json.containsKey('error')) {
      final err = json['error'];
      print(err);
      return err;
    }

    return BookshelfData.fromPopupList(Element.html(json['content']));
  }
}

class RelatedStoriesData {
  final List<StoryData> alsoLiked, similar, author;
  const RelatedStoriesData({this.alsoLiked, this.similar, this.author});

  static RelatedStoriesData fromTabs(Element doc) {
    final alsoLiked = doc.querySelectorAll('[data-tab="also-liked"] .story-card');
    final similar = doc.querySelectorAll('[data-tab="similar"] .story-card');
    final author = doc.querySelectorAll('[data-tab="author"] .story-card');

    return RelatedStoriesData(
      alsoLiked: alsoLiked.map((s) => StoryData.fromStoryCard(s)).toList(),
      similar: similar.map((s) => StoryData.fromStoryCard(s)).toList(),
      author: author.map((s) => StoryData.fromStoryCard(s)).toList(),
    );
  }
}
