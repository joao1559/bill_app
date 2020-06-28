import 'package:bill_app/ui/screens/home.dart';
import 'package:bill_app/ui/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var prefs = await SharedPreferences.getInstance();
  var _email = prefs.getString('email');
  var _password = prefs.getString('password');

  Future<Map> _login() async {
    http.Response response = await http.post(
        // 'http://192.168.100.5:3001/auth',
        'https://bill-financial-assistant-api.herokuapp.com/auth',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': _email,
          'password': _password
        }),
    );

    return json.decode(response.body);
  }

  if (_email != null && _password != null) {
    _login().then((res) {
      if(res['error'] == null) {
        var token = res['content']['token'];
        prefs.setString('token', token);

        return runApp(
          MaterialApp(
            title: 'Bill',
            theme: ThemeData(
              primaryColor: Colors.indigo,
              accentColor: Colors.greenAccent,
              cursorColor: Colors.greenAccent,
            ),
            home: Home(),
          )
        );
      } else {
        return runApp(
          MaterialApp(
            title: 'Bill',
            theme: ThemeData(
              primaryColor: Colors.indigo,
              accentColor: Colors.greenAccent,
              cursorColor: Colors.greenAccent,
            ),
            home: Login(),
          )
        );
      }
    });
  } else {
    return runApp(
      MaterialApp(
        title: 'Bill',
        theme: ThemeData(
          primaryColor: Colors.indigo,
          accentColor: Colors.greenAccent,
          cursorColor: Colors.greenAccent,
        ),
        home: Login(),
      )
    );
  }
}
