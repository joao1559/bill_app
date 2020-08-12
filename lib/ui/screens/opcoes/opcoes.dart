import 'package:bill_app/ui/screens/opcoes/categorias/categorias.dart';
import 'package:bill_app/ui/screens/opcoes/contas/contas.dart';
import 'package:flutter/material.dart';

class Opcoes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Opções'),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 8),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.account_balance),
            title: Text('Contas'),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Contas()));
            },
          ),
          ListTile(
            leading: Icon(Icons.bookmark),
            title: Text('Categorias'),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Categorias()));
            },
          ),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('Metas e Objetivos'),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Agenda'),
          ),
        ],
      ),
    );
  }
}
