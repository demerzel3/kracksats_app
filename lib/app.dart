import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kracksats_app/home.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Kracksats',
      theme: CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromARGB(255, 129, 90, 245),
      ),
      home: Home(title: 'Kracksats'),
    );
  }
}
