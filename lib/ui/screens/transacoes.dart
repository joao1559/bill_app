import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class Transacoes extends StatefulWidget {
  @override
  _TransacoesState createState() => _TransacoesState();
}

class _TransacoesState extends State<Transacoes> {
  List<DropdownMenuItem<Map<dynamic, dynamic>>> _months = [];
  List<dynamic> _movements = [];
  Map _selectedMonth;

  String _getDayOfWeekName(int dayOfWeek) {
    String _day;
    switch(dayOfWeek) {
      case 1:
        _day = 'Segunda';
        break;
      case 2:
        _day = 'Terça';
        break;
      case 3:
        _day = 'Quarta';
        break;
      case 4:
        _day = 'Quinta';
        break;
      case 5:
        _day = 'Sexta';
        break;
      case 6:
        _day = 'Sabado';
        break;
      case 7:
        _day = 'Domingo';
        break;
    }

    return _day;
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

  _onChangeDropdownItem(Map selectedMonth) {
    setState(() {
      _selectedMonth = selectedMonth;
    });
  }

  _getMovements() async {
    http.Response response;

    response = await http.get('http://www.mocky.io/v2/5e83c9133000003800cf3fe1');
    var body = utf8.decode(response.bodyBytes);
    var res = json.decode(body);

    _movements = res['records'];
  }

  @override
  void initState() {
    super.initState();
    _getMonths();
    _getMovements();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildMovement(BuildContext context, int index) {
    var dateFormatted = DateTime.parse(_movements[index]['date']);
    List<Widget> movements = [];

    for (var i = 0; i < _movements[index]['movements'].length; i++) {
      var movement = _movements[index]['movements'][i];

      var f = new NumberFormat.simpleCurrency(locale: 'pt_BR', decimalDigits: 2, name: 'R\$');
      var value = f.format(movement['value']);

      movements.add(
        Padding(
          padding: EdgeInsets.fromLTRB(8,8,8,0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      width: 27,
                      height: 27,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(100)),
                        color: Color(movement['color']),
                      ),
                      child: Icon(IconData(movement['category_icon'], fontFamily: 'MaterialIcons'), color: Colors.white, size: 17,),
                    ),
                  ),
                  Container(
                    width: 317,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(movement['description'], style: TextStyle(fontSize: 16),),
                            Text(movement['category_name'], style: TextStyle(color: Colors.grey),),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(value),
                            Text(movement['account_name'], style: TextStyle(color: Colors.grey),),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              (i != (_movements[index]['movements'].length-1)) ? Divider() : Container(),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: 8,bottom: 16),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 8),
              alignment: Alignment.centerLeft,
              child: Text(
                '${_getDayOfWeekName(dateFormatted.weekday)}, ${dateFormatted.day}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            ...movements,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Theme(
            data: Theme.of(context).copyWith(
                canvasColor: Colors.indigo
            ),
            child: DropdownButton(
              items: _months,
              value: _selectedMonth,
              onChanged: _onChangeDropdownItem,
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18
              ),
              hint: Container(
                child: Text('Loading', style: TextStyle(color: Colors.white),),
              ),
              underline: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _movements.length,
        itemBuilder: _buildMovement,
      ),
    );
  }
}
