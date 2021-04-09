import 'package:html/dom.dart';
//code-splitting
import '../appDrawer.dart';
import '../util/fimHttp.dart';
import '../util/unescape.dart';
import 'pageData.dart';
import 'story.dart';

class ChapterData {
  final String title;

  ///NOT equivalent to the chapter number; used for actions
  final String id;

  ///whether the chapter has been read; action variable
  bool read;

  final String date;

  final String wordcount;

  final StoryData story;

  ///the html contents of the author's note; empty if not exists
  final String note;

  final bool noteIsOnTop;

  ///the html contents of each direct child of the chapter body element
  final List<String> body;

  ///the hash of the bookmarked paragraph's innerText
  final String bookmarkHash;

  ChapterData({
    this.date,
    this.id,
    this.wordcount,
    this.read,
    this.story,
    this.title,
    this.note,
    this.noteIsOnTop,
    this.body,
    this.bookmarkHash,
  });

  static ChapterData fromChapterPage(Document doc) {
    //lessen the search a little
    final chapter = doc.querySelector('#chapter_format');

    final title = chapter.querySelector('#chapter_title');

    final authorsNote = chapter.querySelector('.authors-note');

    final body = chapter.querySelector('#chapter-body > div');
    final paragraphs = body.children.map((p) => p.outerHtml).toList();

    //for id, bookmarkHash
    final chapterData = chapter.parent;

    return ChapterData(
      story: StoryData.fromChapterHeader(doc),
      title: title.innerHtml,
      note: authorsNote?.innerHtml ?? '',
      noteIsOnTop:
          authorsNote != null ? authorsNote.attributes['style'].startsWith('margin-top') : false,
      body: paragraphs,
      id: chapterData.attributes['data-chapter'],
      bookmarkHash: chapterData.attributes['data-bookmark-hash'],
    );
  }

  static PageData<ChapterData> page(Document doc) {
    return PageData<ChapterData>(
        drawer: AppDrawerData.fromDoc(doc), body: ChapterData.fromChapterPage(doc));
  }

  ///from a row in story's chapterlist
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

  ///from a row in chapter's chapterlist
  static ChapterData fromChapterRow(Element row) {
    final title = row.querySelector('.chapter-selector__title');
    final wordcount = row.querySelector('.chapter-selector__words');
    final readIcon = row.querySelector('.fa');

    return ChapterData(
      title: title.innerHtml,
      wordcount: wordcount.innerHtml,
      read: readIcon.className.contains('check'),
    );
  }

  //actions

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
}
