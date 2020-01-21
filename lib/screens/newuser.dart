import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/logic/constant.dart';
import 'package:wellness/models/state_model.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:scoped_model/scoped_model.dart';

class NewUserPage extends StatefulWidget {
  const NewUserPage({Key key}) : super(key: key);
  @override
  _NewUserPageState createState() => _NewUserPageState();
}

class _NewUserPageState extends State<NewUserPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map profileData = Map<String, dynamic>();
  FirebaseUser currentUser;
  DocumentReference users;
  bool _autovalidate = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    currentUser = ScopedModel.of<StateModel>(context).currentUser;
    if (currentUser != null) {
      final DocumentReference ref =
          Firestore.instance.collection('users').document('memberId');
      int nextId;
      Map updateData = Map<String, dynamic>();

      ref.get().then((snapshot) {
        if (snapshot.data.containsKey('currentId')) {
          nextId = snapshot.data['currentId'] + 1;
          updateData['currentId'] = nextId;
          Firestore.instance.runTransaction((transaction) async {
            await transaction.update(ref, updateData);

            profileData['memberId'] = nextId.toString();
            profileData['uid'] = currentUser.uid;
            profileData['phoneNumber'] = currentUser.phoneNumber;

            users = Firestore.instance
                .collection("users")
                .document(currentUser.uid);
            Firestore.instance.runTransaction((transaction) async {
              await transaction.set(users, profileData);
              // print("instance created");
            });
          });
        }
      });
    } else {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      _isLoading = true;
      form.save();
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(users, profileData);
        // print("instance saved");
      });
      showInSnackBar("Successful");
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  // String _validateEmail(String value) {
  //   // if (value.isEmpty) return 'Email is required.';
  //   if (value.isEmpty) return null;
  //   final RegExp emailExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
  //   if (!emailExp.hasMatch(value)) return 'Please enter email address';
  //   return null;
  // }

  String _validateInput(String value) {
    if (value.isEmpty) return 'This field is required.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerDragStartBehavior: DragStartBehavior.down,
      key: _scaffoldKey,
      appBar: GradientAppBar(
        title: Text('ผู้ใช้งานใหม่'),
        gradient: LinearGradient(colors: [appBarColor1, appBarColor2]),
      ),
      body: ModalProgressHUD(child: _formView(), inAsyncCall: _isLoading),
    );
  }

  Widget _formView() {
    return SafeArea(
      top: false,
      bottom: false,
      child: Form(
        key: _formKey,
        autovalidate: _autovalidate,
        child: SingleChildScrollView(
          dragStartBehavior: DragStartBehavior.down,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 24.0),
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: Icon(Icons.person),
                    // hintText: 'ชื่อ',
                    labelText: 'ชื่อ',
                  ),
                  onSaved: (String value) {
                    profileData['firstName'] = value;
                  },
                  validator: _validateInput,
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: Icon(Icons.group),
                    // hintText: 'นามสกุล',
                    labelText: 'นามสกุล',
                  ),
                  onSaved: (String value) {
                    profileData['lastName'] = value;
                  },
                  validator: _validateInput,
                ),
                SizedBox(height: 24.0),
                TextFormField(
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    filled: true,
                    icon: Icon(MdiIcons.human),
                    // hintText: 'ส่วนสูง',
                    labelText: 'ส่วนสูง (cm)',
                  ),
                  keyboardType: TextInputType.number,
                  onSaved: (String value) {
                    profileData['height'] = value;
                  },
                  validator: _validateInput,
                ),
                // TextFormField(
                //   decoration: const InputDecoration(
                //     border: UnderlineInputBorder(),
                //     filled: true,
                //     icon: Icon(Icons.email),
                //     hintText: 'Your email address',
                //     labelText: 'E-mail',
                //   ),
                //   keyboardType: TextInputType.emailAddress,
                //   onSaved: (String value) {
                //     profileData['email'] = value;
                //   },
                //   validator: _validateEmail,
                // ),
                const SizedBox(height: 40.0),
                Center(
                  child: Container(
                    height: 50,
                    width: 200,
                    child: RaisedButton.icon(
                      onPressed: _handleSubmitted,
                      elevation: 7.0,
                      color: Colors.blueAccent,
                      icon: Icon(Icons.check, color: Colors.white),
                      label: Text('ยืนยัน',
                          style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                Text(
                  '* indicates required field',
                  style: Theme.of(context).textTheme.caption,
                ),
                const SizedBox(height: 24.0),
              ]),
        ),
      ),
    );
  }
}
