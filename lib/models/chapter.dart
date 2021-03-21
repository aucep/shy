import 'package:html/dom.dart';
import 'package:html_unescape/html_unescape_small.dart';
//code-splitting
import '../appDrawer.dart';
import '../util/fimHttp.dart';
import 'pageData.dart';
import 'story.dart';

class Chapter {
  final String title;
  //as row in story
  final String date, id;
  //as row
  final String wordcount;
  bool read;
  //as screen
  final Story story;
  final String note;
  final bool notePosition;
  final List<String> paragraphs;

  Chapter(
      {this.date,
      this.id,
      this.wordcount,
      this.read,
      this.story,
      this.title,
      this.note,
      this.notePosition,
      this.paragraphs});

  //screen
  static Chapter fromChapter(Document doc) {
    final title = doc.querySelector('#chapter_title');
    final authorsNote = doc.querySelector('.authors-note');
    final noteOnTop =
        authorsNote != null ? authorsNote.attributes['style'].startsWith('margin-top') : false;
    final body = doc.querySelector('#chapter-body > div');
    final paragraphs = body.children.map((p) => p.outerHtml).toList();
    return Chapter(
      story: Story.fromChapter(doc),
      title: title.innerHtml,
      note: authorsNote?.innerHtml ?? '',
      notePosition: noteOnTop,
      paragraphs: paragraphs,
    );
  }

  static Page<Chapter> page(Document doc) {
    return Page<Chapter>(drawer: AppDrawerData.fromDoc(doc), body: Chapter.fromChapter(doc));
  }

  //chapter row from story
  static Chapter fromStoryRow(Element row) {
    final unesc = HtmlUnescape();
    final title = row.querySelector('.chapter-title');
    final date = row.querySelector('.date');
    final wordcount = row.querySelector('.word-count-number');
    final readIcon = row.querySelector('.chapter-read-icon');
    return Chapter(
      title: unesc.convert(title.innerHtml),
      date: date.nodes[1].text,
      wordcount: wordcount.innerHtml.trim(),
      read: readIcon != null ? readIcon.classes.contains('chapter-read') : null,
      id: readIcon != null ? readIcon.id.replaceFirst('chapter_read_', '') : null,
    );
  }

  Future<bool> setRead(bool changedTo) async {
    final resp = await http.ajaxRequest('chapters/$id/read', changedTo ? 'POST' : 'DELETE');
    read = resp.json['read'];
    return read;
  }

  //chapter row from chapter
  static Chapter fromChapterRow(Element row) {
    final readIcon = row.querySelector('.fa');
    final title = row.querySelector('.chapter-selector__title');
    final wordcount = row.querySelector('.chapter-selector__words');

    return Chapter(
      read: readIcon.className.contains('check'),
      title: title.innerHtml,
      wordcount: wordcount.innerHtml,
    );
  }
}
