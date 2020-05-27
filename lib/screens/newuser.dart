import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/datepicker_custom.dart';
import 'package:wellness/models/state_model.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:scoped_model/scoped_model.dart';

class NewUserPage extends StatefulWidget {
  const NewUserPage({Key key}) : super(key: key);
  @override
  _NewUserPageState createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  Map userData = Map<String, dynamic>();
  FirebaseUser currentUser;
  bool _autovalidate = false;
  bool _isLoading = false;

  @override
  void initState() {
    currentUser = ScopedModel.of<StateModel>(context).currentUser;
    super.initState();
  }

  // void _handleSubmitted() {
  //   final FormState form = _formKey.currentState;
  //   if (!form.validate()) {
  //     _autovalidate = true; // Start validating on every change.
  //     showInSnackBar('Please fix the errors in red before submitting.');
  //   } else {
  //     _isLoading = true;
  //     form.save();
  //     DocumentReference docRef = Firestore.instance
  //         .collection('wellness_users')
  //         .document(currentUser.uid);
  //     Firestore.instance.runTransaction((transaction) async {
  //       profileData['uid'] = currentUser.uid;
  //       profileData['phoneNumber'] = currentUser.phoneNumber;
  //       await transaction.set(docRef, profileData);
  //       // print("instance saved");
  //     });
  //     showInSnackBar("Successful");
  //     ScopedModel.of<StateModel>(context).isLoading = true;
  //     Navigator.pushReplacementNamed(context, '/');
  //   }
  // }

  void _handleSubmitted() {
    if (_fbKey.currentState.saveAndValidate()) {
      // print(_fbKey.currentState.value);
      var userData = _fbKey.currentState.value;
      userData['citizenId'] = '';

      if (userData['gender'] == 'ชาย') userData['gender'] = 'male';
      if (userData['gender'] == 'หญิง') userData['gender'] = 'female';

      if (userData['smoke'] == 'สูบ') userData['smoke'] = true;
      if (userData['smoke'] == 'ไม่สูบ') userData['smoke'] = false;

      setState(() {
        _isLoading = true;
      });
      DocumentReference docRef = Firestore.instance
          .collection('wellness_users')
          .document(currentUser.uid);
      Firestore.instance.runTransaction((transaction) async {
        userData['uid'] = currentUser.uid;
        userData['phoneNumber'] = currentUser.phoneNumber;
        await transaction.set(docRef, userData);
        // print("instance saved");
      });
      showInSnackBar("Successful");
      ScopedModel.of<StateModel>(context).isLoading = true;

      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    } else {
      // print(_fbKey.currentState.value);
      setState(() {
        _isLoading = false;
      });
      print("validation failed");
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerDragStartBehavior: DragStartBehavior.down,
      key: _scaffoldKey,
      appBar: GradientAppBar(
        title: Text('ผู้ใช้งานใหม่'),
        gradient: LinearGradient(
            colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
      ),
      body: ModalProgressHUD(child: _formView(), inAsyncCall: _isLoading),
    );
  }

  Widget _formView() {
    return SafeArea(
      top: false,
      bottom: false,
      child: FormBuilder(
        key: _fbKey,
        autovalidate: _autovalidate,
        child: SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.down,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <
                  Widget>[
            const SizedBox(height: 30.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8.0),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: FormBuilderTextField(
                      maxLines: 1,
                      attribute: "firstname",
                      decoration: InputDecoration(
                        labelText: "ชื่อ",
                      ),
                      // onChanged: _onChanged,
                      validators: [
                        FormBuilderValidators.required(errorText: 'ใส่ชื่อ'),
                        FormBuilderValidators.max(50),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Flexible(
                    child: FormBuilderTextField(
                      maxLines: 1,
                      attribute: "lastname",
                      decoration: InputDecoration(
                        labelText: "นามสกุล",
                      ),
                      // onChanged: _onChanged,
                      validators: [
                        FormBuilderValidators.required(errorText: 'ใส่นามสกุล'),
                        FormBuilderValidators.max(50),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8.0),
              child: FormBuilderDateTimePicker(
                attribute: "birthdate",
                inputType: InputType.date,
                format: DateFormat("dd/MM/yyyy"),
                decoration: InputDecoration(labelText: "วัน/เดือน/ปี เกิด"),
                datePicker: (context) => DatePicker.showPicker(
                  context,
                  showTitleActions: true,
                  locale: LocaleType.en,
                  pickerModel: DatePickerModelCustom(
                      locale: LocaleType.en,
                      minTime: DateTime(1900, 01, 01),
                      currentTime: DateTime.now()),
                ),
                validators: [
                  FormBuilderValidators.required(errorText: 'บอกวันเกิด')
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8.0),
              child: FormBuilderDropdown(
                attribute: "gender",
                decoration: InputDecoration(labelText: "เพศ"),
                hint: Text('เลือกเพศ'),
                validators: [
                  FormBuilderValidators.required(errorText: 'เลือกเพศ')
                ],
                items: ['ชาย', 'หญิง']
                    .map((gender) =>
                        DropdownMenuItem(value: gender, child: Text("$gender")))
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8.0),
              child: FormBuilderTextField(
                maxLines: 1,
                keyboardType: TextInputType.number,
                attribute: "height",
                decoration: InputDecoration(labelText: "ส่วนสูง (cm)"),
                valueTransformer: (text) =>
                    double.tryParse("${text.isEmpty ? '0' : text}").floor(),
                validators: [
                  FormBuilderValidators.required(errorText: 'ใส่ส่วนสูง'),
                  FormBuilderValidators.numeric(errorText: 'ส่วนสูงไม่ถูกต้อง')
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8.0),
              child: FormBuilderDropdown(
                attribute: "smoke",
                decoration: InputDecoration(labelText: "สูบบุหรี่หรือไม่"),
                hint: Text('เลือกคำตอบ'),
                validators: [
                  FormBuilderValidators.required(errorText: 'เลือกคำตอบ')
                ],
                items: ['สูบ', 'ไม่สูบ']
                    .map((smoke) =>
                        DropdownMenuItem(value: smoke, child: Text("$smoke")))
                    .toList(),
              ),
            ),
            const SizedBox(height: 40.0),
            Center(
              child: Container(
                height: 50,
                width: 200,
                child: RaisedButton.icon(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    _handleSubmitted();
                  },
                  elevation: 7.0,
                  color: AppTheme.buttonColor,
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text('ยืนยัน',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
