import 'dart:io';
import 'package:bill_app/ui/screens/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Resumo extends StatefulWidget {
  @override
  _ResumoState createState() => _ResumoState();
}

class _ResumoState extends State<Resumo> {
  List<DropdownMenuItem<Map<dynamic, dynamic>>> _months = [];
  List<Padding> _accounts = [];
  Map _selectedMonth;
  String _totalBalance = '-';
  String _token;

  _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  _getMonths() async {
    http.Response response;

    response = await http.get('http://www.mocky.io/v2/5e8150b83000002c006f96cf');
    var body = utf8.decode(response.bodyBytes);
    var items = json.decode(body);

    setState(() {
      _selectedMonth = items['records'][0];
    });

    for (var month in items['records']) {
      _months.add(
        DropdownMenuItem(
          value: month,
          child: Text(month['name']),
        ),
      );
    }
  }

 _getAccounts() async {
    http.Response response;

    response = await http.get(
      'https://bill-financial-assistant-api.herokuapp.com/accounts?includeDashboard=true&active=true',
      headers: {HttpHeaders.authorizationHeader: 'Bearer ' + _token}
    );
    
    var body = utf8.decode(response.bodyBytes);
    var items = json.decode(body);
    var formatter =  new NumberFormat.currency(
      decimalDigits: 2,
      symbol: 'R\$',
      locale: 'pt_BR'
    );

    var totalBalanceInt = items['content']['totalBalance'];
    _totalBalance = formatter.format(totalBalanceInt);

    for (var month in items['content']['accounts']) {
      var balance = month['actualBalance'];
      

      balance = formatter.format(balance);

      _accounts.add(
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(month['title']),
              Text(balance),
            ],
          ),
        )
      );
    }

    if(_accounts.isEmpty) {
      _accounts.add(
        Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Você não possui contas cadastradas...'),
            ],
          ),
        )
      );
    }
  }

  _onChangeDropdownItem(Map selectedMonth) {
    setState(() {
      _selectedMonth = selectedMonth;
    });
  }

  @override
  void initState() {
    super.initState();

    _getToken().then((_) {
      _getMonths();
      _getAccounts().then((_) {
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.exit_to_app, color: Colors.white,),
                  onPressed: () async {
                    var prefs = await SharedPreferences.getInstance();
                    prefs.remove('email');
                    prefs.remove('password');

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Login())
                    );
                  },
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(top: 30),
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Text(
              _totalBalance,
              style: TextStyle(
                  fontSize: 42,
                  color: Colors.white
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(bottom: 25),
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: Text(
              'Saldo atual em contas',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                Card(
                  key: UniqueKey(),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: 350,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Resumo de contas',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        ..._accounts
                      ],
                    ),
                  ),
                ),
                Card(
                  key: UniqueKey(),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: 350,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Balanço mensal',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Entradas', style: TextStyle(color: Colors.green),),
                              Text('R\$ 1.000,00', style: TextStyle(color: Colors.green),),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Saídas', style: TextStyle(color: Colors.red),),
                              Text('R\$ 500,00', style: TextStyle(color: Colors.red),),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 2,

                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text('Total'),
                              Text('R\$ 500,00'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  key: UniqueKey(),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: 350,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Metas e objetivos',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Container(
                                  width: 27,
                                  height: 27,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(100)),
                                    color: Colors.blue,
                                  ),
                                  child: Icon(Icons.directions_car, color: Colors.white, size: 17,),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 283,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('Carro novo'),
                                        Text('50.00%', style: TextStyle(color: Colors.grey),)
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 5,
                                    width: 283,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        stops: [0.5, 0.5],
                                        colors: [Colors.blue, Colors.grey]
                                      )
                                    ),
                                  ),
                                  Container(
                                    width: 283,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text('R\$ 16.000,00', style: TextStyle(color: Colors.grey)),
                                        Text('/', style: TextStyle(color: Colors.grey)),
                                        Text('R\$ 32.000,00', style: TextStyle(color: Colors.grey))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Container(
                                  width: 27,
                                  height: 27,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(100)),
                                    color: Colors.red,
                                  ),
                                  child: Icon(Icons.local_atm, color: Colors.white, size: 17,),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 283,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text('Fundo emergêncial'),
                                        Text('67.00%', style: TextStyle(color: Colors.grey),)
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 5,
                                    width: 283,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                          stops: [0.67, 0.33],
                                          colors: [Colors.blue, Colors.grey]
                                      )
                                    ),
                                  ),
                                  Container(
                                    width: 283,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Text('R\$ 6.700,00', style: TextStyle(color: Colors.grey)),
                                        Text('/', style: TextStyle(color: Colors.grey)),
                                        Text('R\$ 10.000,00', style: TextStyle(color: Colors.grey))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  key: UniqueKey(),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: 350,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Text(
                            'Agenda',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Container(
                                  width: 27,
                                  height: 27,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(100)),
                                    color: Colors.blue,
                                  ),
                                  child: Center(child: Text('09', style: TextStyle(color: Colors.white),)),
                                ),
                              ),
                              Text('Faculdade'),
                              Container(
                                width: 218,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      width: 70,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(100)),
                                        color: Colors.green,
                                      ),
                                      child: Center(child: Text('Pago', style: TextStyle(color: Colors.white),))
                                    ),
                                    Text('R\$ 32.000,00', style: TextStyle(color: Colors.grey))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Container(
                                  width: 27,
                                  height: 27,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular(100)),
                                    color: Colors.deepPurple,
                                  ),
                                  child: Center(child: Text('22', style: TextStyle(color: Colors.white),)),
                                ),
                              ),
                              Text('Parcela carro'),
                              Container(
                                width: 200,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Container(
                                      width: 70,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(Radius.circular(100)),
                                        color: Colors.red,
                                      ),
                                      child: Center(child: Text('Atrasado', style: TextStyle(color: Colors.white),))
                                    ),
                                    Text('R\$ 32.000,00', style: TextStyle(color: Colors.grey))
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}
