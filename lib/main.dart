import 'package:flutter/material.dart';
import 'package:merchantfrontapp/widgets/dashboard.dart';
import 'package:merchantfrontapp/widgets/landing_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
//  show AppBar, BuildContext, Center, Colors, Column, FloatingActionButton, Icon, Icons, Key, MainAxisAlignment, MaterialApp, Scaffold, State, StatefulWidget, StatelessWidget, Text, Theme, ThemeData, Widget, runApp;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var merchantid = prefs.getString('merchantid');
  print(merchantid);
  runApp(MaterialApp(
      theme: ThemeData.light().copyWith(
        iconTheme: IconThemeData(
          color: Color(0xFFf1d300),
        ),
        accentColor: Color(0xFFf1d300),
        textTheme: TextTheme(
          display1: TextStyle(color: Colors.black),
          display2: TextStyle(color: Colors.black),
          display3: TextStyle(color: Colors.black),
          display4: TextStyle(color: Colors.black),
          body1: TextStyle(color: Colors.black),
          body2: TextStyle(color: Colors.black),
          headline: TextStyle(color: Colors.black),
          title: TextStyle(color: Colors.black),
          subhead: TextStyle(color: Colors.black),
          subtitle: TextStyle(color: Colors.black),
          caption: TextStyle(color: Colors.black),
          overline: TextStyle(color: Colors.black),
          button: TextStyle(
            fontFamily: 'OpenSans',
          ),
        ),
      ),
      home: merchantid == null ? LandingPage() : Dashboard()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        iconTheme: IconThemeData(
          color: Color(0xFFf1d300),
        ),
        accentColor: Color(0xFFf1d300),
        textTheme: TextTheme(
          display1: TextStyle(color: Colors.black),
          display2: TextStyle(color: Colors.black),
          display3: TextStyle(color: Colors.black),
          display4: TextStyle(color: Colors.black),
          body1: TextStyle(color: Colors.black),
          body2: TextStyle(color: Colors.black),
          headline: TextStyle(color: Colors.black),
          title: TextStyle(color: Colors.black),
          subhead: TextStyle(color: Colors.black),
          subtitle: TextStyle(color: Colors.black),
          caption: TextStyle(color: Colors.black),
          overline: TextStyle(color: Colors.black),
          button: TextStyle(
            fontFamily: 'OpenSans',
          ),
        ),
      ),
      home: LandingPage(),
    );
  }
}
