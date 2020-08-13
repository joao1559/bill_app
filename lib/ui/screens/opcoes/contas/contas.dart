import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:bill_app/ui/screens/opcoes/contas/contas-info.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Contas extends StatefulWidget {
  @override
  _ContasState createState() => _ContasState();
}

class _ContasState extends State<Contas> {
  String _token;
  double _totalBalance;
  String _totalBalanceFormatted;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<Map> _getAccounts() async {
    http.Response response;
    await _getToken();

    response = await http.get(
        'https://bill-financial-assistant-api.herokuapp.com/accounts?active=true',
        headers: {HttpHeaders.authorizationHeader: 'Bearer ' + _token});

    var bodyStr = utf8.decode(response.bodyBytes);
    var body = json.decode(bodyStr);
    return body['content'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Contas'),
      ),
      body: FutureBuilder(
        future: _getAccounts(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                var formatter = new NumberFormat.currency(
                    decimalDigits: 2, symbol: 'R\$', locale: 'pt_BR');

                _totalBalance =
                    double.parse(snapshot.data['totalBalance'].toString());
                _totalBalanceFormatted = formatter.format(_totalBalance);

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: snapshot.data['accounts'].length > 0
                          ? ListView.builder(
                              itemCount: snapshot.data['accounts'].length,
                              itemBuilder: (context, index) {
                                var item = snapshot.data['accounts'][index];
                                var balance =
                                    formatter.format(item['actualBalance']);
                                var icon = int.parse(item['icon']);

                                return Column(
                                  children: <Widget>[
                                    ListTile(
                                      leading: Container(
                                        width: 35,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(100)),
                                          color:
                                              Color(int.parse(item['color'])),
                                        ),
                                        child: Icon(
                                          IconData(icon,
                                              fontFamily: 'MaterialIcons'),
                                          color: Colors.white,
                                          size: 25,
                                        ),
                                      ),
                                      title: Text(item['title']),
                                      subtitle: Text(item['typeTitle']),
                                      trailing: Text(
                                        balance,
                                        style: TextStyle(
                                            color: item['actualBalance'] >= 0
                                                ? Colors.green
                                                : Colors.red),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ContasInfo(
                                                      id: item['id'],
                                                    ))).then((value) {
                                          if (value != null) {
                                            setState(() {
                                              _scaffoldKey.currentState
                                                  .showSnackBar(value);
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
                              },
                            )
                          : Center(
                              child: Text('Você não possui contas ativas...'),
                            ),
                    ),
                    Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                            'Saldo atual',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            _totalBalanceFormatted ?? '-',
                            style: TextStyle(
                                color:
                                    _totalBalance != null && _totalBalance >= 0
                                        ? Colors.green
                                        : Colors.red,
                                fontSize: 17),
                          ),
                        ],
                      ),
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration:
                          BoxDecoration(color: Colors.white, boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0),
                          blurRadius: 6.0,
                        )
                      ]),
                    ),
                  ],
                );
              }
              break;
            case ConnectionState.active:
              return CircularProgressIndicator();
              break;
          }
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: Builder(
          builder: (context) => FloatingActionButton(
            backgroundColor: Colors.pink[400],
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ContasInfo()))
                  .then((value) {
                if (value != null) {
                  setState(() {
                    Scaffold.of(context).showSnackBar(value);
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
