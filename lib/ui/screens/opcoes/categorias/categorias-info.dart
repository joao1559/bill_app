import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '0x' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class CategoriasInfo extends StatefulWidget {
  int _id;
  String _type;

  CategoriasInfo({int id, String type}) {
    this._id = id;
    this._type = type;
  }

  @override
  _CategoriasInfoState createState() => _CategoriasInfoState(_id, _type);
}

class _CategoriasInfoState extends State<CategoriasInfo> {
  final _titleController = new TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Color _pickerColor = Color(0xff443a49);
  Color _currentColor = Color(0xff443a49);
  String _token;
  int _id;
  Icon _icon;
  bool isAdaptive = true;
  bool _loading = true;
  bool _active = true;
  String _type;

  _CategoriasInfoState(int id, String type) {
    this._id = id;
    this._type = type;
  }

  _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  _pickIcon() async {
    IconData icon = await FlutterIconPicker.showIconPicker(context,
        adaptiveDialog: isAdaptive,
        iconPickerShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        iconPackMode: IconPack.material,
        title: Text('Escolha um icone'));

    if (icon != null) {
      setState(() {
        _icon = Icon(icon);
      });
    }
  }

  _showColorPicker() {
    void changeColor(Color color) {
      setState(() => _pickerColor = color);
    }

    showDialog(
      context: context,
      child: AlertDialog(
        title: const Text('Escolha uma cor!'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _currentColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: <Widget>[
          FlatButton(
            child: const Text('ESCOLHER'),
            onPressed: () {
              setState(() => _currentColor = _pickerColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  _getCategoriaById(int id) async {
    http.Response response;

    response = await http.get(
        'https://bill-financial-assistant-api.herokuapp.com/categories/' +
            id.toString(),
        headers: {HttpHeaders.authorizationHeader: 'Bearer ' + _token});
    var body = utf8.decode(response.bodyBytes);
    var res = json.decode(body);

    _titleController.text = res['content']['title'];
    _currentColor = Color(int.parse(res['content']['color']));
    _icon = Icon(IconData(int.parse(res['content']['icon']),
        fontFamily: 'MaterialIcons'));
    _type = res['content']['type'];
    _active = res['content']['active'];

    setState(() {
      _loading = false;
    });
  }

  Future<Map> _submit() async {
    if (_id != null) {
      if (!_loading) {
        http.Response response = await http.put(
          // 'http://192.168.100.5:3001/accounts',
          'https://bill-financial-assistant-api.herokuapp.com/categories/' +
              _id.toString(),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'authorization': 'Bearer ' + _token
          },
          body: jsonEncode(<String, dynamic>{
            "title": _titleController.text,
            "type": _type,
            "color": _currentColor.toHex(),
            "icon": _icon.icon.codePoint.toString(),
            "active": _active
          }),
        );

        return json.decode(response.body);
      }
    } else {
      if (_icon == null) {
        final snackBar = SnackBar(
          content: Text('Selecione um icone'),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      } else {
        http.Response response = await http.post(
          // 'http://192.168.100.5:3001/accounts',
          'https://bill-financial-assistant-api.herokuapp.com/categories',
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'authorization': 'Bearer ' + _token
          },
          body: jsonEncode(<String, dynamic>{
            "title": _titleController.text,
            "type": _type,
            "color": _currentColor.toHex(),
            "icon": _icon.icon.codePoint.toString()
          }),
        );

        return json.decode(response.body);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _getToken().then((_) {
      if (_id != null) {
        _getCategoriaById(_id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_id != null ? 'Alterar categoria' : 'Cadastrar categoria'),
        backgroundColor: _type == 'I' ? Colors.green : Colors.red,
        actions: [
          _id != null
              ? IconButton(
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
                )
              : Container()
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
                          border: OutlineInputBorder(),
                          labelText: 'Título',
                          labelStyle: TextStyle(color: Colors.black87),
                          hintText: 'Ex: Supermercado, Salário...',
                          hintStyle: TextStyle(color: Colors.grey),
                          helperText: 'Qual o título desta categoria'),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Insira um título';
                        }

                        return null;
                      }),
                ),
                //color
                ListTile(
                  title: Text('Cor'),
                  subtitle: Text('Cor de fundo do icone da categoria'),
                  onTap: _showColorPicker,
                  trailing: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      color: Color(int.parse(_currentColor.toHex())),
                    ),
                  ),
                ),
                ListTile(
                  title: Text('Icone'),
                  subtitle: Text('Icone da categoria'),
                  onTap: _pickIcon,
                  trailing: _icon,
                ),
              ],
            )),
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
                  print(res);
                  final snackBar = SnackBar(
                    content: Text(res['message']),
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                } else {
                  final snackBar = SnackBar(
                    content: Text(_id != null
                        ? 'Categoria atualizada com sucesso!'
                        : 'Categoria criada com sucesso!'),
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
