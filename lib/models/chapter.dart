import 'package:html/dom.dart';
//code-splitting
import '../appDrawer.dart';
import '../util/fimHttp.dart';
import '../util/unescape.dart';
import 'pageData.dart';
import 'story.dart';

class ChapterData {
  final String title;
  //as row in story
  final String date, id;
  //as row
  final String wordcount;
  bool read;
  //as screen
  final StoryData story;
  final String note;
  final bool notePosition;
  final List<String> paragraphs;

  ChapterData(
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
  static ChapterData fromChapter(Document doc) {
    final title = doc.querySelector('#chapter_title');
    final authorsNote = doc.querySelector('.authors-note');
    final noteOnTop =
        authorsNote != null ? authorsNote.attributes['style'].startsWith('margin-top') : false;
    final body = doc.querySelector('#chapter-body > div');
    final paragraphs = body.children.map((p) => p.outerHtml).toList();
    return ChapterData(
      story: StoryData.fromChapter(doc),
      title: title.innerHtml,
      note: authorsNote?.innerHtml ?? '',
      notePosition: noteOnTop,
      paragraphs: paragraphs,
    );
  }

  static PageData<ChapterData> page(Document doc) {
    return PageData<ChapterData>(
        drawer: AppDrawerData.fromDoc(doc), body: ChapterData.fromChapter(doc));
  }

  //chapter row from story
  static ChapterData fromStoryRow(Element row) {
    final title = row.querySelector('.chapter-title');
    final date = row.querySelector('.date');
    final wordcount = row.querySelector('.word-count-number');
    final readIcon = row.querySelector('.chapter-read-icon');
    return ChapterData(
      title: unescape(title.innerHtml),
      date: date.nodes[1].text,
      wordcount: wordcount.innerHtml.trim(),
      read: readIcon != null ? readIcon.classes.contains('chapter-read') : null,
      id: readIcon != null ? readIcon.id.replaceFirst('chapter_read_', '') : null,
    );
  }

  Future<bool> setRead(bool changedTo) async {
    final resp = await http.ajaxRequest('chapters/$id/read', changedTo ? 'POST' : 'DELETE');
    final json = resp.json;
    if (json.containsKey('error')) {
      print(json['error']);
      return json['error'];
    }
    read = json['read'];
    return null;
  }

  //chapter row from chapter
  static ChapterData fromChapterRow(Element row) {
    final readIcon = row.querySelector('.fa');
    final title = row.querySelector('.chapter-selector__title');
    final wordcount = row.querySelector('.chapter-selector__words');

    return ChapterData(
      read: readIcon.className.contains('check'),
      title: title.innerHtml,
      wordcount: wordcount.innerHtml,
    );
  }
}
