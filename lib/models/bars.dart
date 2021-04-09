//code-splitting
import 'package:html/dom.dart' show Element;

import '../util/fimHttp.dart';

///holds info bar data
class InfoBarData {
  final bool hot;
  final RatingBarData rating;
  final String recentViews, totalViews, comments;

  InfoBarData({
    this.hot,
    this.rating,
    this.comments,
    this.recentViews,
    this.totalViews,
  });

  ///from 'rating bar' element (found in story container/chapter header)
  static InfoBarData fromRatingBar(Element bar) {
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

    //views
    final inStory = bar.children.last.className
        .contains('button-group'); //if last child is a dropdown, this is in a story page
    final viewInfo = bar.querySelector('.fa-bar-chart-o');
    final viewTitle = (inStory ? viewInfo.parent : viewInfo).parent.attributes['title'];
    return InfoBarData(
      hot: hot,
      rating: ratingsDisabled
          ? RatingBarData(disabled: true)
          : RatingBarData(
              storyId: bar.attributes['data-story'],
              disabled: false,
              likes: likes.innerHtml,
              dislikes: dislikes.innerHtml,
              liked: likeButton.className.contains('selected'),
              disliked: dislikeButton.className.contains('selected'),
              rating: rating == null
                  ? null
                  : rating.className.endsWith('hidden')
                      ? null
                      : double.parse(
                          rating.attributes['style'].replaceAll('width:', '').replaceAll('%;', ''),
                        ),
            ),
      comments: commentsIcon.parent.attributes['title'].split(' ').first,
      recentViews: inStory
          ? viewTitle.split('/').first.split(' ').first
          : viewInfo.parent.nodes.last.text.trim(),
      totalViews: (inStory ? viewTitle.split('/').last.trimLeft() : viewTitle).split(' ').first,
    );
  }
}

//this class exists because composition
///holds data and actions (simple constructor)
class RatingBarData {
  final String storyId;

  ///whether rating has been disabled for the story
  final bool disabled;
  String likes, dislikes;
  bool liked, disliked;

  ///[0,1] the percent green a rating bar visualization should be
  final double rating;

  RatingBarData({
    this.storyId,
    this.disabled,
    this.likes,
    this.dislikes,
    this.liked,
    this.disliked,
    this.rating,
  });

  RatingBarData withStoryId(String id) {
    return RatingBarData(
      storyId: id,
      disabled: disabled,
      likes: likes,
      dislikes: dislikes,
      liked: liked,
      disliked: disliked,
      rating: rating,
    );
  }

  //actions
  Future<String> like() async {
    final resp = await http.ajaxRequest('stories/$storyId/like', 'POST');
    if (resp.is404) {
      print('404');
      return '404';
    }
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
    final resp = await http.ajaxRequest('stories/$storyId/dislike', 'POST');
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
}
