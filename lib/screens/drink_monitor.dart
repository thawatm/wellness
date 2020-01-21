import 'dart:io';

import 'package:charts_flutter/flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wellness/logic/constant.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/models/waterdata.dart';
import 'package:wellness/widgets/bar_chart.dart';
import 'package:wellness/widgets/first_load.dart';
import 'package:wellness/widgets/gauge_chart.dart';
import 'package:wellness/widgets/loading_indicator.dart';
import 'package:wellness/widgets/social_date.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

enum ConfirmAction { CANCEL, DELETE }

class DrinkMonitorPage extends StatefulWidget {
  @override
  _DrinkMonitorPageState createState() => _DrinkMonitorPageState();
}

class _DrinkMonitorPageState extends State<DrinkMonitorPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollViewController;
  FirebaseUser currentUser;
  List<DocumentSnapshot> snapshotData;

  List<WaterMonitor> todayData;

  int drink = 0;
  int recommend = 2500;

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

  List<charts.Series<GaugeSegment, String>> _createGaugeData() {
    final data = [
      new GaugeSegment('drink', drink, MaterialPalette.blue.shadeDefault),
      new GaugeSegment('recommend', recommend, MaterialPalette.gray.shade300),
    ];

    return [
      new charts.Series<GaugeSegment, String>(
        id: 'Segments',
        domainFn: (GaugeSegment segment, _) => segment.segment,
        measureFn: (GaugeSegment segment, _) => segment.size,
        colorFn: (GaugeSegment segment, _) => segment.color,
        data: data,
      )
    ];
  }

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
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        body: NestedScrollView(
          controller: _scrollViewController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text("การดื่มน้ำ"),
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
                      key: Key('Today'),
                      text: "เพิ่มข้อมูล",
                      // icon: Icon(Icons.add),
                    ),
                    Tab(
                      key: Key('Chart'),
                      text: "ข้อมูลย้อนหลัง",
                      // icon: Icon(Icons.add),
                    ),
                    // Tab(
                    //   key: Key('HistoryTab'),
                    //   text: "ข้อมูลย้อนหลัง",
                    //   // icon: Icon(Icons.history),
                    // ),
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
                  .collection('water')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return LoadingIndicator();
                snapshotData = snapshot.data.documents;

                todayData = snapshotData
                    .map((data) => WaterMonitor.fromSnapshot(data))
                    .where((v) => (DateFormat.yMd().format(v.date) ==
                        (DateFormat.yMd().format(monitorData['date']))))
                    .toList();

                // Gauge display
                drink = todayData.length * 200;
                recommend = 2400 - drink;
                if (recommend < 0) recommend = 0;

                return TabBarView(
                  children: <Widget>[
                    _buildTodayGauge(),

                    snapshotData.isEmpty
                        ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่แทบด้านบน")
                        : _buildHistoryChart(),
                    // _buildHistory(),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget _buildTodayGauge() {
    DateTime t = monitorData['date'];
    Widget title = ListTile(
      title: Text(socialDate(DateTime(t.year, t.month, t.day))),
      leading: Icon(
        Icons.date_range,
        color: Colors.blue,
      ),
      onTap: () {
        DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          onChanged: (date) {
            setState(() {
              monitorData['date'] = date;
            });
          },
          onConfirm: (date) {
            setState(() {
              monitorData['date'] = date;
            });
          },
          currentTime: monitorData['date'],
        );
      },
    );

    var tempList = todayData.map((data) => _buildTodayData(data)).toList()
      ..insert(0, title);

    return ListView(
      children: <Widget>[
        Container(
            // width: 300,
            height: 300,
            child: Stack(children: [
              GaugeChart(_createGaugeData(), animate: true),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 24),
                    Text(
                      '$drink/2400ml',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 24),
                    InkResponse(
                      onTap: () {
                        monitorData['drinkTime'] =
                            DateFormat.Hm().format(monitorData['date']);
                        monitorData['waterVolume'] = 200;
                        _saveData();
                      },
                      child: Icon(
                        Icons.battery_full,
                        size: 80,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      '+200ml',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    )
                  ],
                ),
              ),
            ])),
        Card(
          margin: EdgeInsets.all(8.0),
          elevation: 8,
          child: Column(
            children: tempList,
          ),
        )
      ],
    );
  }

  Widget _buildTodayData(WaterMonitor record) {
    return Column(children: <Widget>[
      Divider(height: 2.0),
      ListTile(
        leading: Icon(Icons.access_time, color: Colors.blue),
        title: Text(record.drinkTime, style: TextStyle(color: Colors.black54)),
        trailing: InkWell(
          child: Icon(Icons.chevron_right, color: Colors.blue),
          onTap: () {
            // final ConfirmAction action = await confirmDialog(context, record);
            // if (action.toString() == 'ConfirmAction.DELETE') {
            //   deleteData(record.documentID);
            // }
            Alert(
              context: context,
              type: AlertType.warning,
              title: "ลบข้อมูล",
              desc: DateFormat('dd/MM/yyyy').format(record.date) +
                  "\nเวลาดื่ม: " +
                  DateFormat.Hm().format(record.date),
              buttons: [
                DialogButton(
                  child: Text(
                    "ยกเลิก",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.green,
                ),
                DialogButton(
                  child: Text(
                    "ลบ",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  onPressed: () {
                    deleteData(record.documentID);
                    Navigator.pop(context);
                  },
                  color: Colors.red,
                )
              ],
            ).show();
          },
        ),
      ),
    ]);
  }

  Widget _buildHistoryChart() {
    return ListView(children: <Widget>[
      SizedBox(
        height: 72,
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
      Container(
        height: 300,
        child: TimeSeriesBar(_chartData(), animate: true, unit: 'ปริมาณน้ำ ml'),
      ),
    ]);
  }

  deleteData(docId) {
    Firestore.instance
        .collection('monitor')
        .document(currentUser.uid)
        .collection('water')
        .document(docId)
        .delete()
        .catchError((e) {
      print(e);
    });
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  void _saveData() async {
    if (monitorData.length < 2) {
      showInSnackBar("No Data");
      return;
    }

    int timestamp = monitorData['date'].millisecondsSinceEpoch;

    DocumentReference monitor = Firestore.instance
        .collection("monitor")
        .document(currentUser.uid)
        .collection('water')
        .document(timestamp.toString());
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(monitor, monitorData);

      monitorData['date'] = monitorData['date'].add(Duration(seconds: 1));
    });
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        showInSnackBar("Successful");
      } else {
        showInSnackBar("No Internet Connection");
      }
    } on SocketException catch (_) {
      showInSnackBar("No Internet Connection");
      return;
    }
  }

  Future<ConfirmAction> confirmDialog(
      BuildContext context, WaterMonitor record) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text("ลบข้อมูล: " + DateFormat('dd/MM/yyyy').format(record.date)),
          content: Text(
            "เวลาดื่ม: " + DateFormat.Hm().format(record.date),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.CANCEL);
              },
            ),
            FlatButton(
              child: const Text('DELETE'),
              onPressed: () {
                Navigator.of(context).pop(ConfirmAction.DELETE);
              },
            )
          ],
        );
      },
    );
  }
}

class GaugeSegment {
  final String segment;
  final int size;
  final charts.Color color;

  GaugeSegment(this.segment, this.size, this.color);
}
