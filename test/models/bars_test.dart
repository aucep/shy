import 'package:html/dom.dart';
import 'package:test/test.dart';
import 'package:shy/models/bars.dart';

//cases:
//ratings enabled (normal)
final control =
    '''<div class="rating_container rating_container_442301" data-story="442301" data-controller-id="4"><a class="like_button " data-click="like"><i class="fa fa-thumbs-o-up"></i><span class="likes">211</span></a><div class="rating-bar "><div class="like-bar" style="width:92.95154185022%;"></div></div><a class="dislike_button " data-click="dislike"><i class="fa fa-thumbs-o-down"></i><span class="dislikes">16</span></a><div class="divider"></div><span title="1,002 comments"><i class="fa fa-comments"></i>&nbsp;1k</span><div class="divider"></div><span title="3,017 views / 59,712 total views"><a class="stats-link" href="/story/stats/442301"><i class="fa fa-bar-chart-o"></i>&nbsp;3k</a></span><div class="divider"></div><div class="button-group" style="margin:0;"><a class="drop-down-expander"><i class="fa fa-caret-down"></i></a><div class="drop-down" style="width:12em;"><ul><li><a data-click="showAddToGroups"><i class="fa fa-group"></i> Add to Groups</a></li><li><a href="/story/stats/442301"><i class="fa fa-bar-chart"></i> Statistics</a></li><li><a href="/search/blog-posts?q=story:442301&amp;s=date"><i class="fa fa-file-text"></i> Blog Posts</a></li><li class="divider"></li><li><a href="/story/download/442301/txt" title="Download Story (.txt)"><i class="fa fa-download"></i> Download .txt</a></li><li><a href="/story/download/442301/html" title="Download Story (.html)"><i class="fa fa-download"></i> Download .html</a></li><li><a href="/story/download/442301/epub" title="Download Story (.epub)"><i class="fa fa-download"></i> Download .epub</a></li><li class="divider"></li><li><a href="/report/story/442301"><i class="fa fa-warning" style="color:#d16422;"></i> Report Story</a></li></ul></div></div></div>''';
//in chapter
final inChapter =
    '''<div class="rating_container rating_container_442301" data-story="442301" data-controller-id="4"><a class="like_button " data-click="like"><i class="fa fa-thumbs-o-up"></i><span class="likes">211</span></a><div class="rating-bar "><div class="like-bar" style="width:92.95154185022%;"></div></div><a class="dislike_button " data-click="dislike"><i class="fa fa-thumbs-o-down"></i><span class="dislikes">16</span></a><div class="divider"></div><span title="1,002 comments"><i class="fa fa-comments"></i>&nbsp;1,002</span><div class="divider"></div><span title="59,712 total views"><i class="fa fa-bar-chart-o"></i>&nbsp;3,017</span></div>''';
//ratings disabled
final ratingsDisabled =
    '''<div class="rating_container rating_container_69770" data-story="69770" data-controller-id="4">					Ratings Disabled
<div class="divider"></div><span title="980 comments"><i class="fa fa-comments"></i>&nbsp;980</span><div class="divider"></div><span title="19,930 views / 143,390 total views"><a class="stats-link" href="/story/stats/69770"><i class="fa fa-bar-chart-o"></i>&nbsp;20k</a></span><div class="divider"></div><div class="button-group" style="margin:0;"><a class="drop-down-expander"><i class="fa fa-caret-down"></i></a><div class="drop-down" style="width:12em;"><ul><li><a data-click="showAddToGroups"><i class="fa fa-group"></i> Add to Groups</a></li><li><a href="/story/stats/69770"><i class="fa fa-bar-chart"></i> Statistics</a></li><li><a href="/search/blog-posts?q=story:69770&amp;s=date"><i class="fa fa-file-text"></i> Blog Posts</a></li><li class="divider"></li><li><a href="/story/download/69770/txt" title="Download Story (.txt)"><i class="fa fa-download"></i> Download .txt</a></li><li><a href="/story/download/69770/html" title="Download Story (.html)"><i class="fa fa-download"></i> Download .html</a></li><li><a href="/story/download/69770/epub" title="Download Story (.epub)"><i class="fa fa-download"></i> Download .epub</a></li><li class="divider"></li><li><a href="/report/story/69770"><i class="fa fa-warning" style="color:#d16422;"></i> Report Story</a></li></ul></div></div></div>''';
//and ratings disabled in chapter is broken on the site level lol
final ratingsDisabledInChapter =
    '''<div class="rating_container rating_container_69770" data-story="69770" data-controller-id="4"><a class="like_button" data-click="like"><i class="fa fa-thumbs-o-up"></i><span class="likes"></span></a><div class="rating-bar rating-bar-hidden"></div><a class="dislike_button dislike_button_selected" data-click="dislike"><i class="fa fa-thumbs-o-down"></i><span class="dislikes"></span></a><div class="divider"></div><span title="980 comments"><i class="fa fa-comments"></i>&nbsp;980</span><div class="divider"></div><span title="143,390 total views"><i class="fa fa-bar-chart-o"></i>&nbsp;19,930</span></div>''';

