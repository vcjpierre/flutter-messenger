import 'package:flutter/material.dart';
import 'config/Palette.dart';
import 'pages/RegisterPage.dart';

void main() => runApp(Messenger());

class Messenger extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Messenger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Palette.primaryColor,
      ),
      home: RegisterPage(),
    );
  }
}
