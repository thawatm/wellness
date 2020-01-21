import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile(
      {Key key,
      @required this.currentUser,
      this.title,
      this.initialValue,
      this.updateKey})
      : assert(title != null),
        super(key: key);
  final String title;
  final String initialValue;
  final FirebaseUser currentUser;
  final String updateKey;

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController _controller;
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 300,
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Container(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              padding: const EdgeInsets.all(12),
              alignment: Alignment.centerLeft,
            ),
            Container(
              child: TextFormField(
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
                controller: _controller,
                keyboardType: TextInputType.text,
              ),
            ),
            SizedBox(height: 36),
            Container(
              height: 50,
              width: 150,
              child: RaisedButton(
                elevation: 7.0,
                onPressed: () {
                  saveData(_controller.value.text);
                  Navigator.pop(context);
                },
                padding: EdgeInsets.all(12),
                color: Colors.blueAccent,
                child: Text('Save',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ));
  }

  saveData(String value) {
    Map updateData = Map<String, dynamic>();

    updateData[widget.updateKey] = value;

    DocumentReference ref =
        Firestore.instance.collection("users").document(widget.currentUser.uid);
    Firestore.instance.runTransaction((transaction) async {
      await transaction.update(ref, updateData);
    });
  }
}
