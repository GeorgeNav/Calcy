import 'package:flutter/material.dart';
import 'package:calcy/routes/splash.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calcy',
      theme: ThemeData(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      home: Splash(),
    );
  }
}
