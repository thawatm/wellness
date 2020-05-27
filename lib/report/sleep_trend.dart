import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/sleepdata.dart';
import 'package:wellness/widgets/bar_chart.dart';
import 'package:wellness/widgets/first_load.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import "package:collection/collection.dart";

class SleepTrendChart extends StatefulWidget {
  const SleepTrendChart({Key key, this.snapshot}) : super(key: key);

  final QuerySnapshot snapshot;
  @override
  _SleepTrendChartState createState() => _SleepTrendChartState();
}

class _SleepTrendChartState extends State<SleepTrendChart> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DocumentSnapshot> snapshotData;

  DateTime selectedDate;
  DateTime startTime;
  DateTime endTime;
  DateTime today;
  int chartDays = 5;
  Map<String, dynamic> monitorData = {
    'date': DateTime.now(),
  };

  final Map<int, Widget> chartPeriod = const <int, Widget>{
    5: Text('สัปดาห์'),
    30: Text('เดือน'),
    365: Text('ปี'),
    99999: Text('ทั้งหมด'),
  };

  List<charts.Series<SleepMonitor, DateTime>> _chartData() {
    List<SleepMonitor> sleepData = snapshotData
        .map((data) => SleepMonitor.fromSnapshot(data))
        .toList()
          ..removeWhere((v) => today.difference(v.date).inDays > chartDays);

    if (sleepData.isNotEmpty) {
      sleepData = groupBy(sleepData, (obj) => obj.dateString)
          .map((k, v) => MapEntry(k, v.reduce((a, b) {
                a.sleepHours = a.sleepHours + b.sleepHours;
                return a;
              })))
          .values
          .toList();

      return [
        new charts.Series<SleepMonitor, DateTime>(
          id: 'ชั่วโมงนอน',
          colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
          domainFn: (SleepMonitor sleep, _) =>
              DateTime(sleep.date.year, sleep.date.month, sleep.date.day),
          measureFn: (SleepMonitor sleep, _) => sleep.sleepHours,
          data: sleepData,
        )
      ];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    if (widget.snapshot != null) snapshotData = widget.snapshot.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: GradientAppBar(
        title: Text('การนอน'),
        gradient: LinearGradient(
            colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
      ),
      body:
          snapshotData.isEmpty ? FirstLoad(title: "ไม่มีข้อมูล") : _buildBody(),
    );
  }

  _buildBody() {
    return ListView(children: <Widget>[
      SizedBox(
        height: 72,
        child: CupertinoSegmentedControl<int>(
          children: chartPeriod,
          selectedColor: Colors.blueAccent,
          borderColor: Colors.blueAccent,
          onValueChanged: (int newValue) {
            setState(() {
              chartDays = newValue;
            });
          },
          groupValue: chartDays,
        ),
      ),
      Container(
        height: 220,
        child:
            TimeSeriesBar(_chartData(), animate: true, unit: 'ชั่วโมงการนอน'),
      ),
    ]);
  }
}
