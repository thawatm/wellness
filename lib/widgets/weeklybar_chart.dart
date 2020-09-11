import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:wellness/dashboard/app_theme.dart';

class WeeklyBarChart extends StatelessWidget {
  final QuerySnapshot snapshot;
  final DateTime startDate;
  final int scale;
  final String date;
  final String value;
  final Color barColor;
  final String unit;
  WeeklyBarChart({
    Key key,
    this.snapshot,
    this.startDate,
    this.date: 'date',
    this.value,
    this.barColor,
    this.scale: 2000,
    this.unit: '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: AppTheme.nearlyPurple,
                          tooltipPadding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                          tooltipBottomMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                                (rod.y).round().toString() + unit,
                                TextStyle(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.bold));
                          }),
                    ),
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
                              return 'Sun';
                            case 1:
                              return 'Mon';
                            case 2:
                              return 'Tue';
                            case 3:
                              return 'Wed';
                            case 4:
                              return 'Thu';
                            case 5:
                              return 'Fri';
                            case 6:
                              return 'Sat';
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
                          reservedSize: 20,
                          getTitles: (value) {
                            if (value % scale == 0)
                              return value.round().toString();
                            return '';
                          }),
                    ),
                    gridData: FlGridData(
                      show: true,
                      checkToShowHorizontalLine: (value) => value % scale == 0,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: const Color(0xffe7e8ec),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups:
                        buildWeeklyData(snapshot, date, value, startDate),
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

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    Color barColor = Colors.orange,
    double width = 16,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          y: y,
          color: barColor,
          width: width,
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> buildWeeklyData(
      QuerySnapshot snapshot, String date, String value, DateTime startDate) {
    List<BarChartGroupData> barGroup =
        List.generate(7, (i) => makeGroupData(i, 0));

    try {
      DateTime s = DateTime.now();
      if (startDate != null) s = startDate;
      List<DocumentSnapshot> snapshotData = snapshot.docs.where((v) {
        DateTime d = v.data()[date].toDate();
        return v.data()[value] != null &&
            Jiffy(d).week == Jiffy(s).week &&
            Jiffy(d).year == Jiffy(s).year;
      }).toList();

      if (snapshotData != null) {
        var data = snapshotData.map((v) {
          return {
            'day': Jiffy(v.data()[date].toDate()).day,
            'value': v.data()[value]
          };
        });
        groupBy(data, (obj) => obj['day']).forEach((k, v) {
          num sum = v.fold(0, (a, b) {
            if (b['value'] is String) return a + num.parse(b['value']);
            return a + b['value'];
          });
          int i = k - 1;
          barGroup[i] = makeGroupData(i, sum.toDouble(), barColor: barColor);
        });
        return barGroup;
      }
    } catch (e) {
      print(e);
    }
    return barGroup;
  }
}
