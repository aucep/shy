import 'package:html/dom.dart';

//code-splitting
import '../util/fimHttp.dart';
import '../appDrawer.dart';
import 'bookshelf.dart';
import 'chapter.dart';
import 'tags.dart';
import 'pageData.dart';

class Story {
  final String title, description, imageUrl, contentRating;
  final String authorName, authorId;
  final StoryTags tags;
  final List<Chapter> chapters;
  final String completedStatus, approvedDate, wordcount;
  final bool hot, ratingsDisabled;
  String likes, dislikes;
  bool liked, disliked;
  final double rating;
  final String recentViews, totalViews, comments;
  //for chapter
  final String id;

  Story({
    this.hot,
    this.ratingsDisabled,
    this.likes,
    this.dislikes,
    this.liked,
    this.disliked,
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

  //from story page
  //for storyscreen
  static Story fromStory(Document doc) {
    final story = doc.querySelector('.story_container');

    //top
    final title = story.querySelector('.story_name');
    final description = story.querySelector('.description-text');
    final image = story.querySelector('.story_container__story_image > img');
    final contentRating = story.querySelector('.title > a');

    //footer
    final footer = story.querySelector('.chapters-footer');
    final completedStatus = footer.children[1];
    final approvedDate = footer.children[2].children.last;
    final wordcount = footer.children.last.children.first;

    //tags
    final tags = story.querySelector('.story-tags');

    //chapter
    final chapters = story.querySelector('.chapters').children;
    //chapters.removeWhere((c) => c.querySelector('.chapter-title') == null);
    //removeWhere is not implemented, fuck me
    List<int> indexesToRemove = [];
    chapters.asMap().forEach((i, c) {
      if (c.querySelector('.chapter-title') == null) indexesToRemove.add(i);
    });
    for (var i = 0; i < indexesToRemove.length; i++) {
      final index = indexesToRemove[i] - i;
      chapters.removeAt(index);
    }

    //rating_container
    final ratings = story.querySelector('.rating_container');
    final ratingBar = RatingBar.fromRatingBar(ratings);

    return Story(
      id: title.attributes['href'].split('/')[2],
      title: title.innerHtml,
      description: description.innerHtml,
      imageUrl: image != null ? image.attributes['data-src'] : null,
      contentRating: contentRating.innerHtml,
      completedStatus: completedStatus.innerHtml,
      approvedDate: approvedDate.innerHtml,
      wordcount: wordcount.innerHtml,
      tags: StoryTags.fromTags(tags),
      chapters: chapters.map((c) => Chapter.fromStoryRow(c)).toList(),
      hot: ratingBar.hot,
      ratingsDisabled: ratingBar.ratingsDisabled,
      likes: ratingBar.likes,
      liked: ratingBar.liked,
      dislikes: ratingBar.dislikes,
      disliked: ratingBar.disliked,
      rating: ratingBar.rating,
      comments: ratingBar.comments,
      recentViews: ratingBar.recentViews,
      totalViews: ratingBar.totalViews,
    );
  }

  static Page<Story> page(Document doc) {
    return Page<Story>(drawer: AppDrawerData.fromDoc(doc), body: Story.fromStory(doc));
  }

  //from chapter page's story header
  //for chapterscreen drawer
  static Story fromChapter(Document doc) {
    final infoContainer = doc.querySelector('.info-container');
    final storyLink = infoContainer.querySelector('div > h1 > a');
    final authorLink = infoContainer.querySelector('.author > a');
    final description = infoContainer.querySelector('div > div > p');
    final chapterSelector = doc.querySelector('.chapter-selector ul');
    final chapters =
        chapterSelector == null ? [] : chapterSelector.children.where((t) => t != null).toList();
    final ratings = doc.querySelector('.rating_container');
    final ratingBar = RatingBar.fromRatingBar(ratings);

    final id = storyLink.attributes['href'].split('/')[2];
    return Story(
      title: storyLink.innerHtml,
      id: id,
      authorName: authorLink.innerHtml,
      authorId: authorLink.attributes['href'].split('/')[2],
      description: description.innerHtml,
      chapters: chapters.map((c) => Chapter.fromChapterRow(c)).toList(),
      hot: ratingBar.hot,
      ratingsDisabled: ratingBar.ratingsDisabled,
      likes: ratingBar.likes,
      liked: ratingBar.liked,
      dislikes: ratingBar.dislikes,
      disliked: ratingBar.disliked,
      rating: ratingBar.rating,
      comments: ratingBar.comments,
      recentViews: ratingBar.recentViews,
      totalViews: ratingBar.totalViews,
    );
  }

  //actions (return error)
  Future<String> like() async {
    final resp = await http.ajaxRequest('story/$id/like', 'POST');
    final json = resp.json;
    if (json.containsKey('error')) {
      final err = json['error'];
      print(err);
      return err;
    }
    likes = '${json['likes']}';
    liked = json['liked'];
    dislikes = '${json['dislikes']}';
    disliked = json['disliked'];
    return null;
  }

  Future<String> dislike() async {
    final resp = await http.ajaxRequest('story/$id/dislike', 'POST');
    final json = resp.json;
    if (json.containsKey('error')) {
      final err = json['error'];
      print(err);
      return err;
    }
    likes = '${json['likes']}';
    liked = json['liked'];
    dislikes = '${json['dislikes']}';
    disliked = json['disliked'];
    return null;
  }

  //returns String error or List<Bookshelf> result
  Future<dynamic> getShelves() async {
    print('story: $id');
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

    return Bookshelf.fromPopupList(Element.html(json['content']));
  }
}

class RatingBar {
  final bool hot, ratingsDisabled;
  final String likes, dislikes;
  final bool liked, disliked;
  final double rating;
  final String recentViews, totalViews, comments;

  RatingBar({
    this.hot,
    this.ratingsDisabled,
    this.likes,
    this.dislikes,
    this.liked,
    this.disliked,
    this.rating,
    this.comments,
    this.recentViews,
    this.totalViews,
  });

  //from story/chapter page header
  //for story, chapter
  static RatingBar fromRatingBar(Element bar) {
    final hot = bar.querySelector('.hot-container') != null;

    final ratingsDisabled = bar.nodes[0].text.trim() == 'Ratings Disabled';
    Element likeButton, likes, dislikeButton, dislikes, rating;
    if (!ratingsDisabled) {
      likeButton = bar.querySelector('.like_button');
      likes = likeButton.querySelector('.likes');
      dislikeButton = bar.querySelector('.dislike_button');
      dislikes = dislikeButton.querySelector('.dislikes');
      rating = bar.querySelector('.like-bar');
    }

    final commentsIcon = bar.querySelector('.fa-comments');

    final inStory = bar.children.last.className
        .contains('button-group'); //if last child is a dropdown, this is in a story page
    final viewInfo = inStory ? bar.querySelector('.stats-link') : bar.children.last;
    final viewTitle = (inStory ? viewInfo.parent : viewInfo).attributes['title'];
    return RatingBar(
      hot: hot,
      ratingsDisabled: ratingsDisabled,
      likes: ratingsDisabled ? null : likes.innerHtml,
      liked: ratingsDisabled ? null : likeButton.className.contains('selected'),
      dislikes: ratingsDisabled ? null : dislikes.innerHtml,
      disliked: ratingsDisabled ? null : dislikeButton.className.contains('selected'),
      rating: ratingsDisabled || rating.className.endsWith('hidden')
          ? null
          : double.parse(rating.attributes['style'].replaceAll('width:', '').replaceAll('%;', '')),
      comments: commentsIcon.parent.nodes.last.text.trim(),
      recentViews: viewInfo.nodes.last.text.trim(),
      totalViews: (inStory ? viewTitle.split('/').last.trimLeft() : viewTitle).split(' ').first,
    );
  }
}
