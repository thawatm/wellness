import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/state_model.dart';
import 'package:intl/intl.dart';

import 'package:scoped_model/scoped_model.dart';

class WeightDataEntry extends StatefulWidget {
  @override
  _WeightDataEntryState createState() => _WeightDataEntryState();
}

class _WeightDataEntryState extends State<WeightDataEntry> {
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  String uid;
  String collection = 'healthdata';
  int height = 170;

  Map<String, dynamic> monitorData = {
    'date': DateTime.now(),
    'category': 'weight'
  };

  @override
  void initState() {
    super.initState();
    uid = ScopedModel.of<StateModel>(context).uid;
    height = ScopedModel.of<StateModel>(context).userProfile.height;
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
              title: Text("น้ำหนัก"),
              trailing: Text("${monitorData['weight'] ?? ''} kg",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerDouble(
                    context, 20, 300, 70, 'น้ำหนัก (kg)', 'weight');
              }),
          ListTile(
              leading: Text('BMI', style: TextStyle(color: Colors.grey[500])),
              title: Text('ค่าดัชนีมวลกาย'),
              // title: bmiBarCart(),
              trailing: Text(
                  "${height != null ? (monitorData['bmi'] ?? '') : 'ต้องระบุส่วนสูงที่โปรไฟล์'}",
                  style: TextStyle(fontSize: 16, color: Colors.black)),
              onTap: () {
                _showPickerDouble(
                    context, 20, 300, 70, 'น้ำหนัก (kg)', 'weight');
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

        FirebaseFirestore.instance
            .collection('wellness_data')
            .doc(uid)
            .collection(collection)
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

            if (updateKey == 'weight')
              monitorData['bmi'] = bmiCal(monitorData['weight']);
          });
        }).showDialog(context);
  }

  double bmiCal(weight) {
    if (height == null) return 0;
    double bmi = weight * 10000 / (height * height);
    return double.parse(bmi.toStringAsFixed(2));
  }

  Widget bmiBarCart() {
    double barWidth = MediaQuery.of(context).size.width / 4 - 30;
    double pos = 80;

    return Container(
      height: 65,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: <Widget>[
          // Icon(Icons.arrow_drop_down, size: 40, color: Colors.red),
          Positioned(
            left: pos,
            top: 0,
            child: Column(
              children: <Widget>[
                Text(
                  "${height != null ? (monitorData['bmi'] ?? '') : 'ต้องระบุส่วนสูงที่โปรไฟล์'}",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
                Icon(Icons.location_on, size: 24, color: Colors.red)
              ],
            ),
          ),
          Row(children: <Widget>[
            Container(
              height: 15,
              width: barWidth,
              color: Colors.blue,
            ),
            Container(
              height: 15,
              width: barWidth,
              color: Colors.green,
            ),
            Container(
              height: 15,
              width: barWidth,
              color: Colors.orange,
            ),
            Container(
              height: 15,
              width: barWidth,
              color: Colors.red,
            ),
          ])
        ],
      ),
    );
  }
}
