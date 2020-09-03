import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/state_model.dart';
import 'package:intl/intl.dart';

import 'package:scoped_model/scoped_model.dart';

class FatDataEntry extends StatefulWidget {
  @override
  _FatDataEntryState createState() => _FatDataEntryState();
}

class _FatDataEntryState extends State<FatDataEntry> {
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  String uid;
  String collection = 'healthdata';
  int height = 170;

  Map<String, dynamic> monitorData = {
    'date': DateTime.now(),
    'category': 'fat'
  };

  @override
  void initState() {
    super.initState();
    uid = ScopedModel.of<StateModel>(context).uid;
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
              leading: Icon(Icons.event, color: Colors.grey[500]),
              title: Text("Body Fat"),
              trailing: Text("${monitorData['bodyFat'] ?? ''} %",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerDouble(
                    context, 0, 999, 20, 'Body Fat (%)', 'bodyFat');
              }),
          ListTile(
              leading: Icon(Icons.assignment_ind, color: Colors.grey[500]),
              title: Text('Visceral Fat'),
              // title: bmiBarCart(),
              trailing: Text("${monitorData['visceralFat'] ?? ''} %",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerDouble(
                    context, 0, 999, 10, 'visceralFat (%)', 'visceralFat');
              }),
          ListTile(
              leading: Icon(Icons.person, color: Colors.grey[500]),
              title: Text("Muscle Mass"),
              trailing: Text("${monitorData['muscle'] ?? ''} kg",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerDouble(
                    context, 0, 99, 40, 'Muscle Mass (kg)', 'muscle');
              }),
          ListTile(
              leading: Icon(Icons.person, color: Colors.grey[500]),
              title: Text("Body Age"),
              trailing: Text("${monitorData['bodyAge'] ?? ''} ปี",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerNumber(
                    context, 0, 999, 35, 'Body Age (ปี)', 'bodyAge');
              }),
          ListTile(
              leading: Icon(Icons.person, color: Colors.grey[500]),
              title: Text("รอบเอว"),
              trailing: Text("${monitorData['waist'] ?? ''} นิ้ว",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerDouble(context, 15, 60, 30, 'นิ้ว', 'waist');
              }),
          ExpansionTile(
            leading: Icon(Icons.add_circle_outline, color: Colors.grey[500]),
            title: Text('ไขมัน'),
            backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
            children: [
              ListTile(
                  leading: Icon(Icons.border_right, color: Colors.grey[500]),
                  title: Text("ไขมัน แขนขวา"),
                  trailing: Text("${monitorData['rightArmFat'] ?? ''} %",
                      style: TextStyle(color: Colors.grey[500])),
                  onTap: () {
                    _showPickerDouble(
                        context, 0, 999, 20, '%ไขมัน แขนขวา', 'rightArmFat');
                  }),
              ListTile(
                  leading: Icon(Icons.border_left, color: Colors.grey[500]),
                  title: Text("ไขมัน แขนซ้าย"),
                  trailing: Text("${monitorData['leftArmFat'] ?? ''} %",
                      style: TextStyle(color: Colors.grey[500])),
                  onTap: () {
                    _showPickerDouble(
                        context, 0, 999, 20, '%ไขมัน แขนขวา', 'leftArmFat');
                  }),
              ListTile(
                  leading: Icon(Icons.rotate_right, color: Colors.grey[500]),
                  title: Text("ไขมัน ขาขวา"),
                  trailing: Text("${monitorData['rightLegFat'] ?? ''} %",
                      style: TextStyle(color: Colors.grey[500])),
                  onTap: () {
                    _showPickerDouble(
                        context, 0, 999, 20, '%ไขมัน ขาขวา', 'rightLegFat');
                  }),
              ListTile(
                  leading: Icon(Icons.rotate_left, color: Colors.grey[500]),
                  title: Text("ไขมัน ขาซ้าย"),
                  trailing: Text("${monitorData['leftLegFat'] ?? ''} %",
                      style: TextStyle(color: Colors.grey[500])),
                  onTap: () {
                    _showPickerDouble(
                        context, 0, 999, 20, '%ไขมัน ขาซ้าย', 'leftLegFat');
                  }),
              ListTile(
                  leading: Icon(Icons.border_all, color: Colors.grey[500]),
                  title: Text("ไขมัน หน้าท้อง"),
                  trailing: Text("${monitorData['trunkFat'] ?? ''} %",
                      style: TextStyle(color: Colors.grey[500])),
                  onTap: () {
                    _showPickerDouble(
                        context, 0, 999, 20, '%ไขมัน หน้าท้อง', 'trunkFat');
                  }),
            ],
          ),
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
            .collection('wellness_data')
            .document(uid)
            .collection(collection)
            .document(timestamp.toString());
        Firestore.instance.runTransaction((transaction) async {
          await transaction
              .set(monitor, monitorData)
              .whenComplete(() => Navigator.pop(context));
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
}
