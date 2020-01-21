import 'package:charts_flutter/flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/painting.dart';
import 'package:wellness/logic/constant.dart';
import 'package:wellness/models/healthdata.dart';
import 'package:wellness/widgets/chart.dart';
import 'package:wellness/widgets/first_load.dart';
import 'package:wellness/widgets/history.dart';
import 'package:wellness/widgets/loading_indicator.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:wellness/models/state_model.dart';
import 'package:wellness/screens/data_entry.dart';
import 'package:wellness/widgets/chart_title.dart';

class HealthMonitorPage extends StatefulWidget {
  @override
  _HealthMonitorPageState createState() => _HealthMonitorPageState();
}

class _HealthMonitorPageState extends State<HealthMonitorPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollViewController;
  FirebaseUser currentUser;
  List<DocumentSnapshot> healthData;
  List<HealthMonitor> pressureData;
  List<HealthMonitor> hrData;
  int chartDays = 5;

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
    _scrollViewController = ScrollController();
    currentUser = ScopedModel.of<StateModel>(context).currentUser;
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
        key: _scaffoldKey,
        body: NestedScrollView(
          controller: _scrollViewController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text("ความดันและหัวใจ"),
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        appBarColor1,
                        appBarColor2,
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
                  .collection('monitor')
                  .document(currentUser.uid)
                  .collection(collection)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return LoadingIndicator();
                healthData = snapshot.data.documents
                  ..sort((a, b) => b.data['date']
                      .toDate()
                      .compareTo(a.data['date'].toDate()));
                // PRESSURE DATA
                pressureData = healthData
                    .map((data) => HealthMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.pressureUpper == null)
                      ..removeWhere((v) => v.pressureLower == null);

                // HR DATA
                hrData = healthData
                    .map((data) => HealthMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.hr == null);

                return TabBarView(
                  children: <Widget>[
                    DataEntryDialog(),
                    healthData.isEmpty
                        ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่แทบด้านบน")
                        : _buildChart(),
                    healthData.isEmpty
                        ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่แทบด้านบน")
                        : HistoryList(
                            snapshot: healthData,
                            currentUser: currentUser,
                            collection: collection,
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
            onValueChanged: (int newValue) {
              setState(() {
                chartDays = newValue;
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
        hrData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'อัตราการเต้นของหัวใจ',
                      first: hrData.first.hr,
                      last: hrData.last.hr),
                  Container(
                    height: 220,
                    child: _buildHRChart(),
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
          domainFn: (HealthMonitor health, _) =>
              DateTime(health.date.year, health.date.month, health.date.day),
          measureFn: (HealthMonitor health, _) => health.pressureUpper,
          data: pressureData,
        )..setAttribute(rendererIdKey, 'customPoint'),
        new Series<HealthMonitor, DateTime>(
          id: 'ล่าง',
          colorFn: (_, __) => MaterialPalette.red.shadeDefault,
          domainFn: (HealthMonitor health, _) =>
              DateTime(health.date.year, health.date.month, health.date.day),
          measureFn: (HealthMonitor health, _) => health.pressureLower,
          data: pressureData,
        )..setAttribute(rendererIdKey, 'customArea'),
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'ความดันเลือด', unit: 'mmHg');
  }

  Widget _buildHRChart() {
    List<Series<HealthMonitor, DateTime>> _chartData() {
      return [
        new Series<HealthMonitor, DateTime>(
          id: 'หัวใจ',
          colorFn: (_, __) => MaterialPalette.green.shadeDefault,
          domainFn: (HealthMonitor health, _) =>
              DateTime(health.date.year, health.date.month, health.date.day),
          measureFn: (HealthMonitor health, _) => health.hr,
          data: hrData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'อัตราการเต้นของหัวใจ', unit: 'bpm');
  }
}
