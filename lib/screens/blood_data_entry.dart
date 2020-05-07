import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:wellness/fitness_app/app_theme.dart';
import 'package:wellness/models/state_model.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';

class BloodDataEntry extends StatefulWidget {
  @override
  _BloodDataEntryState createState() => _BloodDataEntryState();
}

class _BloodDataEntryState extends State<BloodDataEntry> {
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseUser currentUser;
  String collection = 'bloodtests';

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
              title: Text("Glucose"),
              trailing: Text("${monitorData['glucose'] ?? ''} mg/dL",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerNumber(
                    context, 0, 400, 100, 'Glucose (mg/dL)', 'glucose');
              }),
          ListTile(
              leading: Icon(Icons.fastfood, color: Colors.grey[500]),
              title: Text("Cholesterol"),
              trailing: Text("${monitorData['cholesterol'] ?? ''} mg/dL",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerNumber(context, 100, 500, 200, 'Cholesterol (mg/dL)',
                    'cholesterol');
              }),
          ListTile(
              leading: Icon(Icons.brightness_high, color: Colors.grey[500]),
              title: Text("HDL"),
              trailing: Text("${monitorData['hdl'] ?? ''} mg/dL",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerNumber(context, 0, 100, 50, 'HDL (mg/dL)', 'hdl');
              }),
          ListTile(
              leading: Icon(Icons.low_priority, color: Colors.grey[500]),
              title: Text("LDL"),
              trailing: Text("${monitorData['ldl'] ?? ''} mg/dL",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerNumber(context, 0, 400, 50, 'LDL (mg/dL)', 'ldl');
              }),
          ListTile(
              leading: Icon(Icons.highlight, color: Colors.grey[500]),
              title: Text("HbA1c"),
              trailing: Text("${monitorData['hba1c'] ?? ''} %",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerDouble(context, 0, 100, 10, 'HbA1c (%)', 'hba1c');
              }),
          ListTile(
              leading: Icon(Icons.terrain, color: Colors.grey[500]),
              title: Text("Triglycerides"),
              trailing: Text("${monitorData['triglycerides'] ?? ''} mg/dL",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerNumber(context, 0, 999, 100, 'Triglycerides (mg/dL)',
                    'triglycerides');
              }),
          ListTile(
              leading: Icon(Icons.label, color: Colors.grey[500]),
              title: Text("Creatinine"),
              trailing: Text("${monitorData['creatinine'] ?? ''} mg/dL",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerDouble(
                    context, 0, 9, 5, 'Creatinine (mg/dL)', 'creatinine');
              }),
          ListTile(
              leading: Icon(Icons.eject, color: Colors.grey[500]),
              title: Text("eGFR"),
              trailing: Text("${monitorData['eGFR'] ?? ''}",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerDouble2Digit(context, 0, 100, 50, 'eGFR', 'eGFR');
              }),
          ListTile(
              leading: Icon(Icons.tonality, color: Colors.grey[500]),
              title: Text("Uric Acid"),
              trailing: Text("${monitorData['uricAcid'] ?? ''} mg/dL",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerDouble(
                    context, 0, 19, 10, 'Uric Acid (mg/dL)', 'uricAcid');
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

  _showPickerDouble(BuildContext context, int begin, int end, int initValue,
      String title, String updateKey) {
    new Picker(
        adapter: NumberPickerAdapter(
          data: [
            NumberPickerColumn(begin: begin, end: end, initValue: initValue),
            NumberPickerColumn(begin: 0, end: 9, initValue: 0),
          ],
        ),
        delimiter: [
          PickerDelimiter(
              child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Text(
              '.',
              style: TextStyle(color: Colors.blue, fontSize: 32.0),
            ),
          ))
        ],
        hideHeader: true,
        textStyle: TextStyle(color: Colors.blue, fontSize: 20.0),
        confirmText: 'OK',
        cancelText: 'CANCEL',
        itemExtent: 40.0,
        looping: true,
        title: Text(title),
        onConfirm: (Picker picker, List value) {
          setState(() {
            monitorData[updateKey] = picker.getSelectedValues()[0] +
                picker.getSelectedValues()[1] / 10;
          });
        }).showDialog(context);
  }

  _showPickerDouble2Digit(BuildContext context, int begin, int end,
      int initValue, String title, String updateKey) {
    new Picker(
        adapter: NumberPickerAdapter(
          data: [
            NumberPickerColumn(begin: begin, end: end, initValue: initValue),
            NumberPickerColumn(begin: 0, end: 99, initValue: 0),
          ],
        ),
        delimiter: [
          PickerDelimiter(
              child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Text(
              '.',
              style: TextStyle(color: Colors.blue, fontSize: 32.0),
            ),
          ))
        ],
        hideHeader: true,
        textStyle: TextStyle(color: Colors.blue, fontSize: 20.0),
        confirmText: 'OK',
        cancelText: 'CANCEL',
        itemExtent: 40.0,
        looping: true,
        title: Text(title),
        onConfirm: (Picker picker, List value) {
          setState(() {
            monitorData[updateKey] = picker.getSelectedValues()[0] +
                picker.getSelectedValues()[1] / 100;
          });
        }).showDialog(context);
  }
}
