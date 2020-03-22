import 'package:bill_app/ui/screens/login.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  title: 'Flutter Demo',
  theme: ThemeData(
    primarySwatch: Colors.indigo,
    accentColor: Colors.greenAccent,
    cursorColor: Colors.greenAccent,
    textTheme: TextTheme(
      display2: TextStyle(
        fontFamily: 'OpenSans',
        fontSize: 45.0,
        color: Colors.greenAccent,
      ),
      button: TextStyle(
        fontFamily: 'OpenSans',
      ),
      subhead: TextStyle(fontFamily: 'NotoSans'),
      body1: TextStyle(fontFamily: 'NotoSans'),
    ),
  ),
  home: LoginScreen(),
));
