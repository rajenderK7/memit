import 'package:flutter/material.dart';

SnackBar customSnackbar(String content, {Color? color}) {
  return SnackBar(
    content: Text(
      content,
      style: TextStyle(color: color),
    ),
  );
}
