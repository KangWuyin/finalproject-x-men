import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class SnackUtils {
  static showSnack(BuildContext context, String msg) {
    showToast(msg,position: ToastPosition.bottom);
  }
}
