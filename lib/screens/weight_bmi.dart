import 'package:charts_flutter/flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/healthdata.dart';
import 'package:wellness/screens/weight_data_entry.dart';
import 'package:wellness/widgets/chart.dart';
import 'package:wellness/widgets/chart_title.dart';
import 'package:wellness/widgets/first_load.dart';
import 'package:wellness/widgets/history.dart';
import 'package:wellness/widgets/loading_indicator.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:wellness/models/state_model.dart';

class WeightPage extends StatefulWidget {
  @override
  _WeightPageState createState() => _WeightPageState();
}

class _WeightPageState extends State<WeightPage> {
  ScrollController _scrollViewController;
  String uid;
  String collection = 'healthdata';

  List<DocumentSnapshot> healthData;
  List<HealthMonitor> weightData;
  List<HealthMonitor> bodyAgeData;
  List<HealthMonitor> fatData;

  DateTime today;

  int chartDays = 5;

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
                title: Text("น้ำหนัก"),
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
                      .compareTo(a.data['date'].toDate()))
                  ..removeWhere((v) => v['weight'] == null);

                // Weight DATA
                weightData = healthData
                    .map((data) => HealthMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays);

                return TabBarView(
                  children: <Widget>[
                    WeightDataEntry(),
                    healthData.isEmpty
                        ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่แทบด้านบน")
                        : _buildChart(),
                    healthData.isEmpty
                        ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่แทบด้านบน")
                        : HistoryList(
                            snapshot: healthData,
                            uid: uid,
                            collection: 'weight',
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
      ],
    );
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
}
