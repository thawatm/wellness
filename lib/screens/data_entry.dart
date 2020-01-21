import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:wellness/models/state_model.dart';
import 'package:intl/intl.dart';

import 'package:scoped_model/scoped_model.dart';

class DataEntryDialog extends StatefulWidget {
  @override
  _DataEntryDialogState createState() => _DataEntryDialogState();
}

class _DataEntryDialogState extends State<DataEntryDialog> {
  FirebaseUser currentUser;
  String collection = 'healthdata';

  String _pressureText = '';

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
              leading: Image.asset(
                "assets/images/scale-bathroom.png",
                color: Colors.grey[500],
                height: 24.0,
                width: 24.0,
              ),
              title: Text("ความดันเลือด"),
              trailing: Text("$_pressureText mmHg",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPressurePicker(context);
              }),
          ListTile(
              leading: Icon(Icons.favorite, color: Colors.grey[500]),
              title: Text("อัตราการเต้นของหัวใจ"),
              trailing: Text("${monitorData['hr'] ?? ''} bpm",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showHeartRatePicker(context);
              }),
          SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: RaisedButton(
              elevation: 1.0,
              onPressed: _saveData,
              padding: EdgeInsets.all(12),
              color: Colors.blueAccent,
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

    // int timestamp = monitorData['date'].millisecondsSinceEpoch;

    // DocumentReference monitor = Firestore.instance
    //     .collection("monitor")
    //     .document(currentUser.uid)
    //     .collection(collection)
    //     .document(timestamp.toString());
    // Firestore.instance.runTransaction((transaction) async {
    //   await transaction.set(monitor, monitorData);
    // });
    // showInSnackBar("Successful");
  }

  _showPressurePicker(BuildContext context) {
    new Picker(
        adapter: NumberPickerAdapter(data: [
          NumberPickerColumn(begin: 80, end: 200, initValue: 110),
          NumberPickerColumn(begin: 50, end: 120, initValue: 70),
        ]),
        delimiter: [
          PickerDelimiter(
              child: Container(
            width: 30.0,
            alignment: Alignment.center,
            child: Text(
              '/',
              style: TextStyle(color: Colors.blue, fontSize: 20.0),
            ),
          ))
        ],
        textStyle: TextStyle(color: Colors.blue, fontSize: 20.0),
        confirmText: 'OK',
        cancelText: 'CANCEL',
        itemExtent: 40.0,
        hideHeader: true,
        title: Text("ความดันเลือด"),
        onConfirm: (Picker picker, List value) {
          setState(() {
            monitorData['pressureUpper'] = picker.getSelectedValues()[0];
            monitorData['pressureLower'] = picker.getSelectedValues()[1];
            _pressureText = monitorData['pressureUpper'].toString() +
                '/' +
                monitorData['pressureLower'].toString();
          });
        }).showDialog(context);
  }

  _showHeartRatePicker(BuildContext context) {
    new Picker(
        adapter: NumberPickerAdapter(
          data: [
            NumberPickerColumn(begin: 20, end: 220, initValue: 60),
          ],
        ),
        hideHeader: true,
        textStyle: TextStyle(color: Colors.blue, fontSize: 20.0),
        confirmText: 'OK',
        cancelText: 'CANCEL',
        itemExtent: 40.0,
        title: Text("ครั้งต่อนาที"),
        onConfirm: (Picker picker, List value) {
          setState(() {
            monitorData['hr'] = picker.getSelectedValues()[0];
          });
        }).showDialog(context);
  }
}
