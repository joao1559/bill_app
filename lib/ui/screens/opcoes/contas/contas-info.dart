import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ContasInfo extends StatefulWidget {
  int _id;

  ContasInfo({int id}) {
    this._id = id;
  }

  @override
  _ContasInfoState createState() => _ContasInfoState(id: _id);
}

class _ContasInfoState extends State<ContasInfo> {
  int _id;
  final _titleController = new TextEditingController();
  final _balanceController = new MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<DropdownMenuItem<Map<dynamic, dynamic>>> _accountTypeItems = [];
  Map _selectedAccountType;
  String _token;
  bool _includeDashboard = false;
  bool _mainAccount = false;
  List<dynamic> _accountTypes;
  bool _active = true;
  bool _loading = true;

  _ContasInfoState({int id}) {
    this._id = id;
  }

  _onChangeDropdownItem(Map selectedAccountType) {
    setState(() {
      _selectedAccountType = selectedAccountType;
    });
  }

  Future _getAccountTypes() async {
    http.Response response;
    await _getToken();

    response = await http.get(
      'https://bill-financial-assistant-api.herokuapp.com/account-types',
      headers: {HttpHeaders.authorizationHeader: 'Bearer ' + _token}
    );
    var body = utf8.decode(response.bodyBytes);
    var res = json.decode(body);

    for(var accountType in res['content']) {
      _accountTypeItems.add(
        DropdownMenuItem(
          value: accountType,
          child: Text(accountType['title']),
        ),
      );
    }

    setState(() {
      _accountTypes = res['content'];
    });
  }

  _getAccountById(int id) async {
    http.Response response;

    response = await http.get(
      'https://bill-financial-assistant-api.herokuapp.com/accounts/' + id.toString(),
      headers: {HttpHeaders.authorizationHeader: 'Bearer ' + _token}
    );
    var body = utf8.decode(response.bodyBytes);
    var res = json.decode(body);

    _titleController.text = res['content']['title'];
    _balanceController.updateValue(double.parse(res['content']['actualBalance'].toString()));
    _includeDashboard = res['content']['includeDashboard'];
    _mainAccount = res['content']['mainAccount'];
    
    for (var item in _accountTypes) {
      if(item['id'] == res['content']['typeID'])
        _selectedAccountType = item;
    }

    setState(() {
      _loading = false;
    });
  }

  _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<Map> _submit() async {
    var balance = _balanceController.numberValue;

    if (_id != null) {
      if(!_loading) {
        http.Response response = await http.put(
          // 'http://192.168.100.5:3001/accounts',
          'https://bill-financial-assistant-api.herokuapp.com/accounts/' + _id.toString(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'authorization': 'Bearer ' + _token
          },
          body: jsonEncode(<String, dynamic>{
            'title': _titleController.text,
            'typeID': _selectedAccountType['id'],
            'includeDashboard': _includeDashboard,
            'mainAccount': _mainAccount,
            'active': _active,
            'actualBalance': balance
          }),
        );

        return json.decode(response.body);
      }
    } else {
      http.Response response = await http.post(
        // 'http://192.168.100.5:3001/accounts',
        'https://bill-financial-assistant-api.herokuapp.com/accounts',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'authorization': 'Bearer ' + _token
        },
        body: jsonEncode(<String, dynamic>{
          'title': _titleController.text,
          'initialBalance': balance,
          'typeID': _selectedAccountType['id'],
          'includeDashboard': _includeDashboard,
          'mainAccount': _mainAccount
        }),
      );

      return json.decode(response.body);
    }
  }

  @override
  void initState() {
    super.initState();

    _getAccountTypes().then((value) {
      if(_id != null) {
        _getAccountById(_id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _id != null ? Text('Alterar Conta') : Text('Nova Conta'),
        actions: <Widget>[
          _id != null ? IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              setState(() {
                _active = false;
              });
              _submit().then((res) {
                if (res == null) {
                  return;
                } else if (res['error'] != null) {
                  final snackBar = SnackBar(
                    content: Text(res['message']),
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                } else {
                  final snackBar = SnackBar(
                    content: Text('Conta deletada com sucesso!'),
                  );

                  Navigator.pop(context, snackBar);
                }
              });
            },
          ) : Container()
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              //title
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                child: TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.pink[400],),
                    border: OutlineInputBorder(),
                    labelText: 'Título',
                    labelStyle: TextStyle(color: Colors.black87),
                    hintText: 'Ex: Santander',
                    hintStyle: TextStyle(color: Colors.grey),
                    helperText: 'Qual o título desta conta'
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Insira um título';
                    }

                    return null;
                  }
                ),
              ),
              //initial value
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _balanceController,
                  decoration: InputDecoration(
                    helperText: 'Qual o saldo',
                    border: OutlineInputBorder(),
                    labelText: 'Saldo',
                    labelStyle: TextStyle(color: Colors.black87),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Insira o saldo';
                    }

                    return null;
                  }
                ),
              ),
              //account type
              DropdownButtonFormField(
                value: _selectedAccountType,
                onChanged: _onChangeDropdownItem,
                items: _accountTypeItems,
                isDense: true,
                decoration: InputDecoration(
                  prefixIcon: _selectedAccountType != null ? Icon(IconData(int.parse(_selectedAccountType['icon']), fontFamily: 'MaterialIcons'), color: Color(int.parse(_selectedAccountType['color'])),) : null,
                  helperText: 'Qual o tipo da conta',
                  border: OutlineInputBorder(),
                  labelText: 'Tipo',
                  labelStyle: TextStyle(color: Colors.black87),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Insira a categoria';
                  }

                  return null;
                }
              ),
              //include on dashboard
              GestureDetector(
                onTap: () {
                  setState(() {
                    _includeDashboard = !_includeDashboard;
                  });
                },
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      activeColor: Colors.pink[400],
                      value: _includeDashboard, 
                      onChanged: (_) {
                        setState(() {
                          _includeDashboard = !_includeDashboard;
                        });
                      }
                    ),
                    Text('Incluir saldo no dashboard')
                  ],
                ),
              ),
              //main account
              GestureDetector(
                onTap: () {
                  setState(() {
                    _mainAccount = !_mainAccount;
                  });
                },
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      activeColor: Colors.pink[400],
                      value: _mainAccount, 
                      onChanged: (_) {
                        setState(() {
                          _mainAccount = !_mainAccount;
                        });
                      }
                    ),
                    Text('Conta principal')
                  ],
                ),
              ),
            ],
          )
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          backgroundColor: Colors.green,
          child: Icon(Icons.check, color: Colors.white,),
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _submit().then((res) {
                if (res == null) {
                  return;
                } else if (res['error'] != null) {
                  final snackBar = SnackBar(
                    content: Text(res['message']),
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                } else {
                  final snackBar = SnackBar(
                    content: Text(_id != null ? 'Conta atualizada com sucesso!' : 'Conta criada com sucesso!'),
                  );

                  Navigator.pop(context, snackBar);
                }
              });
            }
          },
        ),
      ),
    );
  }
}