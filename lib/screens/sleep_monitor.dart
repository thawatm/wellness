// import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_picker/flutter_picker.dart';
// import 'package:flutter/src/material/dialog.dart' as Dialog;
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/sleepdata.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/screens/sleep_data_entry.dart';
import 'package:wellness/widgets/bar_chart.dart';
import 'package:wellness/widgets/first_load.dart';
import 'package:wellness/widgets/loading_indicator.dart';
import 'package:wellness/widgets/social_date.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import "package:collection/collection.dart";

enum ConfirmAction { CANCEL, DELETE }

class SleepMonitorPage extends StatefulWidget {
  @override
  _SleepMonitorPageState createState() => _SleepMonitorPageState();
}

class _SleepMonitorPageState extends State<SleepMonitorPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String uid;
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
    uid = ScopedModel.of<StateModel>(context).uid;
    DateTime now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
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
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('wellness_data')
              .document(uid)
              .collection('sleep')
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LoadingIndicator();

            snapshotData = snapshot.data.documents;

            return snapshotData.isEmpty
                ? FirstLoad(title: "เพิ่มข้อมูลใหม่\nแตะที่ไอคอนมุมขวาล่าง")
                : _buildBody();
          }),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: () {
            // showPickerDateRange(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SleepDataEntry()),
            );
          },
          tooltip: 'Pick Time',
          child: Icon(Icons.add_alarm)),
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
      SizedBox(height: 24),
      Card(
        margin: EdgeInsets.all(8.0),
        elevation: 8,
        child: _buildHistory(),
      ),
    ]);
  }

  // showPickerDateRange(BuildContext context) {
  //   Picker dd = new Picker(
  //       hideHeader: true,
  //       adapter: new DateTimePickerAdapter(type: PickerDateTimeType.kDMY),
  //       textStyle: TextStyle(color: Colors.blue, fontSize: 18.0),
  //       onConfirm: (Picker picker, List value) {
  //         // print((picker.adapter as DateTimePickerAdapter).value);
  //         selectedDate = (picker.adapter as DateTimePickerAdapter).value;
  //       });
  //   Picker ps = new Picker(
  //       hideHeader: true,
  //       adapter: new DateTimePickerAdapter(type: PickerDateTimeType.kHM),
  //       delimiter: [
  //         PickerDelimiter(
  //             child: Container(
  //           // width: 30.0,
  //           alignment: Alignment.center,
  //           child: Text(
  //             ':',
  //             style: TextStyle(color: Colors.blue, fontSize: 24.0),
  //           ),
  //         ))
  //       ],
  //       textStyle: TextStyle(color: Colors.blue, fontSize: 18.0),
  //       onConfirm: (Picker picker, List value) {
  //         // print((picker.adapter as DateTimePickerAdapter).value);
  //         startTime = (picker.adapter as DateTimePickerAdapter).value;
  //       });

  //   Picker pe = new Picker(
  //       hideHeader: true,
  //       adapter: new DateTimePickerAdapter(type: PickerDateTimeType.kHM),
  //       delimiter: [
  //         PickerDelimiter(
  //             child: Container(
  //           // width: 30.0,
  //           alignment: Alignment.center,
  //           child: Text(
  //             ':',
  //             style: TextStyle(color: Colors.blue, fontSize: 24.0),
  //           ),
  //         ))
  //       ],
  //       textStyle: TextStyle(color: Colors.blue, fontSize: 18.0),
  //       onConfirm: (Picker picker, List value) {
  //         // print((picker.adapter as DateTimePickerAdapter).value);
  //         endTime = (picker.adapter as DateTimePickerAdapter).value;
  //       });

  //   List<Widget> actions = [
  //     FlatButton(
  //         onPressed: () {
  //           Navigator.pop(context);
  //         },
  //         child: new Text("CANCEL")),
  //     FlatButton(
  //         onPressed: () {
  //           Navigator.pop(context);
  //           dd.onConfirm(dd, dd.selecteds);
  //           ps.onConfirm(ps, ps.selecteds);
  //           pe.onConfirm(pe, pe.selecteds);
  //           if (startTime.isAfter(endTime)) {
  //             endTime = endTime.add(Duration(days: 1));
  //           }
  //           print(endTime.difference(startTime).inHours);

  //           setState(() {
  //             monitorData['date'] = selectedDate;
  //             monitorData['sleepHours'] = endTime.difference(startTime).inHours;
  //             monitorData['startTime'] = DateFormat.Hm().format(startTime);
  //             monitorData['endTime'] = DateFormat.Hm().format(endTime);
  //             _saveData();
  //           });
  //         },
  //         child: new Text("OK")),
  //   ];

  //   Dialog.showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return new AlertDialog(
  //           // title: Text("วันที่"),
  //           actions: actions,
  //           content: Container(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: <Widget>[
  //                 Text("วันที่"),
  //                 dd.makePicker(),
  //                 Text("เวลาเข้านอน"),
  //                 ps.makePicker(),
  //                 Text("เวลาตื่น"),
  //                 pe.makePicker()
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  // }

  Widget _buildHistory() {
    snapshotData = snapshotData
      ..sort(
          (a, b) => b.data['date'].toDate().compareTo(a.data['date'].toDate()));
    return Column(
      children: snapshotData.map((data) => _buildListItem(data)).toList(),
    );
  }

  Widget _buildListItem(DocumentSnapshot data) {
    final record = SleepMonitor.fromSnapshot(data);

    return Column(
      children: <Widget>[
        ListTile(
            title: Text(socialDate(record.date)),
            subtitle: Text('เวลานอน ' +
                record.sleepHours.toString() +
                ' ชม. (' +
                record.startTime +
                ' - ' +
                record.endTime +
                ')'),
            trailing: InkWell(
              child: Icon(Icons.delete, color: Colors.purple.withOpacity(0.6)),
              onTap: () {
                Alert.confirm(
                  context,
                  title: "ลบข้อมูล",
                  content: DateFormat('dd/MM/yyyy').format(record.date) +
                      '\nเวลานอน ' +
                      record.sleepHours.toString() +
                      ' ชม.\n' +
                      record.startTime +
                      ' - ' +
                      record.endTime,
                ).then((int ret) =>
                    ret == Alert.OK ? deleteData(data.documentID) : null);
              },
            )),
        Divider(
          height: 2.0,
        ),
      ],
    );
  }

  deleteData(docId) {
    Firestore.instance
        .collection('wellness_data')
        .document(uid)
        .collection('sleep')
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

  // void _saveData() async {
  //   if (monitorData.length < 2) {
  //     showInSnackBar("No Data");
  //     return;
  //   }

  //   try {
  //     final result = await InternetAddress.lookup('google.com');
  //     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //       int timestamp = monitorData['date'].millisecondsSinceEpoch;
  //       DocumentReference monitor = Firestore.instance
  //           .collection('wellness_data')
  //           .document(uid)
  //           .collection('sleep')
  //           .document(timestamp.toString());
  //       Firestore.instance.runTransaction((transaction) async {
  //         await transaction
  //             .set(monitor, monitorData)
  //             .whenComplete(() => showInSnackBar("Successful"));
  //       });
  //     } else {
  //       showInSnackBar("No Internet Connection");
  //     }
  //   } on SocketException catch (_) {
  //     showInSnackBar("No Internet Connection");
  //     return;
  //   }
  // }

  Future<ConfirmAction> confirmDialog(
      BuildContext context, SleepMonitor record) async {
    return showDialog<ConfirmAction>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text("ลบข้อมูล: " + DateFormat('dd/MM/yyyy').format(record.date)),
          content: Text('เวลานอน ' +
              record.sleepHours.toString() +
              ' ชม. (' +
              record.startTime +
              ' - ' +
              record.endTime +
              ')'),
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
