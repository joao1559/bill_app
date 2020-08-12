import 'dart:convert';

import 'package:bill_app/ui/screens/opcoes/categorias/categorias-info.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Categorias extends StatefulWidget {
  @override
  _CategoriasState createState() => _CategoriasState();
}

class _CategoriasState extends State<Categorias> {
  String _token;
  List<dynamic> _expenseCategories = [];
  List<dynamic> _incomeCategories = [];
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<ScaffoldState> _tabsKey = GlobalKey<ScaffoldState>();

  _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future _getExpenseCategories() async {
    http.Response response;

    response = await http.get(
        'https://bill-financial-assistant-api.herokuapp.com/categories?type=E',
        headers: <String, String>{'authorization': 'Bearer ' + _token});

    var body = utf8.decode(response.bodyBytes);
    var res = json.decode(body);

    setState(() {
      _expenseCategories = res['content'];
    });
  }

  Future _getIncomeCategories() async {
    http.Response response;

    response = await http.get(
        'https://bill-financial-assistant-api.herokuapp.com/categories?type=I',
        headers: <String, String>{'authorization': 'Bearer ' + _token});

    var body = utf8.decode(response.bodyBytes);
    var res = json.decode(body);

    setState(() {
      _incomeCategories = res['content'];
    });
  }

  @override
  void initState() {
    super.initState();

    _getToken().then((_) {
      _getExpenseCategories();
      _getIncomeCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      key: _tabsKey,
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Categorias'),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Container(
                padding: EdgeInsets.all(16),
                child: Text('GASTOS'),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Text('GANHOS'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.builder(
                itemCount: _expenseCategories.length,
                itemBuilder: (context, index) {
                  var item = _expenseCategories[index];
                  return Column(
                    children: <Widget>[
                      ListTile(
                        leading: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                            color: Color(int.parse(item['color'])),
                          ),
                          child: Icon(
                            IconData(int.parse(item['icon']),
                                fontFamily: 'MaterialIcons'),
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        title: Text(item['title']),
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CategoriasInfo(id: item['id'])))
                              .then((value) {
                            if (value != null) {
                              _getExpenseCategories();
                              _getIncomeCategories();

                              setState(() {
                                _scaffoldKey.currentState.showSnackBar(value);
                              });
                            }
                          });
                        },
                      ),
                      Divider(
                        indent: 70,
                        thickness: 1,
                      )
                    ],
                  );
                }),
            ListView.builder(
                itemCount: _incomeCategories.length,
                itemBuilder: (context, index) {
                  var item = _incomeCategories[index];
                  return Column(
                    children: <Widget>[
                      ListTile(
                        leading: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                            color: Color(int.parse(item['color'])),
                          ),
                          child: Icon(
                            IconData(int.parse(item['icon']),
                                fontFamily: 'MaterialIcons'),
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        title: Text(item['title']),
                        onTap: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CategoriasInfo(id: item['id'])))
                              .then((value) {
                            if (value != null) {
                              _getExpenseCategories();
                              _getIncomeCategories();
                              setState(() {
                                _scaffoldKey.currentState.showSnackBar(value);
                              });
                            }
                          });
                        },
                      ),
                      Divider(
                        indent: 70,
                        thickness: 1,
                      )
                    ],
                  );
                }),
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Colors.pink[400],
            onPressed: () {
              var index = DefaultTabController.of(context).index;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CategoriasInfo(
                            type: index > 0 ? 'I' : 'E',
                          ))).then((value) {
                if (value != null) {
                  _getExpenseCategories();
                  _getIncomeCategories();
                  setState(() {
                    _scaffoldKey.currentState.showSnackBar(value);
                  });
                }
              });
            },
          ),
        ),
      ),
    );
  }
}
