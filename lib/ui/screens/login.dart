import 'package:bill_app/ui/screens/cadastro_usuario.dart';
import 'package:bill_app/ui/screens/home.dart';
import 'package:flutter/material.dart';
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
  var _hidePassword = true;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<Map> _login() async {
    http.Response response = await http.post(
        // 'http://192.168.100.5:3001/auth',
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48
                ),
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
                            padding: const EdgeInsets.only(top: 16,bottom: 16),
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person, color: Colors.pink[400],),
                                border: OutlineInputBorder(),
                                labelText: 'E-mail',
                                labelStyle: TextStyle(color: Colors.black87),
                                hintText: 'Ex: email@email.com',
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Insira um e-mail';
                                }

                                return null;
                              }
                            ),
                          ),
                          //Password
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: _hidePassword,
                              decoration: InputDecoration(
                                prefixIcon: Icon(Icons.lock, color: Colors.pink[400],),
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
                                labelStyle: TextStyle(color: Colors.black87),
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Insira um e-mail';
                                }

                                return null;
                              }
                            ),
                          ),
                          //Login button
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: ButtonTheme(
                              minWidth: double.infinity,
                              child: RaisedButton(  
                                color: Colors.pink[400],
                                child: Text('ENTRAR', style: TextStyle(color: Colors.white),),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _login().then((res) async {
                                      if(res['error'] == null) {
                                        var token = res['content']['token'];

                                        final SharedPreferences prefs = await SharedPreferences.getInstance();
                                        prefs.setString('token', token);

                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => Home())
                                        );
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          //Signup button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              FlatButton(
                                child: Text('CADASTRE-SE', style: TextStyle(color: Colors.blue),),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => Cadastro())
                                  );
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
        )
      ),
    );
  }
}