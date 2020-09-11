import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/datepicker_custom.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/widgets/edit_profile.dart';

class VerifyCitizenIdPage extends StatefulWidget {
  @override
  _VerifyCitizenIdPageState createState() => _VerifyCitizenIdPageState();
}

class _VerifyCitizenIdPageState extends State<VerifyCitizenIdPage> {
  TextEditingController _numberController;
  Map<String, dynamic> userData = {};
  String uid;
  @override
  void initState() {
    uid = ScopedModel.of<StateModel>(context).uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).buttonColor,
      appBar: GradientAppBar(
        title: Text('ยืนยันตัวตน'),
        gradient: LinearGradient(
            colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('wellness_users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        if (snapshot.data.data != null) {
          userData['firstname'] = snapshot.data.data()['firstname'];
          userData['lastname'] = snapshot.data.data()['lastname'];
          userData['gender'] = snapshot.data.data()['gender'];

          if (snapshot.data.data()['birthdate'] != null) {
            userData['birthdate'] = snapshot.data.data()['birthdate'].toDate();
          }
        }

        return snapshot.data.data != null
            ? _buildList(context, userData)
            : SizedBox();
      },
    );
  }

  _buildList(BuildContext context, Map<String, dynamic> data) {
    String bDate = DateFormat('dd/MM/yyyy').format(data['birthdate']);
    String gender;

    if (data['gender'] == 'male') gender = 'ชาย';
    if (data['gender'] == 'female') gender = 'หญิง';
    return ListView(
      padding: EdgeInsets.all(8),
      children: <Widget>[
        SizedBox(height: 12),
        ListTile(
          title: Text(
              "กรุณาใส่เลขบัตร 13 หลักและตรวจสอบข้อมูลของท่านให้ตรงกับหน้าบัตรประชาชน",
              style: TextStyle(color: Colors.black54)),
        ),
        SizedBox(height: 12),
        ListTile(
          leading: Icon(FontAwesomeIcons.idCard),
          title:
              Text("เลขบัตรประชาชน", style: TextStyle(color: Colors.black54)),
          trailing: data['citizenId'] != null
              ? Text("${data['citizenId']}",
                  style: TextStyle(color: Colors.cyan[800], fontSize: 16))
              : Icon(Icons.keyboard_arrow_down),
          onTap: () =>
              inputOption('citizenId', 'เลขบัตรประชาชน', data['citizenId']),
        ),
        Divider(
          height: 2.0,
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.user),
          title: Text("ชื่อ", style: TextStyle(color: Colors.black54)),
          trailing: Text("${data['firstname'] ?? ''}",
              style: TextStyle(color: Colors.cyan[800], fontSize: 16)),
          onTap: () => inputOption('firstname', 'ชื่อ', data['firstname']),
        ),
        Divider(
          height: 2.0,
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.userFriends),
          title: Text("นามสกุล", style: TextStyle(color: Colors.black54)),
          trailing: Text("${data['lastname'] ?? ''}",
              style: TextStyle(color: Colors.cyan[800], fontSize: 16)),
          onTap: () => inputOption('lastname', 'นามสกุล', data['lastname']),
        ),
        Divider(
          height: 2.0,
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.venusMars),
          title: Text("เพศ", style: TextStyle(color: Colors.black54)),
          trailing: Text("${gender ?? ''}",
              style: TextStyle(color: Colors.cyan[800], fontSize: 16)),
          onTap: () => inputOption('gender', 'เพศ', gender),
        ),
        Divider(
          height: 2.0,
        ),
        ListTile(
          leading: Icon(FontAwesomeIcons.calendar),
          title: Text("วันเกิด", style: TextStyle(color: Colors.black54)),
          trailing: Text(bDate,
              style: TextStyle(color: Colors.cyan[800], fontSize: 16)),
          onTap: () => inputOption('birthdate', 'วันเกิด', data['birthdate']),
        ),
        Divider(
          height: 2.0,
        ),
        SizedBox(height: 40),
        confirmKioskButton(),
      ],
    );
  }

  void inputOption(String key, String title, dynamic value) {
    switch (key) {
      case 'birthdate':
        DatePicker.showPicker(
          context,
          showTitleActions: true,
          onConfirm: (date) {
            saveData(key, date);
          },
          locale: LocaleType.en,
          pickerModel: DatePickerModelCustom(
              locale: LocaleType.en,
              minTime: DateTime(1900, 01, 01),
              currentTime: value != null ? value : DateTime.now()),
        );
        break;
      case 'gender':
        showRoundedModalBottomSheet(
            context: context, builder: (context) => inputGender());
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
                  title: title,
                  initialValue: value,
                  uid: uid,
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
              maxLength: 13,
              inputFormatters: <TextInputFormatter>[
                WhitelistingTextInputFormatter.digitsOnly,
              ],
            ),
            SizedBox(height: 36),
            Container(
              height: 50,
              width: 150,
              child: FlatButton(
                onPressed: () {
                  // dynamic updateValue = _numberController.value.text;
                  // saveData(key, updateValue);
                  setState(() {
                    userData['citizenId'] = _numberController.value.text;
                  });
                  Navigator.pop(context);
                },
                padding: EdgeInsets.all(12),
                color: Colors.blue,
                child: Text('Save',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ));
  }

  Widget inputGender() {
    return Container(
      height: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          InkWell(
            onTap: () {
              saveData('gender', 'male');
              Navigator.pop(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(FontAwesomeIcons.male, size: 60, color: Colors.blue),
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
              saveData('gender', 'female');
              Navigator.pop(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(FontAwesomeIcons.female,
                    size: 60, color: Colors.pink[300]),
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
    Map updateData = Map<String, dynamic>();

    updateData[updateKey] = value;

    FirebaseFirestore.instance
        .collection("wellness_users")
        .doc(uid)
        .update(updateData);
  }

  verify() async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("data")
        .where('citizenId',
            isEqualTo: userData['citizenId'] ?? '__NotNullValue__')
        .get();
    final count = query.docs.where((doc) {
      String gender;
      String birthyear = userData['birthdate'].year.toString();
      if (userData['gender'] == 'male') gender = 'ชาย';
      if (userData['gender'] == 'female') gender = 'หญิง';

      if (doc.data()['firstname'] == userData['firstname'] &&
          doc.data()['lastname'] == userData['lastname'] &&
          doc.data()['gender'] == gender &&
          doc.data()['birthyear'] == birthyear) {
        return true;
      }
      return false;
    }).length;

    if (count > 0) {
      saveData('citizenId', userData['citizenId']);
      Navigator.pop(context);
      return _buildDialog(
          context, 'สำเร็จ', 'เชื่อมต่อกับระบบ NSTDA Kiosk สำเร็จ');
    }
    return _buildDialog(context, 'ผิดพลาด',
        'ไม่พบข้อมูลในระบบ NSTDA Kiosk \n  - กรุณากรอกข้อมูลให้ตรงกับในบัตรประชาชน\n  - หรือลงทะเบียนที่เครื่อง Kiosk ก่อนใช้งาน');
  }

  Widget confirmKioskButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FlatButton(
          padding: EdgeInsets.all(12),
          color: AppTheme.buttonColor,
          child: Text('ยืนยัน',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          onPressed: () async {
            await verify();
          }),
    );
  }

  Future _buildDialog(BuildContext context, _title, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          // shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.all(Radius.circular(8))),
          title: Text(_title),
          content: Text(_message),
          actions: <Widget>[
            FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
    );
  }
}
