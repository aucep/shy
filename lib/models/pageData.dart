//code-splitting
import '../appDrawer.dart';

class PageData<T> {
  final AppDrawerData drawer;
  final T body;

  const PageData({this.drawer, this.body});
}
//it's quiet in here