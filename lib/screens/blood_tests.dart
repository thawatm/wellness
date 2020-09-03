import 'package:charts_flutter/flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/healthdata.dart';
import 'package:wellness/screens/blood_data_entry.dart';
import 'package:wellness/widgets/chart.dart';
import 'package:wellness/widgets/chart_title.dart';
import 'package:wellness/widgets/first_load.dart';
import 'package:wellness/widgets/history.dart';
import 'package:wellness/widgets/loading_indicator.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:wellness/models/state_model.dart';

class BloodTestPage extends StatefulWidget {
  @override
  _BloodTestPageState createState() => _BloodTestPageState();
}

class _BloodTestPageState extends State<BloodTestPage> {
  ScrollController _scrollViewController;
  String uid;
  String collection = 'healthdata';

  List<DocumentSnapshot> healthData;
  List<HealthMonitor> glucoseData;
  List<HealthMonitor> cholesterolData;
  List<HealthMonitor> hdlData;
  List<HealthMonitor> ldlData;
  List<HealthMonitor> triglyceridesData;
  List<HealthMonitor> creatinineData;
  List<HealthMonitor> eGFRData;
  List<HealthMonitor> uricAcidData;
  List<HealthMonitor> hba1cData;
  int chartDays = 99999;
  DateTime today;

  final Map<int, Widget> chartPeriod = const <int, Widget>{
    5: Text('สัปดาห์'),
    30: Text('เดือน'),
    365: Text('ปี'),
    99999: Text('ทั้งหมด'),
  };

