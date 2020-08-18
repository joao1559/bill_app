import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CadastroTransferencia extends StatefulWidget {
  @override
  _CadastroTransferenciaState createState() => _CadastroTransferenciaState();
}

class _CadastroTransferenciaState extends State<CadastroTransferencia> {
  List<DropdownMenuItem<Map<dynamic, dynamic>>> _accountItems = [];
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map _selectedAccountDe;
  Map _selectedAccountPara;
  String _token;

  final _valorController = new MoneyMaskedTextController(
      decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');
  final _dateController = new MaskedTextController(mask: '00/00/0000');
  final _descricaoController = new TextEditingController();

  _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
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
        "accountID": _selectedAccountDe['id'],
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
      _getAccounts();
    });
  }

  _onChangeAccountDe(Map selectedAccount) {
    setState(() {
      _selectedAccountDe = selectedAccount;
    });
  }

  _onChangeAccountPara(Map selectedAccount) {
    setState(() {
      _selectedAccountPara = selectedAccount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Nova transferencia'),
        backgroundColor: Colors.blue,
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
                          helperText: 'Informe o valor transferido',
                          border: OutlineInputBorder(),
                          labelText: 'Valor',
                          labelStyle: TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          var valueParsed = double.parse(value
                              .replaceAll('R\$ ', '')
                              .replaceAll('.', '')
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
                        value: _selectedAccountDe,
                        onChanged: _onChangeAccountDe,
                        items: _accountItems,
                        isDense: true,
                        decoration: InputDecoration(
                          prefixIcon: _selectedAccountDe != null
                              ? Icon(
                                  IconData(
                                      int.parse(_selectedAccountDe['icon']),
                                      fontFamily: 'MaterialIcons'),
                                  color: Color(
                                      int.parse(_selectedAccountDe['color'])),
                                )
                              : null,
                          helperText: 'Informe a conta do evento',
                          border: OutlineInputBorder(),
                          labelText: 'De',
                          labelStyle: TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Insira a conta';
                          }

                          return null;
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: DropdownButtonFormField(
                        value: _selectedAccountPara,
                        onChanged: _onChangeAccountPara,
                        items: _accountItems,
                        isDense: true,
                        decoration: InputDecoration(
                          prefixIcon: _selectedAccountPara != null
                              ? Icon(
                                  IconData(
                                      int.parse(_selectedAccountPara['icon']),
                                      fontFamily: 'MaterialIcons'),
                                  color: Color(
                                      int.parse(_selectedAccountPara['color'])),
                                )
                              : null,
                          helperText: 'Informe a conta do evento',
                          border: OutlineInputBorder(),
                          labelText: 'Para',
                          labelStyle: TextStyle(color: Colors.black87),
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Insira a conta';
                          }

                          if (value['id'] == _selectedAccountDe['id'])
                            return 'As contas de origem e destino são iguais';

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
