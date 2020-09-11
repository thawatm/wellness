import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/waterdata.dart';
import 'package:wellness/widgets/bar_chart.dart';
import 'package:wellness/widgets/first_load.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class WaterTrendChart extends StatefulWidget {
  const WaterTrendChart({Key key, this.snapshot}) : super(key: key);

  final QuerySnapshot snapshot;
  @override
  _WaterTrendChartState createState() => _WaterTrendChartState();
}

class _WaterTrendChartState extends State<WaterTrendChart> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DocumentSnapshot> snapshotData;

  List<WaterMonitor> todayData;

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

  List<charts.Series<WaterMonitor, DateTime>> _chartData() {
    List<WaterMonitor> waterData = snapshotData
        .map((data) => WaterMonitor.fromSnapshot(data))
        .toList()
          ..removeWhere((v) => today.difference(v.date).inDays > chartDays);

    if (waterData.isNotEmpty) {
      waterData = groupBy(waterData, (obj) => obj.dateString)
          .map((k, v) => MapEntry(k, v.reduce((a, b) {
                a.waterVolume = a.waterVolume + b.waterVolume;
                return a;
              })))
          .values
          .toList();

      return [
        new charts.Series<WaterMonitor, DateTime>(
          id: 'ปริมาณน้ำ',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (WaterMonitor water, _) =>
              DateTime(water.date.year, water.date.month, water.date.day),
          measureFn: (WaterMonitor water, _) => water.waterVolume,
          data: waterData,
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
    initData();
  }

  initData() {
    if (widget.snapshot != null) {
      snapshotData = widget.snapshot.docs;

      todayData = snapshotData
          .map((data) => WaterMonitor.fromSnapshot(data))
          .where((v) => (DateFormat.yMd().format(v.date) ==
              (DateFormat.yMd().format(monitorData['date']))))
          .toList();
    }
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
      body: snapshotData.isEmpty
          ? FirstLoad(title: "ไม่มีข้อมูล")
          : _buildHistoryChart(),
      // _buildHistory(),
    );
  }

  Widget _buildHistoryChart() {
    return ListView(children: <Widget>[
      SizedBox(
        height: 72,
        child: CupertinoSegmentedControl<int>(
          children: chartPeriod,
          selectedColor: AppTheme.buttonColor,
          borderColor: AppTheme.buttonColor,
          onValueChanged: (int newValue) {
            setState(() {
              chartDays = newValue;
            });
          },
          groupValue: chartDays,
        ),
      ),
      Container(
        height: 300,
        child: TimeSeriesBar(_chartData(), animate: true, unit: 'ปริมาณน้ำ ml'),
      ),
    ]);
  }
}
