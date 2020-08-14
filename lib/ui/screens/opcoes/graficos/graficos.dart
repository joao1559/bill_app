import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

final List<List<CircularStackEntry>> _quarterlyProfitPieData = [
  <CircularStackEntry>[
    new CircularStackEntry(
      <CircularSegmentEntry>[
        new CircularSegmentEntry(600.0, Colors.red, rankKey: 'Q1'),
        new CircularSegmentEntry(800.0, Colors.green, rankKey: 'Q2'),
        new CircularSegmentEntry(2000.0, Colors.blue, rankKey: 'Q3'),
        new CircularSegmentEntry(1600.0, Colors.yellow, rankKey: 'Q4'),
      ],
      rankKey: 'Quarterly Profits',
    ),
  ],
];

class Graficos extends StatefulWidget {
  @override
  _GraficosState createState() => _GraficosState();
}

class ClicksPerYear {
  final String year;
  final double clicks;
  final charts.Color color;

  ClicksPerYear(this.year, this.clicks, Color color)
      : this.color = charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

class _GraficosState extends State<Graficos> {
  final GlobalKey<AnimatedCircularChartState> _chartKey =
      new GlobalKey<AnimatedCircularChartState>();
  final _chartSize = const Size(300.0, 300.0);
  int sampleIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Gráficos'),
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Container(
                padding: EdgeInsets.all(16),
                child: Text('BALANÇO MENSAL'),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Text('GASTO CATEGORIAS'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Gastos
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.green,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 16),
                            child: Text('Ganhos'),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.red,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 16),
                            child: Text('Gastos'),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(32.0),
                        child: SizedBox(
                          height: 350.0,
                          child: charts.BarChart(
                            [
                              charts.Series(
                                domainFn: (dynamic clickData, _) =>
                                    clickData.year,
                                measureFn: (dynamic clickData, _) =>
                                    clickData.clicks,
                                colorFn: (dynamic clickData, _) =>
                                    clickData.color,
                                id: 'Clicks',
                                data: [
                                  ClicksPerYear('Jul', 1800, Colors.green),
                                  ClicksPerYear('Ago', 4000, Colors.green),
                                  ClicksPerYear('Set', 4800, Colors.green),
                                ],
                              ),
                              charts.Series(
                                domainFn: (dynamic clickData, _) =>
                                    clickData.year,
                                measureFn: (dynamic clickData, _) =>
                                    clickData.clicks,
                                colorFn: (dynamic clickData, _) =>
                                    clickData.color,
                                id: 'Clicks',
                                data: [
                                  ClicksPerYear('Jul', 1200, Colors.red),
                                  ClicksPerYear('Ago', 3000, Colors.red),
                                  ClicksPerYear('Set', 1000, Colors.red),
                                ],
                              ),
                            ],
                            animate: true,
                            barGroupingType: charts.BarGroupingType.grouped,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Ganhos
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: new AnimatedCircularChart(
                    key: _chartKey,
                    size: _chartSize,
                    initialChartData: _quarterlyProfitPieData[0],
                    chartType: CircularChartType.Pie,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.blue,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'Educação',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'R\$ 2.000,00',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '(40%)',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.yellow,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'Transporte',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'R\$ 1.600,00',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '(32%)',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.green,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'Casa',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'R\$ 800,00',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '(16%)',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(100)),
                              color: Colors.red,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'Contas',
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              'R\$ 600,00',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '(12%)',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
