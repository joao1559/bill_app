import 'dart:convert';

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
  _CadastroMovimentacaoState createState() => _CadastroMovimentacaoState(_entradaSaida);
}

class _CadastroMovimentacaoState extends State<CadastroMovimentacao> {
  int _entradaSaida;
  int _userId;
  List<DropdownMenuItem<Map<dynamic, dynamic>>> _categoryItems = [];
  Map _selectedCategory;

  final _valorController = new MoneyMaskedTextController(decimalSeparator: ',', thousandSeparator: '.', leftSymbol: 'R\$ ');
  final _dateController = new MaskedTextController(mask: '00/00/0000');
  final _descricaoController = new TextEditingController();


  _CadastroMovimentacaoState(entradaSaida) {
    this._entradaSaida = entradaSaida;
  }

  void _getUserId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id');
  }

  _getCategories() async {
    http.Response response;

    response = await http.get('http://www.mocky.io/v2/5e83eb503000008400cf4048');
    var body = utf8.decode(response.bodyBytes);
    var res = json.decode(body);

    for(var category in res['records']) {
      _categoryItems.add(
        DropdownMenuItem(
          value: category,
          child: Text(category['name']),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _getUserId();
    _getCategories();
  }

  _onChangeDropdownItem(Map selectedCategory) {
    setState(() {
      _selectedCategory = selectedCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _entradaSaida == 1 ? Text('Nova entrada') : Text('Nova saída'),
        backgroundColor: _entradaSaida == 1 ? Colors.green : Colors.red,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check, color: Colors.white,),
        backgroundColor: Colors.green,
        onPressed: () {
          print(_categoryItems);
        },
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.white,
        child: Form(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _valorController,
                  decoration: InputDecoration(
                    helperText: _entradaSaida == 1 ? 'Informe o valor recebido' : 'Informe o valor gasto',
                    border: OutlineInputBorder(),
                    labelText: 'Valor',
                    labelStyle: TextStyle(color: Colors.black87),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Insira o valor';
                    }

                    return null;
                  }
                ),
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
                          _dateController.text = DateFormat('dd/MM/yyyy').format(selectedDate);
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
                  }
                ),
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
                  }
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: DropdownButtonFormField(
                  value: _selectedCategory,
                  onChanged: _onChangeDropdownItem,
                  items: _categoryItems,
                  isDense: true,
                  decoration: InputDecoration(
                    prefixIcon: _selectedCategory != null ? Icon(IconData(_selectedCategory['icon'], fontFamily: 'MaterialIcons'), color: Color(_selectedCategory['color']),) : null,
                    helperText: 'Informe a categoria do evento',
                    border: OutlineInputBorder(),
                    labelText: 'Categoria',
                    labelStyle: TextStyle(color: Colors.black87),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Insira a categoria';
                    }

                    return null;
                  }
                ),
              ),
            ],
          )
        ),
      ),
    );
  }
}
