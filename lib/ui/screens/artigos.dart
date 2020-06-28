import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Artigos extends StatefulWidget {
  @override
  _ArtigosState createState() => _ArtigosState();
}

class _ArtigosState extends State<Artigos> {
  String _token;

  Future _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<Map<dynamic, dynamic>> _getArticles() async {
    http.Response response;
    await _getToken();

    response = await http.get(
      'https://run.mocky.io/v3/f16a245a-b5aa-453f-bc7a-d63c4f09f41b',
      // headers: {HttpHeaders.authorizationHeader: 'Bearer ' + _token}
    );
    var body = utf8.decode(response.bodyBytes);
    return json.decode(body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artigos'),
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
      body: FutureBuilder(
        future: _getArticles(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:          
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return ListView.builder(
                  itemCount: snapshot.data['content'].length,
                  itemBuilder: (context, index) {
                    var item = snapshot.data['content'][index];

                    return Container(
                      child: Card(
                        semanticContainer: true,
                        margin: EdgeInsets.all(16),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Image.network('https://s27389.pcdn.co/wp-content/uploads/2018/11/data-era-1013x440.jpeg'),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                item['title'],
                                style: TextStyle(
                                  fontSize: 24
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16,0,16,16),
                              child: Text(
                                item['description'],
                                maxLines: 5,
                                // textAlign: TextAlign.justify,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  // fontWeight: FontWeight.w300
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                );
              }
              break;
            case ConnectionState.active:
              return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}