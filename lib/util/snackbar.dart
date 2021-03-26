import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/widgets.dart';

void showSnackbar(BuildContext context, String msg) => Flushbar(
      message: msg,
      duration: Duration(seconds: 4),
      animationDuration: Duration(milliseconds: 350),
    ).show(context);
