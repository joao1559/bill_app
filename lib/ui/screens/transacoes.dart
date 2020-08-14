import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Transacoes extends StatefulWidget {
  @override
  _TransacoesState createState() => _TransacoesState();
}

class _TransacoesState extends State<Transacoes> {
  List<DropdownMenuItem<Map<dynamic, dynamic>>> _months = [];
  List<dynamic> _movements = [];
  Map _selectedMonth;
  String _token;
  int _actualYear = DateTime.now().year;
  int _actualMonth = DateTime.now().month;

  _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  _getMonths() {
    String payload =
        '{"records": [{"id": 1,"name": "Janeiro"},{"id": 2,"name": "Fevereiro"},{"id": 3,"name": "Março"},{"id": 4,"name": "Abril"},{"id": 5,"name": "Maio"},{"id": 6,"name": "Junho"},{"id": 7,"name": "Julho"},{"id": 8,"name": "Agosto"},{"id": 9,"name": "Setembro"},{"id": 10,"name": "Outubro"},{"id": 11,"name": "Novembro"},{"id": 12,"name": "Dezembro"}]}';

    var items = json.decode(payload);

    for (var month in items['records']) {
      if (month['id'] == _actualMonth) {
        setState(() {
          _selectedMonth = month;
        });
      }

      _months.add(
        DropdownMenuItem(
          value: month,
          child: Text(month['name']),
        ),
      );
    }
  }

  _onChangeDropdownItem(Map selectedMonth) {
    setState(() {
      _selectedMonth = selectedMonth;
    });

    _getMovements();
  }

  _getMovements() async {
    http.Response response;
    var _selectedMonthID = _selectedMonth['id'].toString();

    _selectedMonthID = _selectedMonthID.padLeft(2, '0');

    response = await http.post(
      'https://bill-financial-assistant-api.herokuapp.com/transactions-search',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'authorization': 'Bearer ' + _token
      },
      body: jsonEncode(
          <String, dynamic>{'date': '$_selectedMonthID/$_actualYear'}),
    );
    var body = utf8.decode(response.bodyBytes);
    var res = json.decode(body);

    setState(() {
      _movements = res['content'];
    });
  }

  Future<void> _refresh() async {
    _getMovements();
  }

  @override
  void initState() {
    super.initState();

    _getToken().then((_) {
      _getMonths();
      _getMovements();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildMovement(BuildContext context, int index) {
    var dateFormatted = _movements[index]['transactionDate'];
    List<Widget> movements = [];

    for (var i = 0; i < _movements[index]['transactions'].length; i++) {
      var movement = _movements[index]['transactions'][i];

      var f = new NumberFormat.simpleCurrency(
          locale: 'pt_BR', decimalDigits: 2, name: 'R\$');
      var value = f.format(movement['value']);

      movements.add(
        Column(
          children: <Widget>[
            ListTile(
              title: Text(movement['description']),
              subtitle: Text(movement['categoryTitle']),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                  color: Color(int.parse(movement['categoryColor'])),
                ),
                child: Icon(
                  IconData(int.parse(movement['categoryIcon']),
                      fontFamily: 'MaterialIcons'),
                  color: Colors.white,
                  size: 17,
                ),
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    value,
                    style: TextStyle(
                        color:
                            movement['value'] > 0 ? Colors.green : Colors.red),
                  ),
                  Text(movement['accountTitle'],
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Divider(
              thickness: 1,
              indent: 70,
            )
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              dateFormatted,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
          ...movements,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
            child: Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.indigo),
              child: DropdownButton(
                items: _months,
                value: _selectedMonth,
                onChanged: _onChangeDropdownItem,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                style: TextStyle(color: Colors.white, fontSize: 18),
                hint: Container(
                  child: Text(
                    'Loading',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                underline: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          // actions: <Widget>[
          //   IconButton(
          //     icon: Icon(Icons.search),
          //     onPressed: () {},
          //   ),
          //   IconButton(
          //     icon: Icon(Icons.filter_list),
          //     onPressed: () {},
          //   ),
          // ],
        ),
        body: _movements.length > 0
            ? LiquidPullToRefresh(
                onRefresh: _refresh,
                showChildOpacityTransition: false,
                springAnimationDurationInMilliseconds: 600,
                color: Colors.pink[400],
                child: ListView.builder(
                  itemCount: _movements.length,
                  itemBuilder: _buildMovement,
                ),
              )
            : Center(
                child: Text('Você não possui transações nesse periodo...'),
              ));
  }
}
