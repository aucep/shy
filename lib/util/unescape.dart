//dart
import 'package:html_unescape/html_unescape.dart';

final unesc = HtmlUnescape();

String unescape(String s) {
  return unesc.convert(s);
}