  @override
  void initState() {
    super.initState();
    _scrollViewController = ScrollController();
    uid = ScopedModel.of<StateModel>(context).uid;
    DateTime now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          controller: _scrollViewController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text("ค่าผลเลือด"),
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.appBarColor1,
                        AppTheme.appBarColor2,
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  tabs: <Tab>[
                    Tab(
                      key: Key('AddTab'),
                      text: "เพิ่มข้อมูล",
                      // icon: Icon(Icons.add),
                    ),
                    Tab(
                      key: Key('StatisticsTab'),
                      text: "รายงาน",
                      // icon: Icon(Icons.show_chart),
                    ),
                    Tab(
                      key: Key('HistoryTab'),
                      text: "ข้อมูลย้อนหลัง",
                      // icon: Icon(Icons.history),
                    ),
                  ],
                ),
                // actions: _buildMenuActions(context),
              ),
            ];
          },
          body: StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection('wellness_data')
                  .document(uid)
                  .collection(collection)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return LoadingIndicator();
                healthData = snapshot.data.documents
                  ..sort((a, b) => b.data['date']
                      .toDate()
                      .compareTo(a.data['date'].toDate()));

                // Sugar DATA
                glucoseData = healthData
                    .map((data) => HealthMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.glucose == null);

                // cholesterol DATA
                cholesterolData = healthData
                    .map((data) => HealthMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.cholesterol == null);

                // HDL DATA
                hdlData = healthData
                    .map((data) => HealthMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.hdl == null);

                // LDL DATA
                ldlData = healthData
                    .map((data) => HealthMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.ldl == null);
                // LDL DATA
                hba1cData = healthData
                    .map((data) => HealthMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.hba1c == null);

                // triglycerides DATA
                triglyceridesData = healthData
                    .map((data) => HealthMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.triglycerides == null);

                // creatinine DATA
                creatinineData = healthData
                    .map((data) => HealthMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.creatinine == null);
                // eGFR DATA
                eGFRData = healthData
                    .map((data) => HealthMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.eGFR == null);

                // uricAcid DATA
                uricAcidData = healthData
                    .map((data) => HealthMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.uricAcid == null);

                return TabBarView(
                  children: <Widget>[
                    BloodDataEntry(),
                    healthData.isEmpty
                        ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่แทบด้านบน")
                        : _buildChart(),
                    healthData.isEmpty
                        ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่แทบด้านบน")
                        : HistoryList(
                            snapshot: healthData,
                            uid: uid,
                            collection: 'bloodtests',
                          ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return ListView(
      children: <Widget>[
        SizedBox(
          // width: 500.0,
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
        SizedBox(height: 8),
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
        hdlData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'HDL',
                      first: hdlData.first.hdl,
                      last: hdlData.last.hdl),
                  Container(
                    height: 220,
                    child: _buildHDLChart(),
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
        SizedBox(height: 30),
        triglyceridesData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'Triglycerides',
                      first: triglyceridesData.first.triglycerides,
                      last: triglyceridesData.last.triglycerides),
                  Container(
                    height: 220,
                    child: _buildTriglyceridesChart(),
                  ),
                ],
              ),
        SizedBox(height: 30),
        creatinineData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'Creatinine',
                      first: creatinineData.first.creatinine,
                      last: creatinineData.last.creatinine),
                  Container(
                    height: 220,
                    child: _buildCreatinineChart(),
                  ),
                ],
              ),
        SizedBox(height: 30),
        eGFRData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'eGFR',
                      first: eGFRData.first.eGFR,
                      last: eGFRData.last.eGFR),
                  Container(
                    height: 220,
                    child: _buildeGFRChart(),
                  ),
                ],
              ),
        SizedBox(height: 30),
        uricAcidData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'Uric Acid',
                      first: uricAcidData.first.uricAcid,
                      last: uricAcidData.last.uricAcid),
                  Container(
                    height: 220,
                    child: _buildUricAcidChart(),
                  ),
                ],
              ),
      ],
    );
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

  Widget _buildHDLChart() {
    List<Series<HealthMonitor, DateTime>> _chartData() {
      return [
        new Series<HealthMonitor, DateTime>(
          id: 'HDL',
          colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
          domainFn: (HealthMonitor health, _) => health.date,
          measureFn: (HealthMonitor health, _) => health.hdl,
          data: hdlData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'HDL', unit: 'mg/dL');
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

  Widget _buildTriglyceridesChart() {
    List<Series<HealthMonitor, DateTime>> _chartData() {
      return [
        new Series<HealthMonitor, DateTime>(
          id: 'Triglycerides',
          colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
          domainFn: (HealthMonitor health, _) => health.date,
          measureFn: (HealthMonitor health, _) => health.triglycerides,
          data: triglyceridesData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'Triglycerides', unit: 'mg/dL');
  }

  Widget _buildCreatinineChart() {
    List<Series<HealthMonitor, DateTime>> _chartData() {
      return [
        new Series<HealthMonitor, DateTime>(
          id: 'creatinine',
          colorFn: (_, __) => MaterialPalette.cyan.shadeDefault,
          domainFn: (HealthMonitor health, _) => health.date,
          measureFn: (HealthMonitor health, _) => health.creatinine,
          data: creatinineData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'Creatinine', unit: 'mg/dL');
  }

  Widget _buildeGFRChart() {
    List<Series<HealthMonitor, DateTime>> _chartData() {
      return [
        new Series<HealthMonitor, DateTime>(
          id: 'eGFR',
          colorFn: (_, __) => MaterialPalette.indigo.shadeDefault,
          domainFn: (HealthMonitor health, _) => health.date,
          measureFn: (HealthMonitor health, _) => health.eGFR,
          data: eGFRData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(), animate: true, title: 'eGFR');
  }

  Widget _buildUricAcidChart() {
    List<Series<HealthMonitor, DateTime>> _chartData() {
      return [
        new Series<HealthMonitor, DateTime>(
          id: 'uricAcid',
          colorFn: (_, __) => MaterialPalette.pink.shadeDefault,
          domainFn: (HealthMonitor health, _) => health.date,
          measureFn: (HealthMonitor health, _) => health.uricAcid,
          data: uricAcidData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'Uric Acid', unit: 'mg/dL');
  }
}
