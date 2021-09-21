# Shy Styling Guide
I don't know.

# Import ordering and styling
Fall back to directory grouping and  shortest->longest  
Label with top-level title  
Place newlines between each section except in Local  

---
## dart
### Core (`dart:`)
### Third Party

## flutter
### Core (`package:flutter`)
`material` or `widgets` at top
### Third Party

## local
Directory order: root, screens, widgets, models, util  

If you're importing files from the same directory (excluding root), include the dir name.  
e.g. `storyTags.dart` -> `../widgets/storyTags.dart`  

When there are 3 or more files from a dir, shorten to `index.dart`.

---

example:
```dart
//dart
import 'dart:math';
import 'dart:convert' show jsonDecode, utf8;

import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:brotli/brotli.dart';
import 'package:http/http.dart' show Request;

//flutter
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';


import 'package:badges/badges.dart';
import 'package:assorted_layout_widgets/assorted_layout_widgets.dart';

//local
import '../appDrawer.dart';
import '../screens/story.dart';
import '../screens/chapter.dart';
import '../widgets/index.dart';
import '../util/unescape.dart';
```
