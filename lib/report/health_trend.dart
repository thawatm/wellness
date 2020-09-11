import 'package:charts_flutter/flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/healthdata.dart';
import 'package:wellness/widgets/chart.dart';
import 'package:wellness/widgets/first_load.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:wellness/models/state_model.dart';
import 'package:wellness/widgets/chart_title.dart';

class HealthTrendChart extends StatefulWidget {
  const HealthTrendChart({Key key, this.snapshot}) : super(key: key);

  final QuerySnapshot snapshot;
  @override
  _HealthTrendChartState createState() => _HealthTrendChartState();
}

class _HealthTrendChartState extends State<HealthTrendChart> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String uid;
  List<DocumentSnapshot> healthData;
  List<HealthMonitor> pressureData;
  List<HealthMonitor> weightData;
  List<HealthMonitor> glucoseData;
  List<HealthMonitor> cholesterolData;
  List<HealthMonitor> ldlData;
  List<HealthMonitor> hba1cData;

  int chartDays = 99999;

  DateTime today;
  String collection = 'healthdata';

  final Map<int, Widget> chartPeriod = const <int, Widget>{
    5: Text('สัปดาห์'),
    30: Text('เดือน'),
    365: Text('ปี'),
    99999: Text('ทั้งหมด'),
  };

  @override
  void initState() {
    super.initState();
    uid = ScopedModel.of<StateModel>(context).uid;
    DateTime now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    initData();
  }

  initData() {
    if (widget.snapshot != null) {
      healthData = widget.snapshot.docs
        ..sort((a, b) =>
            b.data()['date'].toDate().compareTo(a.data()['date'].toDate()));

      // PRESSURE DATA
      pressureData = healthData
          .map((data) => HealthMonitor.fromSnapshot(data))
          .toList()
            ..removeWhere((v) => today.difference(v.date).inDays > chartDays)
            ..removeWhere((v) => v.pressureUpper == null)
            ..removeWhere((v) => v.pressureLower == null);
      // Weight DATA
      weightData = healthData
          .map((data) => HealthMonitor.fromSnapshot(data))
          .toList()
            ..removeWhere((v) => today.difference(v.date).inDays > chartDays)
            ..removeWhere((v) => v.weight == null);
      // Sugar DATA
      glucoseData = healthData
          .map((data) => HealthMonitor.fromSnapshot(data))
          .toList()
            ..removeWhere((v) => today.difference(v.date).inDays > chartDays)
            ..removeWhere((v) => v.glucose == null);

      // cholesterol DATA
      cholesterolData = healthData
          .map((data) => HealthMonitor.fromSnapshot(data))
          .toList()
            ..removeWhere((v) => today.difference(v.date).inDays > chartDays)
            ..removeWhere((v) => v.cholesterol == null);

      // LDL DATA
      ldlData = healthData
          .map((data) => HealthMonitor.fromSnapshot(data))
          .toList()
            ..removeWhere((v) => today.difference(v.date).inDays > chartDays)
            ..removeWhere((v) => v.ldl == null);
      // LDL DATA
      hba1cData = healthData
          .map((data) => HealthMonitor.fromSnapshot(data))
          .toList()
            ..removeWhere((v) => today.difference(v.date).inDays > chartDays)
            ..removeWhere((v) => v.hba1c == null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      appBar: GradientAppBar(
        title: Text('ข้อมูลสุขภาพ'),
        gradient: LinearGradient(
            colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
      ),
      body:
          healthData.isEmpty ? FirstLoad(title: "ไม่มีข้อมูล") : _buildChart(),
    );
  }

  Widget _buildChart() {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 72,
          child: CupertinoSegmentedControl<int>(
            children: chartPeriod,
            selectedColor: AppTheme.buttonColor,
            borderColor: AppTheme.buttonColor,
            onValueChanged: (int newValue) {
              setState(() {
                chartDays = newValue;
                initData();
              });
            },
            groupValue: chartDays,
          ),
        ),
        SizedBox(height: 8),
        pressureData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'ความดันเลือด',
                      first: pressureData.first.pressureUpper,
                      last: pressureData.last.pressureUpper),
                  Container(
                    height: 230,
                    child: _buildPressureChart(),
                  ),
                ],
              ),
        SizedBox(height: 30),
        weightData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'น้ำหนัก',
                      first: weightData.first.weight,
                      last: weightData.last.weight),
                  Container(
                    height: 220,
                    child: _buildWeightChart(),
                  ),
                ],
              ),
        SizedBox(height: 30),
        weightData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'BMI',
                      first: weightData.first.weight,
                      last: weightData.last.weight),
                  Container(
                    height: 220,
                    child: _buildBMIChart(),
                  ),
                ],
              ),
        SizedBox(height: 30),
        cholesterolData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'Cholesterol',
                      first: cholesterolData.first.cholesterol,
                      last: cholesterolData.last.cholesterol),
                  Container(
                    height: 220,
                    child: _buildCholesterolChart(),
                  ),
                ],
              ),
        SizedBox(height: 30),
        ldlData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'LDL',
                      first: ldlData.first.ldl,
                      last: ldlData.last.ldl),
                  Container(
                    height: 220,
                    child: _buildLDLChart(),
                  ),
                ],
              ),
        SizedBox(height: 30),
        glucoseData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'Glucose',
                      first: glucoseData.first.glucose,
                      last: glucoseData.last.glucose),
                  Container(
                    height: 220,
                    child: _buildSugarChart(),
                  ),
                ],
              ),
        SizedBox(height: 30),
        hba1cData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'HbA1c',
                      first: hba1cData.first.hba1c,
                      last: hba1cData.last.hba1c),
                  Container(
                    height: 220,
                    child: _buildHbA1cChart(),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _buildPressureChart() {
    List<Series<HealthMonitor, DateTime>> _chartData() {
      return [
        new Series<HealthMonitor, DateTime>(
          id: 'บน',
          colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
          domainFn: (HealthMonitor health, _) => health.date,
          measureFn: (HealthMonitor health, _) => health.pressureUpper,
          data: pressureData,
        )..setAttribute(rendererIdKey, 'customPoint'),
        new Series<HealthMonitor, DateTime>(
          id: 'ล่าง',
          colorFn: (_, __) => MaterialPalette.red.shadeDefault,
          domainFn: (HealthMonitor health, _) => health.date,
          measureFn: (HealthMonitor health, _) => health.pressureLower,
          data: pressureData,
        )..setAttribute(rendererIdKey, 'customArea'),
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'ความดันเลือด', unit: 'mmHg');
  }

  Widget _buildWeightChart() {
    List<Series<HealthMonitor, DateTime>> _chartData() {
      return [
        new Series<HealthMonitor, DateTime>(
          id: 'น้ำหนัก',
          colorFn: (_, __) => MaterialPalette.green.shadeDefault,
          domainFn: (HealthMonitor health, _) => health.date,
          measureFn: (HealthMonitor health, _) => health.weight,
          data: weightData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'น้ำหนัก', unit: 'kg');
  }

  Widget _buildBMIChart() {
    List<HealthMonitor> bmiData = weightData..removeWhere((v) => v.bmi == null);
    List<Series<HealthMonitor, DateTime>> _chartData() {
      return [
        new Series<HealthMonitor, DateTime>(
          id: 'bmi',
          colorFn: (_, __) => MaterialPalette.red.shadeDefault,
          domainFn: (HealthMonitor health, _) => health.date,
          measureFn: (HealthMonitor health, _) => health.bmi,
          data: bmiData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'น้ำหนัก', unit: '');
  }

  Widget _buildSugarChart() {
    List<Series<HealthMonitor, DateTime>> _chartData() {
      return [
        new Series<HealthMonitor, DateTime>(
          id: 'Glucose',
          colorFn: (_, __) => MaterialPalette.purple.shadeDefault,
          domainFn: (HealthMonitor health, _) => health.date,
          measureFn: (HealthMonitor health, _) => health.glucose,
          data: glucoseData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'Glucose', unit: 'mg/dL');
  }

  Widget _buildCholesterolChart() {
    List<Series<HealthMonitor, DateTime>> _chartData() {
      return [
        new Series<HealthMonitor, DateTime>(
          id: 'cholesterol',
          colorFn: (_, __) => MaterialPalette.green.shadeDefault,
          domainFn: (HealthMonitor health, _) => health.date,
          measureFn: (HealthMonitor health, _) => health.cholesterol,
          data: cholesterolData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'Cholesterol', unit: 'mg/dL');
  }

  Widget _buildLDLChart() {
    List<Series<HealthMonitor, DateTime>> _chartData() {
      return [
        new Series<HealthMonitor, DateTime>(
          id: 'LDL',
          colorFn: (_, __) => MaterialPalette.deepOrange.shadeDefault,
          domainFn: (HealthMonitor health, _) => health.date,
          measureFn: (HealthMonitor health, _) => health.ldl,
          data: ldlData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'LDL', unit: 'mg/dL');
  }

  Widget _buildHbA1cChart() {
    List<Series<HealthMonitor, DateTime>> _chartData() {
      return [
        new Series<HealthMonitor, DateTime>(
          id: 'HbA1c',
          colorFn: (_, __) => MaterialPalette.pink.shadeDefault,
          domainFn: (HealthMonitor health, _) => health.date,
          measureFn: (HealthMonitor health, _) => health.hba1c,
          data: hba1cData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'HbA1c', unit: '%');
  }
}
