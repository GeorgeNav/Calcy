import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calcy/routes/calcy.dart';

final appName = 'Calcy';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash>{
  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if(_seen)
      Navigator
        .of(context)
        .pushReplacement(
          MaterialPageRoute( builder: (context) => Calcy() )
      );
    else {
      prefs.setBool('seen', true);
      Navigator
        .of(context)
        .pushReplacement(
          MaterialPageRoute( builder: (context) => IntroScreen() )
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkFirstSeen();
    Timer(
      Duration(milliseconds: 200), () {
        checkFirstSeen();
      });
  }

  @override
  Widget build(BuildContext context) =>
    Scaffold(
      body: Center(
        child: Text('Beep boop...'),
      ),
    );
}

class IntroScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Material(
    child: Container(
      color: Color.fromARGB(255, 33, 34, 38),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              appName,
              style: TextStyle(
                color: Color.fromARGB(255, 94, 94, 97),
                fontSize: 50.0,
              )
            ),
            MaterialButton(
              color: Color.fromARGB(255, 94, 94, 97),
              child: Text('Let\'s calculate!'),
              onPressed: () {
                Navigator
                  .of(context)
                  .pushReplacement(
                    MaterialPageRoute( builder: (context) => Calcy() )
                  );
              },
            )
          ]
        )
      )
    )
  );
}