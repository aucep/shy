//flutter
import 'package:flutter/widgets.dart';

import 'package:another_flushbar/flushbar.dart';

void showSnackbar(BuildContext context, String msg) => Flushbar(
      message: msg,
      duration: Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 350),
    ).show(context);
