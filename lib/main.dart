import 'package:flutter/material.dart';
import 'package:manycooks/text_editor.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = {
      50: Color.fromRGBO(147, 196, 125, .1),
      100: Color.fromRGBO(147, 196, 125, .2),
      200: Color.fromRGBO(147, 196, 125, .3),
      300: Color.fromRGBO(147, 196, 125, .4),
      400: Color.fromRGBO(147, 196, 125, .5),
      500: Color.fromRGBO(147, 196, 125, .6),
      600: Color.fromRGBO(147, 196, 125, .7),
      700: Color.fromRGBO(147, 196, 125, .8),
      800: Color.fromRGBO(147, 196, 125, .9),
      900: Color.fromRGBO(147, 196, 125, 1),
    };
    MaterialColor colorCustom = MaterialColor(0xFFF0B432, color);
    return MaterialApp(
      title: 'Many Cooks',
      theme: ThemeData(
        primarySwatch: colorCustom,
        brightness: Brightness.dark,
        fontFamily: 'Georgia',
      ),
      debugShowCheckedModeBanner: false,
      home: TextEditor(),
    );
  }
}
