//code-splitting
import '../appDrawer.dart';

class Page<T> {
  final AppDrawerData drawer;
  final T body;

  const Page({this.drawer, this.body});
}
//it's quiet in here