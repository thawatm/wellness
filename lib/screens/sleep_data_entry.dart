import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/state_model.dart';

class SleepDataEntry extends StatefulWidget {
  @override
  _SleepDataEntryState createState() => _SleepDataEntryState();
}

class _SleepDataEntryState extends State<SleepDataEntry> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String uid;
  DateTime selectedDate;
  DateTime startTime;
  DateTime endTime;
  DateTime today;
  Map<String, dynamic> monitorData = {
    'date': DateTime.now(),
  };

  @override
  void initState() {
    super.initState();
    uid = ScopedModel.of<StateModel>(context).uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: GradientAppBar(
        title: Text('เพิ่มข้อมูลการนอน'),
        gradient: LinearGradient(
            colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
      ),
      body: ListView(
        padding: EdgeInsets.all(8),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.today, color: Colors.grey[500]),
            title: Text('วันที่'),
            trailing: Text(
                DateFormat('EEEE, MMMM d').format(monitorData['date']),
                style: TextStyle(color: Colors.grey[500])),
            onTap: () {
              DatePicker.showDatePicker(
                context,
                showTitleActions: true,
                onConfirm: (date) {
                  setState(() {
                    monitorData['date'] = date;
                  });
                },
                currentTime: monitorData['date'],
              );
            },
          ),
          ListTile(
              leading: Icon(Icons.timer, color: Colors.grey[500]),
              title: Text("เวลาเข้านอน"),
              trailing: startTime != null
                  ? Text(DateFormat.Hm().format(startTime),
                      style: TextStyle(color: Colors.grey[500]))
                  : SizedBox(width: 0),
              onTap: () {
                DatePicker.showTimePicker(
                  context,
                  showSecondsColumn: false,
                  showTitleActions: true,
                  onConfirm: (time) {
                    setState(() {
                      monitorData['startTime'] = time;
                      startTime = time;
                    });
                  },
                );
              }),
          ListTile(
              leading: Icon(Icons.access_time, color: Colors.grey[500]),
              title: Text('เวลาตื่น'),
              trailing: endTime != null
                  ? Text(DateFormat.Hm().format(endTime),
                      style: TextStyle(color: Colors.grey[500]))
                  : SizedBox(width: 0),
              onTap: () {
                DatePicker.showTimePicker(
                  context,
                  showTitleActions: true,
                  showSecondsColumn: false,
                  onConfirm: (time) {
                    setState(() {
                      monitorData['endTime'] = time;
                      endTime = time;
                    });
                  },
                );
              }),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RaisedButton(
              elevation: 1.0,
              onPressed: _saveData,
              padding: EdgeInsets.all(12),
              color: AppTheme.buttonColor,
              child: Text('Save',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  _saveData() async {
    if (monitorData.length != 3) {
      showInSnackBar("No Data");
      return;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        int timestamp = monitorData['date'].millisecondsSinceEpoch;

        if (startTime.isAfter(endTime)) {
          endTime = endTime.add(Duration(days: 1));
        }

        monitorData['sleepHours'] = endTime
            .difference(startTime.subtract(Duration(minutes: 1)))
            .inHours;
        monitorData['startTime'] = DateFormat.Hm().format(startTime);
        monitorData['endTime'] = DateFormat.Hm().format(endTime);

        FirebaseFirestore.instance
            .collection('wellness_data')
            .doc(uid)
            .collection('sleep')
            .doc(timestamp.toString())
            .set(monitorData)
            .whenComplete(() => Navigator.pop(context));
      } else {
        showInSnackBar("No Internet Connection");
      }
    } on SocketException catch (_) {
      showInSnackBar("No Internet Connection");
      return;
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }
}
