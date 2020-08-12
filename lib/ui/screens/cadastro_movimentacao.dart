import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CadastroMovimentacao extends StatefulWidget {
  int _entradaSaida;

  CadastroMovimentacao(entradaSaida) {
    this._entradaSaida = entradaSaida;
  }

  @override
  _CadastroMovimentacaoState createState() =>
      _CadastroMovimentacaoState(_entradaSaida);
}

class _CadastroMovimentacaoState extends State<CadastroMovimentacao> {
  int _entradaSaida;
  List<DropdownMenuItem<Map<dynamic, dynamic>>> _categoryItems = [];
  List<DropdownMenuItem<Map<dynamic, dynamic>>> _accountItems = [];
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map _selectedCategory;
  Map _selectedAccount;
  String _token;

  final _valorController = new MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');
  final _dateController = new MaskedTextController(mask: '00/00/0000');
  final _descricaoController = new TextEditingController();

  _CadastroMovimentacaoState(entradaSaida) {
    this._entradaSaida = entradaSaida;
  }

  _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  _getCategories() async {
    http.Response response;

    response = await http.get(
        'https://bill-financial-assistant-api.herokuapp.com/categories?type=' +
            (_entradaSaida == 1 ? 'I' : 'E'),
        headers: {HttpHeaders.authorizationHeader: 'Bearer ' + _token});

    var body = utf8.decode(response.bodyBytes);
    var res = json.decode(body);

    for (var category in res['content']) {
      _categoryItems.add(
        DropdownMenuItem(
          value: category,
          child: Text(category['title']),
        ),
      );
    }

    setState(() {});
  }

  _getAccounts() async {
    http.Response response;

    response = await http.get(
        'https://bill-financial-assistant-api.herokuapp.com/accounts?active=true',
        headers: {HttpHeaders.authorizationHeader: 'Bearer ' + _token});

    var body = utf8.decode(response.bodyBytes);
    var res = json.decode(body);

    for (var account in res['content']['accounts']) {
      _accountItems.add(
        DropdownMenuItem(
          value: account,
          child: Text(account['title']),
        ),
      );
    }

    setState(() {});
  }

  Future<Map> _submit() async {
    var value = _valorController.numberValue;
    var dateList = _dateController.text.split('/');
    var date = dateList.reversed.join('-');

    http.Response response = await http.post(
      'https://bill-financial-assistant-api.herokuapp.com/transactions',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Bearer ' + _token
      },
      body: jsonEncode(<String, dynamic>{
        "accountID": _selectedAccount['id'],
        "categoryID": _selectedCategory['id'],
        "value": value,
        "description": _descricaoController.text,
        "date": date
      }),
    );

    return json.decode(response.body);
  }

  @override
  void initState() {
    super.initState();

    _getToken().then((_) {
      _getCategories();
      _getAccounts();
    });
  }

  _onChangeDropdownItem(Map selectedCategory) {
    setState(() {
      _selectedCategory = selectedCategory;
    });
  }

  _onChangeAccount(Map selectedAccount) {
    setState(() {
      _selectedAccount = selectedAccount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _entradaSaida == 1 ? Text('Nova entrada') : Text('Nova saída'),
        backgroundColor: _entradaSaida == 1 ? Colors.green : Colors.red,
        elevation: 0,
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          child: Icon(
            Icons.check,
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
          onPressed: () {
            if (_formKey.currentState.validate()) {
              _submit().then((res) {
                if (res == null) {
                  return;
                } else if (res['error'] != null) {
                  final snackBar = SnackBar(
                    content: Text(res['message']),
                  );
                  _scaffoldKey.currentState.showSnackBar(snackBar);
                } else {
                  final snackBar = SnackBar(
                    content: Text('Transação criada com sucesso!'),
                  );

                  Navigator.pop(context, snackBar);
                }
              });
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          color: Colors.white,
          child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _valorController,
                        decoration: InputDecoration(
                          helperText: _entradaSaida == 1
                              ? 'Informe o valor recebido'
                              : 'Informe o valor gasto',
                          border: OutlineInputBorder(),
                          labelText: 'Valor',
                          labelStyle: TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          var valueParsed = double.parse(value
                              .replaceAll('R\$ ', '')
                              .replaceAll(',', '.'));

                          if (valueParsed <= 0) {
                            return 'Insira o valor';
                          }

                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _dateController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(Icons.date_range),
                            onPressed: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2018),
                                lastDate: DateTime.now(),
                              ).then((selectedDate) {
                                if (selectedDate != null) {
                                  _dateController.text =
                                      DateFormat('dd/MM/yyyy')
                                          .format(selectedDate);
                                }
                              });
                            },
                          ),
                          helperText: 'Informe a data em que ocorreu o evento',
                          border: OutlineInputBorder(),
                          labelText: 'Data',
                          labelStyle: TextStyle(color: Colors.black87),
                          hintText: 'Ex: 01/01/2000',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Insira a data';
                          }

                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: _descricaoController,
                        decoration: InputDecoration(
                          suffixIcon: Icon(Icons.create),
                          helperText: 'Informe uma descrição do evento',
                          border: OutlineInputBorder(),
                          labelText: 'Descrição',
                          labelStyle: TextStyle(color: Colors.black87),
                          hintText: 'Ex: Jantar',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Insira a descrição';
                          }

                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField(
                        value: _selectedCategory,
                        onChanged: _onChangeDropdownItem,
                        items: _categoryItems,
                        isDense: true,
                        decoration: InputDecoration(
                          prefixIcon: _selectedCategory != null
                              ? Icon(
                                  IconData(int.parse(_selectedCategory['icon']),
                                      fontFamily: 'MaterialIcons'),
                                  color: Color(
                                      int.parse(_selectedCategory['color'])),
                                )
                              : null,
                          helperText: 'Informe a categoria do evento',
                          border: OutlineInputBorder(),
                          labelText: 'Categoria',
                          labelStyle: TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Insira a categoria';
                          }

                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField(
                        value: _selectedAccount,
                        onChanged: _onChangeAccount,
                        items: _accountItems,
                        isDense: true,
                        decoration: InputDecoration(
                          prefixIcon: _selectedAccount != null
                              ? Icon(
                                  IconData(int.parse(_selectedAccount['icon']),
                                      fontFamily: 'MaterialIcons'),
                                  color: Color(
                                      int.parse(_selectedAccount['color'])),
                                )
                              : null,
                          helperText: 'Informe a conta do evento',
                          border: OutlineInputBorder(),
                          labelText: 'Conta',
                          labelStyle: TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Insira a conta';
                          }

                          return null;
                        }),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
