import 'package:bill_app/ui/screens/cadastro_usuario.dart';
import 'package:bill_app/ui/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _hidePassword = true;
  var _loginButtonDisabled = false;
  var _saveData = false;

  Future<Map> _login() async {
    http.Response response = await http.post(
      'https://bill-financial-assistant-api.herokuapp.com/auth',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': _emailController.text,
        'password': _passwordController.text
      }),
    );

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: Colors.indigo,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              //Bill
              Padding(
                padding: const EdgeInsets.only(bottom: 64),
                child: Text(
                  'Bill',
                  style: TextStyle(color: Colors.white, fontSize: 48),
                ),
              ),
              //Card
              Container(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Card(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            //Email
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8, bottom: 16),
                              child: TextFormField(
                                  controller: _emailController,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Colors.pink[400],
                                    ),
                                    border: OutlineInputBorder(),
                                    labelText: 'E-mail',
                                    labelStyle:
                                        TextStyle(color: Colors.black87),
                                    hintText: 'Ex: email@email.com',
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Insira um e-mail';
                                    }

                                    return null;
                                  }),
                            ),
                            //Password
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextFormField(
                                  controller: _passwordController,
                                  obscureText: _hidePassword,
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: Colors.pink[400],
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.remove_red_eye),
                                      onPressed: () {
                                        setState(() {
                                          _hidePassword = !_hidePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(),
                                    labelText: 'Senha',
                                    labelStyle:
                                        TextStyle(color: Colors.black87),
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Insira um e-mail';
                                    }

                                    return null;
                                  }),
                            ),
                            //Save data
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _saveData = !_saveData;
                                  });
                                },
                                child: Row(
                                  children: <Widget>[
                                    Checkbox(
                                        activeColor: Colors.pink[400],
                                        value: _saveData,
                                        onChanged: (_) {
                                          setState(() {
                                            _saveData = !_saveData;
                                          });
                                        }),
                                    Text('Salvar dados')
                                  ],
                                ),
                              ),
                            ),
                            //Login button
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Builder(
                                builder: (context) => ButtonTheme(
                                  minWidth: double.infinity,
                                  child: !_loginButtonDisabled
                                      ? RaisedButton(
                                          color: _loginButtonDisabled
                                              ? Colors.grey
                                              : Colors.pink[400],
                                          child: Text(
                                            'ENTRAR',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          onPressed: () {
                                            if (!_loginButtonDisabled &&
                                                _formKey.currentState
                                                    .validate()) {
                                              setState(() {
                                                _loginButtonDisabled = true;
                                              });
                                              _login().then((res) async {
                                                if (res['error'] == null) {
                                                  var token =
                                                      res['content']['token'];

                                                  final SharedPreferences
                                                      prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  prefs.setString(
                                                      'token', token);

                                                  if (_saveData) {
                                                    prefs.setString('email',
                                                        _emailController.text);
                                                    prefs.setString(
                                                        'password',
                                                        _passwordController
                                                            .text);
                                                  }

                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Home()));
                                                } else {
                                                  final snackBar = SnackBar(
                                                    content:
                                                        Text(res['message']),
                                                  );
                                                  Scaffold.of(context)
                                                      .showSnackBar(snackBar);
                                                  setState(() {
                                                    _loginButtonDisabled =
                                                        false;
                                                  });
                                                }
                                              });
                                            }
                                          },
                                        )
                                      : Loading(
                                          indicator: BallPulseIndicator(),
                                          size: 50,
                                          color: Colors.pink,
                                        ),
                                ),
                              ),
                            ),
                            //Signup button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                FlatButton(
                                  child: Text(
                                    'CADASTRE-SE',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Cadastro()));
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
