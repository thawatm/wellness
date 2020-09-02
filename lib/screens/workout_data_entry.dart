import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/state_model.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wellness/widgets/edit_dialog.dart';

class WorkoutDataEntry extends StatefulWidget {
  @override
  _WorkoutDataEntryState createState() => _WorkoutDataEntryState();
}

class _WorkoutDataEntryState extends State<WorkoutDataEntry> {
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  String uid;
  String collection = 'workout';

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
              leading: Icon(FontAwesomeIcons.walking, color: Colors.blue[500]),
              title: Text("เดิน"),
              trailing: Text("${monitorData['steps'] ?? ''} ก้าว",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                showRoundedModalBottomSheet(
                    context: context,
                    builder: (context) => EditDialog(
                          title: 'จำนวนก้าวเดิน',
                          initialValue: '',
                          textInputType: TextInputType.number,
                          onSave: _saveStepData,
                        ));
              }),
          ListTile(
              leading: Icon(FontAwesomeIcons.running, color: Colors.orange),
              title: Text("วิ่ง"),
              trailing: Text("${monitorData['run'] ?? ''} นาที",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerNumber(context, 0, 500, 20, 'วิ่ง (นาที)', 'run');
              }),
          ListTile(
              leading: Icon(FontAwesomeIcons.biking, color: Colors.green),
              title: Text("ปั่นจักรยาน"),
              trailing: Text("${monitorData['cycling'] ?? ''} นาที",
                  style: TextStyle(color: Colors.grey[500])),
              onTap: () {
                _showPickerNumber(
                    context, 0, 500, 20, 'ปั่นจักรยาน (นาที)', 'cycling');
              }),
          ListTile(
              leading: Icon(FontAwesomeIcons.dumbbell, color: Colors.purple),
              title: Text("ออกกำลังกายแบบอื่น"),
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
            padding: EdgeInsets.all(16),
            child: Text(
                '*การออกกำลังกายแบบต่อเนื่อง (Aerobic exercise) นับเฉพาะช่วงที่ได้ออกแรงถึงระดับหนักพอควร คือ หัวใจเต้นเร็วขึ้น หายใจเร็วขึ้น หรือหอบเหนื่อยจนร้องเพลงไม่ได้แต่ยังพูดได้ เช่น เดินเร็ว, jogging, ว่ายน้ำ, ปั่นจักรยาน',
                style: TextStyle(color: Colors.red.withOpacity(0.8))),
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

  void _saveStepData(String steps) {
    setState(() {
      monitorData['steps'] = int.tryParse(steps);
    });
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

        // if (monitorData['steps'] != null)
        //   monitorData['steps'] = monitorData['steps'] * 400;

        monitorData['totalWorkout'] = (monitorData['run'] ?? 0) +
            (monitorData['cycling'] ?? 0) +
            (monitorData['etc'] ?? 0);

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
}
