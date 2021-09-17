//dart
import 'package:html/dom.dart';

class StoryTags {
  final List<String> series, warning, genre, content, character;

  StoryTags({this.series, this.warning, this.genre, this.content, this.character});

  static StoryTags fromTags(Element tags) {
    final seriesTags = tags.querySelectorAll('.tag-series');
    final warningTags = tags.querySelectorAll('.tag-warning');
    final genreTags = tags.querySelectorAll('.tag-genre');
    final contentTags = tags.querySelectorAll('.tag-content');
    final characterTags = tags.querySelectorAll('.tag-character');

    List<String> tagNames(List<Element> tags) => tags.map((t) => t.innerHtml).toList();

    return StoryTags(
      series: tagNames(seriesTags),
      warning: tagNames(warningTags),
      genre: tagNames(genreTags),
      content: tagNames(contentTags),
      character: tagNames(characterTags),
    );
  }
}
