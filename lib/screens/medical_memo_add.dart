import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/state_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:mime_type/mime_type.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_alert/easy_alert.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';

class MedicalMemoAddPage extends StatefulWidget {
  @override
  _MedicalMemoAddPageState createState() => _MedicalMemoAddPageState();
}

class _MedicalMemoAddPageState extends State<MedicalMemoAddPage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final FirebaseStorage storage =
      FirebaseStorage(storageBucket: 'gs://bsp-kiosk.appspot.com');
  File tempImage;
  String uid;

  @override
  void initState() {
    super.initState();
    uid = ScopedModel.of<StateModel>(context).uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text('เพิ่มข้อมูล'),
        gradient: LinearGradient(
            colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return FormBuilder(
      key: _fbKey,
      autovalidateMode: AutovalidateMode.always,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
            child: FormBuilderImagePicker(
              attribute: 'images',
              decoration: const InputDecoration(
                labelText: 'รูปภาพ',
                labelStyle: TextStyle(fontSize: 24),
              ),
              imageQuality: 90,
              maxWidth: 2400,
              defaultImage: NetworkImage(
                  'https://firebasestorage.googleapis.com/v0/b/bsp-kiosk.appspot.com/o/default_images%2Fimage-placeholder.jpg?alt=media'),
              maxImages: 1,
              iconColor: Colors.red,
              // readOnly: true,
              validators: [
                FormBuilderValidators.required(errorText: 'ใส่รูปภาพ'),
              ],
              // onChanged: _onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
            child: FormBuilderTextField(
              maxLines: 3,
              attribute: 'note',
              decoration: InputDecoration(
                labelText: 'รายละเอียด',
                contentPadding: EdgeInsets.only(top: 10.0, bottom: 4),
              ),
              style: TextStyle(fontSize: 18),
              // onChanged: _onChanged,
              validators: [
                FormBuilderValidators.required(errorText: 'ใส่รายละเอียด'),
              ],
            ),
          ),
          const SizedBox(height: 40.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FlatButton(
                padding: EdgeInsets.all(12),
                color: AppTheme.buttonColor,
                child: Text('Save',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (_fbKey.currentState.saveAndValidate()) {
                    var userData = _fbKey.currentState.value;
                    _saveData(userData);
                    Navigator.pop(context);
                  }
                }),
          ),
        ],
      ),
    );
  }

  _saveData(var userData) {
    DateTime now = DateTime.now();
    Map<String, dynamic> memoData = {'date': now};

    try {
      int timestamp = now.millisecondsSinceEpoch;
      File imageFile = userData['images'][0];

      String mimeType = mime(imageFile.uri.path);
      String ext = '.jpg';

      if (mimeType == 'image/png') {
        ext = '.png';
      }

      final uploadPath =
          '/note_images/' + uid + '/' + timestamp.toString() + ext;
      final StorageReference ref = storage.ref().child(uploadPath);
      final StorageUploadTask uploadTask = ref.putFile(imageFile);

      uploadTask.onComplete
          .then((snapshot) => snapshot.ref.getDownloadURL())
          .then((url) {
        memoData['imageUrl'] = url;
        memoData['uploadPath'] = uploadPath;
        memoData['note'] = userData['note'];

        FirebaseFirestore.instance
            .collection('wellness_data')
            .doc(uid)
            .collection('medical_note')
            .doc(timestamp.toString())
            .set(memoData);
      });
    } catch (e) {
      print(e);
      Alert.toast(context, 'อัพโหลดรูปภาพไม่ได้');
    }
  }
}
