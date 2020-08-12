import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
      'https://run.mocky.io/v3/9fee0e4b-1bcb-4620-847e-fc66df83a73d',
      // headers: {HttpHeaders.authorizationHeader: 'Bearer ' + _token}
    );
    var body = utf8.decode(response.bodyBytes);
    return json.decode(body);
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
                          child: InkWell(
                            onTap: () {
                              _launchURL(item['url']);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Image.network(
                                  'https://neogrid-site.s3.amazonaws.com/uploads/blog/2016/04/big-data.jpg',
                                  fit: BoxFit.fitWidth,
                                  height: 150,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text(
                                    item['title'],
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
                        ),
                      );
                    });
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
