import 'package:html/dom.dart' show Element;

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