//no ratings yet
final noRatings =
    '''<div class="rating_container rating_container_492419" data-story="492419" data-controller="rate-story"><a class="like_button " data-click="like" data-element="like_button"><i class="fa fa-thumbs-o-up"></i><span class="likes"></span></a><div class="rating-bar rating-bar-hidden"></div><a class="dislike_button " data-click="dislike" data-element="dislike_button"><i class="fa fa-thumbs-o-down"></i><span class="dislikes"></span></a><div class="divider"></div><span title="2 comments"><i class="fa fa-comments"></i>&nbsp;2</span><div class="divider"></div><span title="94 views / 94 total views"><a class="stats-link" href="/story/stats/492419"><i class="fa fa-bar-chart-o"></i>&nbsp;94</a></span><div class="divider"></div><div class="button-group" style="margin:0;"><a class="drop-down-expander"><i class="fa fa-caret-down"></i></a><div class="drop-down" style="width:12em;"><ul><li><a data-click="showAddToGroups"><i class="fa fa-group"></i> Add to Groups</a></li><li><a href="/story/stats/492419"><i class="fa fa-bar-chart"></i> Statistics</a></li><li><a href="/search/blog-posts?q=story:492419&amp;s=date"><i class="fa fa-file-text"></i> Blog Posts</a></li><li class="divider"></li><li><a href="/story/download/492419/txt" title="Download Story (.txt)"><i class="fa fa-download"></i> Download .txt</a></li><li><a href="/story/download/492419/html" title="Download Story (.html)"><i class="fa fa-download"></i> Download .html</a></li><li><a href="/story/download/492419/epub" title="Download Story (.epub)"><i class="fa fa-download"></i> Download .epub</a></li><li class="divider"></li><li><a href="/report/story/492419"><i class="fa fa-warning" style="color:#d16422;"></i> Report Story</a></li></ul></div></div></div>''';

void main() {
  group('Infobar', () {
    test('control', () {
      final bar = InfoBarData.fromRatingBar(Element.html(control));

      expect(bar.rating.likes, '211');
      expect(bar.rating.dislikes, '16');
      expect(bar.rating.disabled, false);
      expect(bar.rating.storyId, '442301');

      expect(bar.recentViews, '3,017');
      expect(bar.totalViews, '59,712');

      expect(bar.comments, '1,002');
    });
    test('in chapter', () {
      final bar = InfoBarData.fromRatingBar(Element.html(inChapter));

      expect(bar.rating.likes, '211');
      expect(bar.rating.dislikes, '16');
      expect(bar.rating.disabled, false);
      expect(bar.rating.storyId, '442301');

      expect(bar.recentViews, '3,017');
      expect(bar.totalViews, '59,712');

      expect(bar.comments, '1,002');
    });

    test('ratings disabled', () {
      final bar = InfoBarData.fromRatingBar(Element.html(ratingsDisabled));

      expect(bar.rating.disabled, true);

      //19,930 views / 143,390 total views
      expect(bar.recentViews, '19,930');
      expect(bar.totalViews, '143,390');

      expect(bar.comments, '980');
    });

    test('ratings disabled in chapter (will false negative)', () {
      final bar = InfoBarData.fromRatingBar(Element.html(ratingsDisabledInChapter));

      //unfortunately, fimfiction doesn't know when ratings are disabled from a chapter
      expect(bar.rating.disabled, false);

      //19,930 views / 143,390 total views
      expect(bar.recentViews, '19,930');
      expect(bar.totalViews, '143,390');

      expect(bar.comments, '980');
    });

    test('no ratings yet', () {
      final bar = InfoBarData.fromRatingBar(Element.html(noRatings));

      expect(bar.rating.likes, '');
      expect(bar.rating.dislikes, '');
      expect(bar.rating.disabled, false);
      expect(bar.rating.storyId, '492419');

      expect(bar.recentViews, '94');
      expect(bar.totalViews, '94');

      expect(bar.comments, '2');
    });
  });
}

//i think i just wasted my time