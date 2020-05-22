import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  FirebaseUser currentUser;
  String collection = 'weightfat';
  int height = 170;

  Map<String, dynamic> monitorData = {
    'date': DateTime.now(),
  };

  @override
  void initState() {
    super.initState();
    currentUser = ScopedModel.of<StateModel>(context).currentUser;

    final DocumentReference ref =
        Firestore.instance.collection('users').document(currentUser.uid);

    ref.get().then((snapshot) {
      if (snapshot.data.containsKey('height')) {
        height = int.parse(snapshot.data['height']);
      }
    });
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
          // ListTile(
          //     leading: Icon(Icons.person, color: Colors.grey[500]),
          //     title: Text("Body Age"),
          //     trailing: Text("${monitorData['bodyAge'] ?? ''} ปี",
          //         style: TextStyle(color: Colors.grey[500])),
          //     onTap: () {
          //       _showPickerNumber(
          //           context, 0, 150, 35, 'Body Age (ปี)', 'bodyAge');
          //     }),
          // ListTile(
          //     leading: Icon(Icons.border_right, color: Colors.grey[500]),
          //     title: Text("ไขมัน แขนขวา"),
          //     trailing: Text("${monitorData['rightArmFat'] ?? ''} %",
          //         style: TextStyle(color: Colors.grey[500])),
          //     onTap: () {
          //       _showPickerDouble(
          //           context, 0, 100, 20, '%ไขมัน แขนขวา', 'rightArmFat');
          //     }),
          // ListTile(
          //     leading: Icon(Icons.border_left, color: Colors.grey[500]),
          //     title: Text("ไขมัน แขนซ้าย"),
          //     trailing: Text("${monitorData['leftArmFat'] ?? ''} %",
          //         style: TextStyle(color: Colors.grey[500])),
          //     onTap: () {
          //       _showPickerDouble(
          //           context, 0, 100, 20, '%ไขมัน แขนขวา', 'leftArmFat');
          //     }),
          // ListTile(
          //     leading: Icon(Icons.rotate_right, color: Colors.grey[500]),
          //     title: Text("ไขมัน ขาขวา"),
          //     trailing: Text("${monitorData['rightLegFat'] ?? ''} %",
          //         style: TextStyle(color: Colors.grey[500])),
          //     onTap: () {
          //       _showPickerDouble(
          //           context, 0, 100, 20, '%ไขมัน ขาขวา', 'rightLegFat');
          //     }),
          // ListTile(
          //     leading: Icon(Icons.rotate_left, color: Colors.grey[500]),
          //     title: Text("ไขมัน ขาซ้าย"),
          //     trailing: Text("${monitorData['leftLegFat'] ?? ''} %",
          //         style: TextStyle(color: Colors.grey[500])),
          //     onTap: () {
          //       _showPickerDouble(
          //           context, 0, 100, 20, '%ไขมัน ขาซ้าย', 'leftLegFat');
          //     }),
          // ListTile(
          //     leading: Icon(Icons.border_all, color: Colors.grey[500]),
          //     title: Text("ไขมัน หน้าท้อง"),
          //     trailing: Text("${monitorData['trunkFat'] ?? ''} %",
          //         style: TextStyle(color: Colors.grey[500])),
          //     onTap: () {
          //       _showPickerDouble(
          //           context, 0, 100, 20, '%ไขมัน หน้าท้อง', 'trunkFat');
          //     }),
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

    // int timestamp = monitorData['date'].millisecondsSinceEpoch;

    // DocumentReference monitor = Firestore.instance
    //     .collection("monitor")
    //     .document(currentUser.uid)
    //     .collection(collection)
    //     .document(timestamp.toString());
    // Firestore.instance.runTransaction((transaction) async {
    //   await transaction.set(monitor, monitorData);
    // });
    // // print(monitorData.keys);
    // // print(monitorData.values);
    // showInSnackBar("Successful");
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
