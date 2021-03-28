//code-splitting
import 'package:html/dom.dart' show Element;

import '../util/fimHttp.dart';

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

  //from story/chapter page header
  //for story, chapter
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

    final inStory = bar.children.last.className
        .contains('button-group'); //if last child is a dropdown, this is in a story page
    final viewInfo = inStory ? bar.querySelector('.stats-link') : bar.children.last;
    final viewTitle = (inStory ? viewInfo.parent : viewInfo).attributes['title'];
    return InfoBarData(
      hot: hot,
      rating: ratingsDisabled
          ? RatingBarData(disabled: true)
          : RatingBarData(
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
      comments: commentsIcon.parent.nodes.last.text.trim(),
      recentViews: viewInfo.nodes.last.text.trim(),
      totalViews: (inStory ? viewTitle.split('/').last.trimLeft() : viewTitle).split(' ').first,
    );
  }
}

class RatingBarData {
  final String storyId;
  final bool disabled;
  String likes, dislikes;
  bool liked, disliked;
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
