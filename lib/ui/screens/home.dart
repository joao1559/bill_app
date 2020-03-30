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
          heroTag: "train",
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
          onPressed: () {},
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
          onPressed: () {},
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
            Container(color: Colors.green,),
            Container(color: Colors.blue,),
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
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Colors.blue,
            title: Text('Item One'),
            icon: Icon(Icons.home)
          ),
          BottomNavyBarItem(
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Colors.blue,
            title: Text('Item One'),
            icon: Icon(Icons.apps)
          ),
          BottomNavyBarItem(
            activeColor:Theme.of(context).primaryColor,
            inactiveColor: Colors.blue,
            title: Text('Item One'),
            icon: Icon(Icons.chat_bubble)
          ),
          BottomNavyBarItem(
            activeColor: Theme.of(context).primaryColor,
            inactiveColor: Colors.blue,
            title: Text('Item One'),
            icon: Icon(Icons.settings)
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
