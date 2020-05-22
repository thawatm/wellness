import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/fitkitdata.dart';
import 'package:wellness/models/state_model.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

class WorkoutDataEntry extends StatefulWidget {
  @override
  _WorkoutDataEntryState createState() => _WorkoutDataEntryState();
}

class _WorkoutDataEntryState extends State<WorkoutDataEntry> {
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseUser currentUser;
  String collection = 'workout';

  Map<String, dynamic> monitorData = {
    'date': DateTime.now(),
  };

  @override
  void initState() {
    super.initState();
    currentUser = ScopedModel.of<StateModel>(context).currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // key: _scaffoldKey,
      child: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.today, color: Colors.grey[500]),
            title: Text(DateFormat('EEEE, MMMM d').format(monitorData['date'])),
            trailing: Text(
              DateFormat('H:mm ').format(monitorData['date']),
              style: TextStyle(fontSize: 16),
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
          ),
          ListTile(
              leading: Icon(Icons.local_drink, color: Colors.grey[500]),
              title: Text("เดิน"),
              trailing: Text("${monitorData['steps'] ?? ''} ก้าว",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerNumber(
                    context, 0, 20000, 1000, 'เดิน (ก้าว)', 'steps');
              }),
          ListTile(
              leading: Icon(Icons.fastfood, color: Colors.grey[500]),
              title: Text("วิ่ง"),
              trailing: Text("${monitorData['run'] ?? ''} นาที",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerNumber(context, 0, 500, 20, 'วิ่ง (นาที)', 'run');
              }),
          ListTile(
              leading: Icon(Icons.brightness_high, color: Colors.grey[500]),
              title: Text("ปั่นจักรยาน"),
              trailing: Text("${monitorData['cycling'] ?? ''} นาที",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerNumber(
                    context, 0, 500, 20, 'ปั่นจักรยาน (นาที)', 'cycling');
              }),
          ListTile(
              leading: Icon(Icons.low_priority, color: Colors.grey[500]),
              title: Text("ออกกำลังกายแบบอื่นๆ"),
              trailing: Text("${monitorData['etc'] ?? ''} นาที",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerNumber(context, 0, 500, 20, 'อื่นๆ (นาที)', 'etc');
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
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RaisedButton(
              elevation: 1.0,
              onPressed: () async {
                FitKitData().revokePermissions();
              },
              padding: EdgeInsets.all(12),
              color: AppTheme.buttonColor,
              child: Text('Remove Google Fit',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  void showInSnackBar(String value) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  void _saveData() async {
    if (monitorData.length < 2) {
      showInSnackBar("No Data");
      return;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        int timestamp = monitorData['date'].millisecondsSinceEpoch;

        monitorData['totalWorkout'] = monitorData['run'] ??
            0 + monitorData['cycling'] ??
            0 + monitorData['etc'] ??
            0;

        DocumentReference monitor = Firestore.instance
            .collection("monitor")
            .document(currentUser.uid)
            .collection(collection)
            .document(timestamp.toString());
        Firestore.instance.runTransaction((transaction) async {
          await transaction
              .set(monitor, monitorData)
              .whenComplete(() => showInSnackBar("Successful"));
        });
      } else {
        showInSnackBar("No Internet Connection");
      }
    } on SocketException catch (_) {
      showInSnackBar("No Internet Connection");
      return;
    }
  }

  _showPickerNumber(BuildContext context, int begin, int end, int initValue,
      String title, String updateKey) {
    new Picker(
        adapter: NumberPickerAdapter(
          data: [
            NumberPickerColumn(begin: begin, end: end, initValue: initValue),
          ],
        ),
        hideHeader: true,
        textStyle: TextStyle(color: Colors.blue, fontSize: 20.0),
        confirmText: 'OK',
        cancelText: 'CANCEL',
        itemExtent: 40.0,
        title: Text(title),
        onConfirm: (Picker picker, List value) {
          setState(() {
            monitorData[updateKey] = picker.getSelectedValues()[0];
          });
        }).showDialog(context);
  }
}
