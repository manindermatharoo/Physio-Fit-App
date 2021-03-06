import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:physio_tracker_app/widgets/shared/app_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:physio_tracker_app/constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:physio_tracker_app/models/completed_exercise.dart';
import 'package:physio_tracker_app/screens/results/resultDetail.dart';
import 'package:physio_tracker_app/screens/results/resultDetail2.dart';
import 'package:physio_tracker_app/widgets/shared/defaultPageRoute.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class Result extends StatefulWidget {
  const Result({Key key, @required this.exercise}) : super(key: key);
  final CompletedExercise exercise;
  @override
  _Result createState() => _Result();
}

class _Result extends State<Result> {
  final Color leftBarColor = const Color(0xff53fdd7);
  final Color rightBarColor = const Color.fromRGBO(3, 127, 252, 1.0);
  final double width = 14;
  List<BarChartGroupData> rawBarGroups;
  List<BarChartGroupData> showingBarGroups;

  List<BarChartGroupData> rawBarGroupsSecondDay;
  List<BarChartGroupData> showingBarGroupsSecondDay;

  int touchedGroupIndex;
  bool _rememberMe = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(barsSpace: 4, x: x, showingTooltipIndicators: [
      0,
      1
    ], barRods: [
      BarChartRodData(
        y: y1,
        color: leftBarColor,
        width: width,
      ),
      BarChartRodData(
        y: y2,
        color: rightBarColor,
        width: width,
      ),
    ]);
  }

  @override
  void initState() {
    super.initState();
    print('hello im here');
    var items = <BarChartGroupData>[];

    for (int i = 0; i < widget.exercise.correct_reps_h.length; i++) {
      double correct_percentage =
          ((widget.exercise.correct_reps_h[i].toDouble() +
                      widget.exercise.correct_reps_k[i].toDouble() +
                      widget.exercise.correct_reps_s[i].toDouble()) /
                  (widget.exercise.attempted_h[i] +
                      widget.exercise.attempted_k[i] +
                      widget.exercise.attempted_s[i])) *
              100;
      double attempt_percentage =
          (widget.exercise.total_reps_array[i].toDouble() /
                  widget.exercise.total_reps) *
              100;
      if (widget.exercise.correct_reps_h[i].toDouble() == 0) {
        items.add(makeGroupData(0, 0.0, 0.0));
      } else {
        items.add(makeGroupData(0, correct_percentage, attempt_percentage));
      }
    }

    rawBarGroups = items;
    showingBarGroups = rawBarGroups;

    var itemsSecondDay = <BarChartGroupData>[];

    for (int i = 0; i < widget.exercise.correct_reps_h_2.length; i++) {
      double correct_percentage =
          ((widget.exercise.correct_reps_h_2[i].toDouble() +
                      widget.exercise.correct_reps_k_2[i].toDouble() +
                      widget.exercise.correct_reps_s_2[i].toDouble()) /
                  (widget.exercise.attempted_h_2[i] +
                      widget.exercise.attempted_k_2[i] +
                      widget.exercise.attempted_s_2[i])) *
              100;
      double attempt_percentage =
          (widget.exercise.total_reps_array_2[i].toDouble() /
                  widget.exercise.total_reps) *
              100;
      if (widget.exercise.correct_reps_h_2[i].toDouble() == 0) {
        itemsSecondDay.add(makeGroupData(0, 0.0, 0.0));
      } else {
        itemsSecondDay
            .add(makeGroupData(0, correct_percentage, attempt_percentage));
      }
    }

    rawBarGroupsSecondDay = itemsSecondDay;
    showingBarGroupsSecondDay = rawBarGroupsSecondDay;
  }

  Widget _appBar() {
    return AppBar(
      title: Text(
        'Results',
        style: TextStyle(
          color: const Color.fromRGBO(160, 187, 227, 1.0),
          fontFamily: 'OpenSans',
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xff2c4260),
      elevation: 0.0,
      leading: IconButton(
        iconSize: 40,
        icon: Icon(Icons.chevron_left),
        onPressed: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
      ),
    );
  }

  Widget graphScreen(String title, List<BarChartGroupData> raw,
      List<BarChartGroupData> showing) {
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: const Color(0xff2c4260),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.99,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1)),
              color: const Color(0xff2c4260),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: BarChart(
                          BarChartData(
                            maxY: 115,
                            barTouchData: BarTouchData(
                                touchTooltipData: BarTouchTooltipData(
                                  tooltipBgColor: Colors.transparent,
                                  tooltipPadding: const EdgeInsets.all(0),
                                  tooltipBottomMargin: 4,
                                  getTooltipItem: (
                                    BarChartGroupData group,
                                    int groupIndex,
                                    BarChartRodData rod,
                                    int rodIndex,
                                  ) {
                                    return BarTooltipItem(
                                      rod.y.round().toString(),
                                      TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                                touchCallback: (response) {
                                  if (response.spot == null) {
                                    setState(() {
                                      touchedGroupIndex = -1;
                                      showingBarGroups = List.of(raw);
                                    });
                                    return;
                                  }

                                  touchedGroupIndex =
                                      response.spot.touchedBarGroupIndex;
                                  //touchedGroupIndex = response.spot.touchedBarGroupIndex;
                                  if (title ==
                                      'Weekly Summary: March 16 - 20') {
                                    Navigator.of(context).push<dynamic>(
                                        DefaultPageRoute<dynamic>(
                                            pageRoute: ResultDetail2(
                                      exercise: widget.exercise,
                                      index: touchedGroupIndex,
                                    )));
                                  } else {
                                    Navigator.of(context).push<dynamic>(
                                        DefaultPageRoute<dynamic>(
                                            pageRoute: ResultDetail(
                                      exercise: widget.exercise,
                                      index: touchedGroupIndex,
                                    )));
                                  }
                                }),
                            axisTitleData: FlAxisTitleData(
                              show: true,
                              bottomTitle: AxisTitle(
                                showTitle: true,
                                titleText: 'Day',
                                textStyle: TextStyle(
                                    color: const Color.fromRGBO(
                                        160, 187, 227, 1.0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                                textAlign: TextAlign.center,
                              ),
                              leftTitle: AxisTitle(
                                showTitle: true,
                                titleText: 'Percentage (%)',
                                margin: 20,
                                textStyle: TextStyle(
                                    color: const Color.fromRGBO(
                                        160, 187, 227, 1.0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                              topTitle: AxisTitle(
                                showTitle: true,
                                titleText: title,
                                margin: -10,
                                textStyle: TextStyle(
                                    color: const Color.fromRGBO(
                                        160, 187, 227, 1.0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: SideTitles(
                                showTitles: true,
                                textStyle: TextStyle(
                                    color: const Color(0xff7589a2),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                                margin: 20,
                                getTitles: (double value) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return 'Mon';
                                    case 1:
                                      return 'Tue';
                                    case 2:
                                      return 'Wed';
                                    case 3:
                                      return 'Thu';
                                    case 4:
                                      return 'Fri';
                                    case 5:
                                      return 'Sat';
                                    case 6:
                                      return 'Sun';
                                    default:
                                      return '';
                                  }
                                },
                              ),
                              leftTitles: SideTitles(
                                showTitles: true,
                                textStyle: TextStyle(
                                    color: const Color(0xff7589a2),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                                reservedSize: 14,
                                getTitles: (value) {
                                  if (value == 0) {
                                    return '0';
                                  } else if (value == 5) {
                                    return '5';
                                  } else if (value == 10) {
                                    return '10';
                                  } else if (value == 15) {
                                    return '15';
                                  } else if (value == 20) {
                                    return '20';
                                  } else if (value == 25) {
                                    return '25';
                                  } else if (value == 30) {
                                    return '30';
                                  } else if (value == 35) {
                                    return '35';
                                  } else if (value == 40) {
                                    return '40';
                                  } else if (value == 45) {
                                    return '45';
                                  } else if (value == 50) {
                                    return '50';
                                  } else if (value == 55) {
                                    return '55';
                                  } else if (value == 60) {
                                    return '60';
                                  } else if (value == 65) {
                                    return '65';
                                  } else if (value == 70) {
                                    return '70';
                                  } else if (value == 75) {
                                    return '75';
                                  } else if (value == 80) {
                                    return '80';
                                  } else if (value == 85) {
                                    return '85';
                                  } else if (value == 90) {
                                    return '90';
                                  } else if (value == 95) {
                                    return '95';
                                  } else if (value == 100) {
                                    return '100';
                                  } else {
                                    return '';
                                  }
                                },
                              ),
                            ),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            barGroups: showing,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            child: Padding(
                padding: EdgeInsets.fromLTRB(
                    MediaQuery.of(context).size.width * 0.15, 0.0, 0.0, 0.0),
                child: Container(
                    height: 50,
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 3,
                          color: const Color.fromRGBO(160, 187, 227, 1.0),
                          style: BorderStyle.solid),
                      borderRadius: const BorderRadius.all(Radius.circular(40)),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0.0),
                        child: Row(
                          children: <Widget>[
                            Center(
                                child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                        color: Color(0xff53fdd7),
                                        shape: BoxShape.rectangle))),
                            const SizedBox(width: 10.0),
                            const Center(
                                child: Text(
                              'Accuracy',
                              style: TextStyle(
                                color: Color.fromRGBO(160, 187, 227, 1.0),
                                fontFamily: 'OpenSans',
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            const SizedBox(width: 10.0),
                            const Center(
                                child: Text(
                              '|',
                              style: TextStyle(
                                color: Color.fromRGBO(160, 187, 227, 1.0),
                                fontFamily: 'OpenSans',
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            const SizedBox(width: 10.0),
                            Center(
                                child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                        color: Color.fromRGBO(3, 127, 252, 1.0),
                                        shape: BoxShape.rectangle))),
                            const SizedBox(width: 10.0),
                            const Center(
                                child: Text(
                              'Completion',
                              style: TextStyle(
                                color: Color.fromRGBO(160, 187, 227, 1.0),
                                fontFamily: 'OpenSans',
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                          ],
                        )))),
            //Center(child: Text("Hello"))))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        graphScreen('Weekly Summary: March 16 - 20', rawBarGroupsSecondDay,
            showingBarGroupsSecondDay),
        graphScreen(
            'Weekly Summary: March 23 - 27', rawBarGroups, showingBarGroups),
      ],
    );
  }
}

class Day {
  final int reps;
  final String date; // 3/15

  Day(this.reps, this.date);
}
