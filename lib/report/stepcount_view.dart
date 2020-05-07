import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/fitness_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:wellness/models/healthdata.dart';
import 'package:wellness/models/state_model.dart';

class StepCountChartView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;

  const StepCountChartView({Key key, this.animationController, this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseUser currentUser = ScopedModel.of<StateModel>(context).currentUser;
    double bodyFat = 0;
    int bodyAge = 0;
    double visceralFat = 0;
    String recordDate = 'ไม่มีข้อมูล';

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('monitor')
          .document(currentUser.uid)
          .collection('weightfat')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        try {
          DocumentSnapshot snapshotData = snapshot.data.documents
              .lastWhere((v) => v.data['bodyFat'] != null);

          if (snapshotData != null) {
            HealthMonitor fatData = HealthMonitor.fromSnapshot(snapshotData);
            bodyAge = fatData.bodyAge ?? 0;
            bodyFat = fatData.bodyFat ?? 0;
            visceralFat = fatData.visceralFat ?? 0;
            recordDate = DateFormat.yMMMd().format(fatData.date);
          }
        } catch (e) {
          print(e);
        }
        return AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget child) {
            return FadeTransition(
                opacity: animation,
                child: new Transform(
                  transform: new Matrix4.translationValues(
                      0.0, 30 * (1.0 - animation.value), 0.0),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 8, right: 8, top: 16, bottom: 18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0),
                            topRight: Radius.circular(8.0)),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: AppTheme.grey.withOpacity(0.2),
                              offset: Offset(1.1, 1.1),
                              blurRadius: 10.0),
                        ],
                      ),
                      child: BarChartSample2(),
                      //   child: Column(
                      //     children: <Widget>[
                      //       Padding(
                      //           padding: const EdgeInsets.only(
                      //               left: 24, right: 24, top: 16, bottom: 8),
                      //           child: Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: <Widget>[
                      //                 Counter(
                      //                   color: AppTheme.nearlyDarkBlue,
                      //                   number: bodyFat,
                      //                   title: "Body Fat",
                      //                 ),
                      //                 Counter(
                      //                   color: AppTheme.nearlyDarkBlue,
                      //                   number: visceralFat,
                      //                   title: "Visceral Fat",
                      //                 ),
                      //                 Counter(
                      //                   color: AppTheme.nearlyDarkBlue,
                      //                   number: bodyAge,
                      //                   title: "Body Age",
                      //                 ),
                      //               ])),
                      //       Padding(
                      //         padding: const EdgeInsets.only(
                      //             left: 24, right: 24, top: 8, bottom: 8),
                      //         child: Container(
                      //           height: 2,
                      //           decoration: BoxDecoration(
                      //             color: AppTheme.background,
                      //             borderRadius:
                      //                 BorderRadius.all(Radius.circular(4.0)),
                      //           ),
                      //         ),
                      //       ),
                      //       Padding(
                      //         padding: const EdgeInsets.only(
                      //             left: 24, right: 24, top: 0, bottom: 16),
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.start,
                      //           children: <Widget>[
                      //             Icon(
                      //               Icons.access_time,
                      //               color: AppTheme.grey.withOpacity(0.5),
                      //               size: 16,
                      //             ),
                      //             Padding(
                      //               padding: const EdgeInsets.only(left: 4.0),
                      //               child: Text(
                      //                 recordDate,
                      //                 textAlign: TextAlign.center,
                      //                 style: TextStyle(
                      //                   fontFamily: AppTheme.fontName,
                      //                   fontWeight: FontWeight.w500,
                      //                   fontSize: 14,
                      //                   letterSpacing: 0.0,
                      //                   color: AppTheme.grey.withOpacity(0.5),
                      //                 ),
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ),
                  ),
                ));
          },
        );
      },
    );
  }

  int weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}

class BarChartSample2 extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => BarChartSample2State();
}

class BarChartSample2State extends State<BarChartSample2> {
  final Color leftBarColor = Colors.orange;
  final Color rightBarColor = const Color(0xffff5182);
  final double width = 15;

  List<BarChartGroupData> rawBarGroups;
  List<BarChartGroupData> showingBarGroups;

  int touchedGroupIndex;

  @override
  void initState() {
    super.initState();
    final barGroup1 = makeGroupData(0, 5, 12);
    final barGroup2 = makeGroupData(1, 16, 12);
    final barGroup3 = makeGroupData(2, 18, 5);
    final barGroup4 = makeGroupData(3, 20, 16);
    final barGroup5 = makeGroupData(4, 17, 6);
    final barGroup6 = makeGroupData(5, 19, 1.5);
    final barGroup7 = makeGroupData(6, 10, 1.5);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
      barGroup4,
      barGroup5,
      barGroup6,
      barGroup7,
    ];

    rawBarGroups = items;

    showingBarGroups = rawBarGroups;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: BarChart(
                  BarChartData(
                    maxY: 20,
                    barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.grey,
                          getTooltipItem: (_a, _b, _c, _d) => null,
                        ),
                        touchCallback: (response) {
                          if (response.spot == null) {
                            setState(() {
                              touchedGroupIndex = -1;
                              showingBarGroups = List.of(rawBarGroups);
                            });
                            return;
                          }

                          touchedGroupIndex =
                              response.spot.touchedBarGroupIndex;

                          setState(() {
                            if (response.touchInput is FlLongPressEnd ||
                                response.touchInput is FlPanEnd) {
                              touchedGroupIndex = -1;
                              showingBarGroups = List.of(rawBarGroups);
                            } else {
                              showingBarGroups = List.of(rawBarGroups);
                              if (touchedGroupIndex != -1) {
                                double sum = 0;
                                for (BarChartRodData rod
                                    in showingBarGroups[touchedGroupIndex]
                                        .barRods) {
                                  sum += rod.y;
                                }
                                final avg = sum /
                                    showingBarGroups[touchedGroupIndex]
                                        .barRods
                                        .length;

                                showingBarGroups[touchedGroupIndex] =
                                    showingBarGroups[touchedGroupIndex]
                                        .copyWith(
                                  barRods: showingBarGroups[touchedGroupIndex]
                                      .barRods
                                      .map((rod) {
                                    return rod.copyWith(y: avg);
                                  }).toList(),
                                );
                              }
                            }
                          });
                        }),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: SideTitles(
                        showTitles: true,
                        textStyle: TextStyle(
                            color: const Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        margin: 10,
                        getTitles: (double value) {
                          switch (value.toInt()) {
                            case 0:
                              return 'Sn';
                            case 1:
                              return 'Mn';
                            case 2:
                              return 'Te';
                            case 3:
                              return 'Wd';
                            case 4:
                              return 'Tu';
                            case 5:
                              return 'Fr';
                            case 6:
                              return 'Sa';
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
                        margin: 20,
                        reservedSize: 14,
                        getTitles: (value) {
                          if (value == 0) {
                            return '1K';
                          } else if (value == 10) {
                            return '5K';
                          } else if (value == 19) {
                            return '10K';
                          } else {
                            return '';
                          }
                        },
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: showingBarGroups,
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
    );
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        y: y1,
        color: leftBarColor,
        width: width,
      ),
      // BarChartRodData(
      //   y: y2,
      //   color: rightBarColor,
      //   width: width,
      // ),
    ]);
  }
}
