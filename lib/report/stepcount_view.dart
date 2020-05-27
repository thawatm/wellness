import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:wellness/widgets/weeklybar_chart.dart';

class StepCountChartView extends StatelessWidget {
  final DateTime startDate;
  final QuerySnapshot snapshot;

  const StepCountChartView({Key key, this.startDate, this.snapshot})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 18),
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
        child: WeeklyBarChart(
          snapshot: snapshot,
          startDate: startDate,
          value: 'steps',
          barColor: Colors.orange,
          scale: 2000,
          unit: ' ก้าว',
        ),
        // child: BarChartSample1(),
      ),
    );
  }
}
