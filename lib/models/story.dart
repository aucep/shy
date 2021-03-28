import 'package:html/dom.dart';

//code-splitting
import '../util/fimHttp.dart';
import '../appDrawer.dart';
import 'bookshelf.dart';
import 'chapter.dart';
import 'rating.dart';
import 'tags.dart';
import 'pageData.dart';

class StoryData {
  final String title, description, imageUrl, contentRating;
  final String authorName, authorId;
  final StoryTags tags;
  final List<ChapterData> chapters;
  final String completedStatus, approvedDate, wordcount;
  final bool hot;
  final RatingBarData rating;
  final String recentViews, totalViews, comments;
  //for chapter
  final String id;

  StoryData({
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

  //from story page
  //for storyscreen
  static StoryData fromStory(Document doc) {
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
    final infoBar = InfoBarData.fromRatingBar(ratings);

    //id
    final id = title.attributes['href'].split('/')[2];
    return StoryData(
      id: id,
      title: title.innerHtml,
      description: description.innerHtml,
      imageUrl: image != null ? image.attributes['data-src'] : null,
      contentRating: contentRating.innerHtml,
      completedStatus: completedStatus.innerHtml,
      approvedDate: approvedDate.innerHtml,
      wordcount: wordcount.innerHtml,
      tags: StoryTags.fromTags(tags),
      chapters: chapters.map((c) => ChapterData.fromStoryRow(c)).toList(),
      hot: infoBar.hot,
      rating: infoBar.rating.withStoryId(id),
      comments: infoBar.comments,
      recentViews: infoBar.recentViews,
      totalViews: infoBar.totalViews,
    );
  }

  static PageData<StoryData> page(Document doc) {
    return PageData<StoryData>(drawer: AppDrawerData.fromDoc(doc), body: StoryData.fromStory(doc));
  }

  //from chapter page's story header
  //for chapterscreen drawer
  static StoryData fromChapter(Document doc) {
    final infoContainer = doc.querySelector('.info-container');
    final storyLink = infoContainer.querySelector('div > h1 > a');
    final authorLink = infoContainer.querySelector('.author > a');
    final description = infoContainer.querySelector('div > div > p');
    final chapterSelector = doc.querySelector('.chapter-selector ul');
    final chapters =
        chapterSelector == null ? [] : chapterSelector.children.where((t) => t != null).toList();
    final ratingContainer = doc.querySelector('.rating_container');
    final infoBar = InfoBarData.fromRatingBar(ratingContainer);

    final id = storyLink.attributes['href'].split('/')[2];
    return StoryData(
      title: storyLink.innerHtml,
      id: id,
      authorName: authorLink.innerHtml,
      authorId: authorLink.attributes['href'].split('/')[2],
      description: description.innerHtml,
      chapters: chapters.map((c) => ChapterData.fromChapterRow(c)).toList(),
      hot: infoBar.hot,
      rating: infoBar.rating.withStoryId(id),
      comments: infoBar.comments,
      recentViews: infoBar.recentViews,
      totalViews: infoBar.totalViews,
    );
  }

  //actions

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

    return BookshelfData.fromPopupList(Element.html(json['content']));
  }
}
