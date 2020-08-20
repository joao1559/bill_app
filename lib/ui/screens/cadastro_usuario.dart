import 'package:bill_app/ui/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Cadastro extends StatefulWidget {
  @override
  _CadastroState createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final _nameController = new TextEditingController();
  final _emailController = new TextEditingController();
  final _passwordController = new TextEditingController();
  final _confirmPasswordController = new TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var _hidePassword = true;
  var _hideConfirmPassword = true;

  Future<Map> _signup() async {
    http.Response response = await http.post(
      // 'http://192.168.100.5:3001/auth',
      'https://bill-financial-assistant-api.herokuapp.com/users',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': _emailController.text,
        'password': _passwordController.text,
        'name': _nameController.text,
      }),
    );

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informe seus dados'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                //Nome
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.pink[400],
                          ),
                          border: OutlineInputBorder(),
                          labelText: 'Nome',
                          labelStyle: TextStyle(color: Colors.black87),
                          hintText: 'Ex: John Doe',
                          hintStyle: TextStyle(color: Colors.grey),
                          helperText: 'Informe seu nome completo'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Insira um nome';
                        }

                        return null;
                      }),
                ),
                //Email
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.pink[400],
                          ),
                          border: OutlineInputBorder(),
                          labelText: 'E-mail',
                          labelStyle: TextStyle(color: Colors.black87),
                          hintText: 'Ex: email@email.com',
                          hintStyle: TextStyle(color: Colors.grey),
                          helperText: 'Informe seu e-mail para cadastro'),
                      validator: (value) {
                        RegExp regExp = new RegExp(
                            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");

                        if (value.isEmpty) {
                          return 'Insira um e-mail';
                        } else if (!regExp.hasMatch(value)) {
                          return "Email inválido";
                        }

                        return null;
                      }),
                ),
                //Password
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
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
                        labelStyle: TextStyle(color: Colors.black87),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Insira a senha';
                        }

                        return null;
                      }),
                ),
                //Confirm password
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _hideConfirmPassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.pink[400],
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          onPressed: () {
                            setState(() {
                              _hideConfirmPassword = !_hideConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'Confirme a senha',
                        labelStyle: TextStyle(color: Colors.black87),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Insira a confirmação de senha';
                        }

                        if (value != _passwordController.text)
                          return 'As senhas não são iguais';

                        return null;
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          backgroundColor: Colors.green,
          child: Icon(
            Icons.check,
            color: Colors.white,
          ),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _signup().then((res) async {
                if (res['error'] == null) {
                  var token = res['content']['token'];

                  final SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString('token', token);

                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (context) => Home()));
                } else {
                  final snackBar = SnackBar(
                    content: Text(res['message']),
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                }
              });
            }
          },
        ),
      ),
    );
  }
}
