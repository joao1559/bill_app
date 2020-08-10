import 'package:bill_app/ui/screens/artigos.dart';
import 'package:bill_app/ui/screens/cadastro_movimentacao.dart';
import 'package:bill_app/ui/screens/opcoes/opcoes.dart';
import 'package:bill_app/ui/screens/resumo.dart';
import 'package:bill_app/ui/screens/transacoes.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  IconData _icon = Icons.add;
  int _currentIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _childButtons = [
      SpeedDialChild(
          child: Icon(
            Icons.swap_vert,
            color: Colors.white,
          ),
          backgroundColor: Colors.lightBlue,
          label: 'Transferência',
          onTap: () {}),
      SpeedDialChild(
          child: Icon(
            Icons.trending_up,
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
          label: 'Entrada',
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CadastroMovimentacao(1)));
          }),
      SpeedDialChild(
          child: Icon(
            Icons.trending_down,
            color: Colors.white,
          ),
          backgroundColor: Colors.redAccent,
          label: 'Saída',
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CadastroMovimentacao(2)));
          })
    ];

    return Scaffold(
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            Resumo(),
            Transacoes(),
            Artigos(),
            Opcoes(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
              activeColor: Colors.blue,
              inactiveColor: Colors.blue,
              title: Text('Resumo'),
              icon: Icon(Icons.home)),
          BottomNavyBarItem(
              activeColor: Colors.red,
              inactiveColor: Colors.red,
              title: Text('Transações'),
              icon: Icon(Icons.list)),
          BottomNavyBarItem(
              activeColor: Colors.green,
              inactiveColor: Colors.green,
              title: Text('Artigos'),
              icon: Icon(
                Icons.wb_incandescent,
                color: Colors.green,
              )),
          BottomNavyBarItem(
              activeColor: Colors.black,
              inactiveColor: Colors.black,
              title: Text('Opções'),
              icon: Icon(Icons.more_horiz)),
        ],
      ),
      floatingActionButton: _currentIndex < 2
          ? SpeedDial(
              child: Icon(_icon),
              visible: true,
              closeManually: false,
              onOpen: () {
                setState(() {
                  _icon = Icons.close;
                });
              },
              onClose: () {
                setState(() {
                  _icon = Icons.add;
                });
              },
              curve: Curves.bounceIn,
              overlayColor: Colors.black,
              overlayOpacity: 0.5,
              tooltip: 'Menu',
              heroTag: 'menu',
              backgroundColor: Colors.pink[400],
              foregroundColor: Colors.white,
              elevation: 8.0,
              shape: CircleBorder(),
              children: _childButtons)
          : null,
    );
  }
}
