import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Artigos extends StatefulWidget {
  @override
  _ArtigosState createState() => _ArtigosState();
}

class _ArtigosState extends State<Artigos> {
  String _token;
  final _futureBuilderKey = GlobalKey<ScaffoldState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<Map<dynamic, dynamic>> _articles;

  Future _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
  }

  Future<Map<dynamic, dynamic>> _getArticles() async {
    http.Response response;
    await _getToken();

    response = await http.get(
        'https://bill-financial-assistant-api.herokuapp.com/articles',
        headers: {HttpHeaders.authorizationHeader: 'Bearer ' + _token});
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
  void initState() {
    super.initState();

    _getToken().then((_) {
      setState(() {
        _articles = _getArticles();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Artigos'),
      ),
      body: FutureBuilder(
        key: _futureBuilderKey,
        future: _articles,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return LiquidPullToRefresh(
                  onRefresh: () async {
                    setState(() {
                      _articles = _getArticles();
                    });
                  },
                  springAnimationDurationInMilliseconds: 600,
                  color: Colors.pink[400],
                  child: ListView.builder(
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
                                    item['img'],
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
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 16),
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
                      }),
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
