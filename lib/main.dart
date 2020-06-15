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
          headline4: TextStyle(color: Colors.black),
          headline3: TextStyle(color: Colors.black),
          headline2: TextStyle(color: Colors.black),
          headline1: TextStyle(color: Colors.black),
          bodyText2: TextStyle(color: Colors.black),
          bodyText1: TextStyle(color: Colors.black),
          headline5: TextStyle(color: Colors.black),
          headline6: TextStyle(color: Colors.black),
          subtitle1: TextStyle(color: Colors.black),
          subtitle2: TextStyle(color: Colors.black),
          caption: TextStyle(color: Colors.black),
          overline: TextStyle(color: Colors.black),
          button: TextStyle(
            fontFamily: 'OpenSans',
          ),
        ),
      ),
      home: merchantid == null ? LandingPage() : Dashboard()));
}
