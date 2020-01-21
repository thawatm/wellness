import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/logic/constant.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/widgets/edit_profile.dart';
import 'package:intl/intl.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // UserProfile profileData;
  TextEditingController _numberController;
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = ScopedModel.of<StateModel>(context).currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text("ข้อมูลส่วนตัว"),
        gradient: LinearGradient(colors: [appBarColor1, appBarColor2]),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection('users')
          .document(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        // profileData = UserProfile.fromSnapshot(snapshot.data);

        return _buildList(context, snapshot.data);
      },
    );
  }

  Widget _buildList(BuildContext context, DocumentSnapshot snapshot) {
    Map<String, dynamic> header = {
      'firstName': 'ชื่อ',
      'lastName': 'นามสกุล',
      'phoneNumber': 'มือถือ',
      'height': 'ส่วนสูง (cm)',
      'sex': 'เพศ',
      'birthday': 'วันเกิด',
      'citizenId': 'เลขบัตรประชาชน',
      'bloodGroup': 'กรุ๊ปเลือด',
      'expense': 'สิทธิการรักษา',
      'email': 'อีเมล',
      'lineId': 'ไลน์ไอดี',
      'address': 'ที่อยู่',
    };

    return ListView.builder(
        itemCount: header.length,
        itemBuilder: (BuildContext context, int index) {
          String key = header.keys.elementAt(index);
          String value = "${snapshot.data[key] ?? ''}";
          String subtitle = '';

          if (key == 'birthday' && value != '') {
            value = DateFormat.yMMMd().format(snapshot.data[key].toDate());
          }

          if (key == 'address' && value != '') {
            subtitle = value;
            value = '';
          }

          return Column(
            children: <Widget>[
              ListTile(
                  title: Text("${header[key]}",
                      style: TextStyle(color: Colors.black54)),
                  trailing: Text(value,
                      style: TextStyle(
                          color: Colors.lightBlue.shade700, fontSize: 16)),
                  subtitle: subtitle != ''
                      ? Padding(
                          padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
                          child: Text(subtitle,
                              style:
                                  TextStyle(color: Colors.lightBlue.shade700)))
                      : null,
                  onTap: () =>
                      inputOption(key, header[key], snapshot.data[key])),
              Divider(
                height: 2.0,
              ),
            ],
          );
        });
  }

  void inputOption(String key, String title, dynamic value) {
    switch (key) {
      case 'phoneNumber':
        break;
      case 'birthday':
        DatePicker.showDatePicker(
          context,
          showTitleActions: true,
          onConfirm: (date) {
            saveData(key, date);
          },
          locale: LocaleType.en,
          minTime: DateTime(1900, 01, 01),
          currentTime: value != null ? value.toDate() : DateTime.now(),
        );
        break;
      case 'sex':
        showRoundedModalBottomSheet(
            context: context, builder: (context) => inputSex());
        break;

      case 'height':
      case 'citizenId':
        _numberController = TextEditingController(text: value);
        showRoundedModalBottomSheet(
            context: context,
            builder: (context) => inputNumber(key, title, value));
        break;
      default:
        showRoundedModalBottomSheet(
            context: context,
            builder: (context) => EditProfile(
                  updateKey: key,
                  currentUser: currentUser,
                  title: title,
                  initialValue: value,
                ));
    }
  }

  Widget inputNumber(String key, String title, dynamic value) {
    return Container(
        height: 300,
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Container(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.centerLeft,
            ),
            TextFormField(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, letterSpacing: 1.0),
              controller: _numberController,
              keyboardType: TextInputType.number,
              // maxLength: 13,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
              ],
            ),
            SizedBox(height: 36),
            Container(
              height: 50,
              width: 150,
              child: RaisedButton(
                elevation: 7.0,
                onPressed: () {
                  saveData(key, _numberController.value.text);
                  Navigator.pop(context);
                },
                padding: EdgeInsets.all(12),
                color: Colors.blueAccent,
                child: Text('Save',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ));
  }

  Widget inputSex() {
    return Container(
      height: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () {
              saveData('sex', 'ชาย');
              Navigator.pop(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(MdiIcons.humanMale, size: 60, color: Colors.blue),
                Text(
                  'ชาย',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
          ),
          SizedBox(width: 70),
          InkWell(
            onTap: () {
              saveData('sex', 'หญิง');
              Navigator.pop(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(MdiIcons.humanFemale, size: 60, color: Colors.pink[300]),
                Text(
                  'หญิง',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  saveData(String updateKey, dynamic value) {
    if (value == null) return;
    Map updateData = Map<String, dynamic>();

    updateData[updateKey] = value;

    DocumentReference ref =
        Firestore.instance.collection("users").document(currentUser.uid);
    Firestore.instance.runTransaction((transaction) async {
      await transaction.update(ref, updateData);
    });
  }
}
