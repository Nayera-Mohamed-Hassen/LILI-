import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:progress_bar_chart/progress_bar_chart.dart';

class AnalysisPage extends StatefulWidget {
  const AnalysisPage({Key? key}) : super(key: key);

  @override
  AnalysisPageState createState() => AnalysisPageState();
}

class AnalysisPageState extends State<AnalysisPage> {
  double totalMoney = 60000;
  double totalSpent = 40000; // Remaining amount

  final dataMap = <String, double>{
    "Food": 10,
    "Clothing": 8,
    "Education": 6,
    "Sports": 7,
    "Entertainment": 5,
    "Fuel": 5,
    "Others": 9,
  };

  final colorList = <Color>[
    const Color(0xfffdcb6e),
    Colors.blue,
    const Color(0xfffd79a8),
    const Color(0xffe17055),
    const Color(0xff6c5ce7),
    Colors.green,
    const Color(0xfff39c12),
    const Color(0xffe74c3c),
    const Color(0xff2ecc71),
    const Color(0xff9b59b6),
  ];

  bool _showChartValues = true;
  bool _showChartValuesInPercentage = true;
  bool _showChartValuesOutside = true;

  double _ringStrokeWidth = 25;

  @override
  Widget build(BuildContext context) {
    final chart = PieChart(
      dataMap: dataMap,
      animationDuration: const Duration(milliseconds: 800),
      chartRadius: math.min(MediaQuery.of(context).size.width / 3.2, 300),
      colorList: colorList,
      chartType: ChartType.ring,
      ringStrokeWidth: _ringStrokeWidth,
      chartValuesOptions: ChartValuesOptions(
        showChartValues: _showChartValues,
        showChartValuesInPercentage: _showChartValuesInPercentage,
        showChartValuesOutside: _showChartValuesOutside,
      ),
      legendOptions: LegendOptions(
        showLegends: true,
        legendPosition: LegendPosition.right,
        legendShape: BoxShape.circle,
        legendTextStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
      baseChartColor: Colors.transparent,
      emptyColor: Colors.grey,
    );

    double totalLeft = totalMoney - totalSpent;

    List<StatisticsItem> stats = [
      StatisticsItem(Colors.blue, totalSpent / totalMoney),
      StatisticsItem(Colors.green, totalLeft / totalMoney),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF213555),
        iconTheme: const IconThemeData(color: Colors.white),
      ),s

      body: Column(
        children: [
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 50),
                Row(
                  children: [
                    SizedBox(width: 15),
                    Text(
                      "You have spent ",
                      style: TextStyle(
                        color: Color(0xFF213555),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "\$${totalSpent} ",
                      style: TextStyle(
                        color: Color(0xffff9c18),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "this month ",
                      style: TextStyle(
                        color: Color(0xFF213555),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SizedBox(width: 15),
                    Text(
                      "You have ",
                      style: TextStyle(
                        color: Color(0xFF213555),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "\$${totalMoney - totalSpent} ",
                      style: TextStyle(
                        color: Color(0xffff9c18),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "left of this month's budget",
                      style: TextStyle(
                        color: Color(0xFF213555),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 30,
                  child: ProgressBarChart(
                    values: stats,
                    height: 30,
                    borderRadius: 20,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
          Row(
            children: [
              SizedBox(width: 20),
              Text(
                "Total Expenses",
                style: TextStyle(
                  color: Color(0xFF213555),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          LayoutBuilder(
            builder: (_, constraints) {
              if (constraints.maxWidth >= 600) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(flex: 3, fit: FlexFit.tight, child: chart),
                    Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Container(), // You can add settings here if needed
                    ),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 32),
                        child: chart,
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}
