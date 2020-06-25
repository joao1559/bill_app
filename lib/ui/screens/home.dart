import 'package:bill_app/ui/screens/cadastro_movimentacao.dart';
import 'package:bill_app/ui/screens/opcoes.dart';
import 'package:bill_app/ui/screens/resumo.dart';
import 'package:bill_app/ui/screens/transacoes.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unicorndial/unicorndial.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

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
      UnicornButton(
        hasLabel: true,
        labelText: "Transferência",
        currentButton: FloatingActionButton(
          heroTag: "swap_vert",
          backgroundColor: Colors.lightBlue,
          mini: true,
          child: Icon(
            Icons.swap_vert,
            color: Colors.white,
          ),
          onPressed: () {},
        )
      ),
      UnicornButton(
        hasLabel: true,
        labelText: "Entrada",
        currentButton: FloatingActionButton(
          heroTag: "trending_up",
          backgroundColor: Colors.green,
          mini: true,
          child: Icon(
            Icons.trending_up,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CadastroMovimentacao(1))
            );
          },
        )
      ),
      UnicornButton(
        hasLabel: true,
        labelText: "Saída",
        currentButton: FloatingActionButton(
          heroTag: "trending_down",
          backgroundColor: Colors.redAccent,
          mini: true,
          child: Icon(
            Icons.trending_down,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CadastroMovimentacao(2))
            );
          },
        )
      )
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
            Container(color: Colors.blue,),
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
            icon: Icon(Icons.home)
          ),
          BottomNavyBarItem(
            activeColor: Colors.red,
            inactiveColor: Colors.red,
            title: Text('Transações'),
            icon: Icon(Icons.list)
          ),
          BottomNavyBarItem(
            activeColor: Colors.green,
            inactiveColor: Colors.green,
            title: Text('Artigos'),
            icon: Icon(Icons.wb_incandescent, color: Colors.green,)
          ),
          BottomNavyBarItem(
            activeColor: Colors.black,
            inactiveColor: Colors.black,
            title: Text('Opções'),
            icon: Icon(Icons.more_horiz)
          ),
        ],
      ),
      floatingActionButton: UnicornDialer(
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.6),
        parentButtonBackground: Theme.of(context).accentColor,
        orientation: UnicornOrientation.VERTICAL,
        parentButton: Icon(Icons.add),
        childButtons: _childButtons,
      ),
    );
  }
}
