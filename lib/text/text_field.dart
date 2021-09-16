import 'package:flutter/material.dart';

enum SmartTextType { H1, T, QUOTE, UNDERLINE, BULLET }

extension SmartTextStyle on SmartTextType {
  static TextStyle? mystyle;

  void set textStyle(var style) {
    style == SmartTextType.QUOTE
        ? mystyle = TextStyle(
            fontSize: 12.0, fontStyle: FontStyle.italic, color: Colors.white70)
        : style == SmartTextType.H1
            ? mystyle = TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)
            : style == SmartTextType.UNDERLINE
                ? mystyle = TextStyle(decoration: TextDecoration.underline)
                : mystyle = TextStyle(fontSize: 12.0);
  }

  TextStyle get textStyle {
    return mystyle ?? TextStyle(fontSize: 12.0);
  }

  EdgeInsets get padding {
    switch (this) {
      case SmartTextType.H1:
        return EdgeInsets.fromLTRB(16, 24, 16, 8);
      case SmartTextType.BULLET:
        return EdgeInsets.fromLTRB(24, 8, 16, 8);
      default:
        return EdgeInsets.fromLTRB(16, 8, 16, 8);
    }
  }

  TextAlign get align {
    switch (this) {
      case SmartTextType.QUOTE:
      case SmartTextType.UNDERLINE:
        return TextAlign.center;
      default:
        return TextAlign.justify;
    }
  }

  String get prefix {
    return this == SmartTextType.BULLET ? '\u2022 ' : '';
    // switch (this) {
    //   case SmartTextType.BULLET:
    //     return '\u2022 ';
    //   default:
    // }
    // throw ("some arbitrary bulleting error");
  }
}

class SmartTextField extends StatelessWidget {
  const SmartTextField(
      {required this.type, this.controller, this.focusNode, Key? key})
      : super(key: key);

  final SmartTextType type;
  final controller;
  final focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        keyboardType: TextInputType.multiline,
        maxLines: null,
        cursorColor: Colors.teal,
        textAlign: type.align,
        decoration: InputDecoration(
            border: InputBorder.none,
            prefixText: type.prefix,
            prefixStyle: type.textStyle,
            isDense: true,
            contentPadding: type.padding),
        style: type.textStyle);
  }
}
