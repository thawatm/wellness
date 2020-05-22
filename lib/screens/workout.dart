import 'package:charts_flutter/flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/workoutdata.dart';
import 'package:wellness/screens/workout_data_entry.dart';
import 'package:wellness/widgets/chart.dart';
import 'package:wellness/widgets/chart_title.dart';
import 'package:wellness/widgets/first_load.dart';
import 'package:wellness/widgets/history.dart';
import 'package:wellness/widgets/loading_indicator.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:wellness/models/state_model.dart';

class WorkoutPage extends StatefulWidget {
  @override
  _WorkoutPageState createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  ScrollController _scrollViewController;
  FirebaseUser currentUser;
  String collection = 'workout';

  List<DocumentSnapshot> snapshotData;
  List<WorkoutMonitor> stepsData;
  List<WorkoutMonitor> runWorkoutData;
  List<WorkoutMonitor> cyclingWorkoutData;
  List<WorkoutMonitor> etcWorkoutData;

  int chartDays = 5;
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
        body: NestedScrollView(
          controller: _scrollViewController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text("การออกกำลังกาย"),
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
                  .collection('monitor')
                  .document(currentUser.uid)
                  .collection(collection)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return LoadingIndicator();
                snapshotData = snapshot.data.documents
                  ..sort((a, b) => b.data['date']
                      .toDate()
                      .compareTo(a.data['date'].toDate()));

                // Sugar DATA
                stepsData = snapshotData
                    .map((data) => WorkoutMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.steps == null);
                // Sugar DATA
                runWorkoutData = snapshotData
                    .map((data) => WorkoutMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.run == null);
                cyclingWorkoutData = snapshotData
                    .map((data) => WorkoutMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.cycling == null);
                etcWorkoutData = snapshotData
                    .map((data) => WorkoutMonitor.fromSnapshot(data))
                    .toList()
                      ..removeWhere(
                          (v) => today.difference(v.date).inDays > chartDays)
                      ..removeWhere((v) => v.etc == null);

                return TabBarView(
                  children: <Widget>[
                    WorkoutDataEntry(),
                    snapshotData.isEmpty
                        ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่แทบด้านบน")
                        : _buildChart(),
                    snapshotData.isEmpty
                        ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่แทบด้านบน")
                        : HistoryList(
                            snapshot: snapshotData,
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
        stepsData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'การเดิน',
                      first: stepsData.first.steps,
                      last: stepsData.last.steps),
                  Container(
                    height: 220,
                    child: _buildStepsChart(),
                  ),
                ],
              ),
        SizedBox(height: 30),
        runWorkoutData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'วิ่ง',
                      first: runWorkoutData.first.cycling,
                      last: runWorkoutData.last.cycling),
                  Container(
                    height: 220,
                    child: _buildRunChart(),
                  ),
                ],
              ),
        SizedBox(height: 30),
        cyclingWorkoutData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'ปั่นจักรยาน',
                      first: cyclingWorkoutData.first.cycling,
                      last: cyclingWorkoutData.last.cycling),
                  Container(
                    height: 220,
                    child: _buildCyclingChart(),
                  ),
                ],
              ),
        SizedBox(height: 30),
        etcWorkoutData.isEmpty
            ? SizedBox(height: 0)
            : Column(
                children: <Widget>[
                  ChartPercentTitle(
                      title: 'ออกกำลังอื่นๆ',
                      first: etcWorkoutData.first.etc,
                      last: etcWorkoutData.last.etc),
                  Container(
                    height: 220,
                    child: _buildEtcChart(),
                  ),
                ],
              ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildStepsChart() {
    List<Series<WorkoutMonitor, DateTime>> _chartData() {
      return [
        new Series<WorkoutMonitor, DateTime>(
          id: 'Steps',
          colorFn: (_, __) => MaterialPalette.purple.shadeDefault,
          domainFn: (WorkoutMonitor workout, _) => workout.date,
          measureFn: (WorkoutMonitor workout, _) => workout.steps,
          data: stepsData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'จำนวนก้าว', unit: 'ก้าว');
  }

  Widget _buildRunChart() {
    List<Series<WorkoutMonitor, DateTime>> _chartData() {
      return [
        new Series<WorkoutMonitor, DateTime>(
          id: 'run',
          colorFn: (_, __) => MaterialPalette.green.shadeDefault,
          domainFn: (WorkoutMonitor workout, _) => workout.date,
          measureFn: (WorkoutMonitor workout, _) => workout.run,
          data: runWorkoutData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'วิ่ง', unit: 'นาที');
  }

  Widget _buildCyclingChart() {
    List<Series<WorkoutMonitor, DateTime>> _chartData() {
      return [
        new Series<WorkoutMonitor, DateTime>(
          id: 'cycling',
          colorFn: (_, __) => MaterialPalette.blue.shadeDefault,
          domainFn: (WorkoutMonitor workout, _) => workout.date,
          measureFn: (WorkoutMonitor workout, _) => workout.cycling,
          data: cyclingWorkoutData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'ปั่นจักรยาน', unit: 'นาที');
  }

  Widget _buildEtcChart() {
    List<Series<WorkoutMonitor, DateTime>> _chartData() {
      return [
        new Series<WorkoutMonitor, DateTime>(
          id: 'etc',
          colorFn: (_, __) => MaterialPalette.red.shadeDefault,
          domainFn: (WorkoutMonitor workout, _) => workout.date,
          measureFn: (WorkoutMonitor workout, _) => workout.etc,
          data: etcWorkoutData,
        )..setAttribute(rendererIdKey, 'customArea')
      ];
    }

    return SimpleTimeSeriesChart(_chartData(),
        animate: true, title: 'อื่นๆ', unit: 'นาที');
  }
}
