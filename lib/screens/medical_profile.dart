import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/models/userdata.dart';
import 'package:scoped_model/scoped_model.dart';

class MedicalProfilePage extends StatefulWidget {
  @override
  _MedicalProfilePageState createState() => _MedicalProfilePageState();
}

class _MedicalProfilePageState extends State<MedicalProfilePage> {
  String uid;

  UserProfile profileData;
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    uid = ScopedModel.of<StateModel>(context).uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          title: Text('ข้อมูลทางการแพทย์'),
          gradient: LinearGradient(
              colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
        ),
        body: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('wellness_users')
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
              profileData = UserProfile.fromSnapshot(snapshot.data);

              return SafeArea(
                child: FormBuilder(
                  key: _fbKey,
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8.0),
                        child: FormBuilderTextField(
                          initialValue: snapshot.data.data()['diagnosis'] ?? '',
                          maxLines: 2,
                          keyboardType: TextInputType.text,
                          attribute: "diagnosis",
                          decoration: InputDecoration(labelText: "โรคประจำตัว"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8.0),
                        child: FormBuilderTextField(
                          initialValue:
                              snapshot.data.data()['currentMedication'] ?? '',
                          maxLines: 2,
                          keyboardType: TextInputType.text,
                          attribute: "currentMedication",
                          decoration: InputDecoration(labelText: "ยาปัจจุบัน"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8.0),
                        child: FormBuilderTextField(
                          initialValue:
                              snapshot.data.data()['passMedication'] ?? '',
                          maxLines: 2,
                          keyboardType: TextInputType.text,
                          attribute: "passMedication",
                          decoration: InputDecoration(labelText: "ยาที่เคยกิน"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8.0),
                        child: FormBuilderTextField(
                          initialValue:
                              snapshot.data.data()['vaccination'] ?? '',
                          maxLines: 2,
                          keyboardType: TextInputType.text,
                          attribute: "vaccination",
                          decoration:
                              InputDecoration(labelText: "ประวัติวัคซีน"),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 8.0),
                        child: FormBuilderTextField(
                          initialValue:
                              snapshot.data.data()['drugAllergy'] ?? '',
                          maxLines: 2,
                          keyboardType: TextInputType.text,
                          attribute: "drugAllergy",
                          decoration:
                              InputDecoration(labelText: "ประวัติการแพ้"),
                        ),
                      ),
                      const SizedBox(height: 60.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: FlatButton(
                            padding: EdgeInsets.all(12),
                            color: AppTheme.buttonColor,
                            child: Text('Save',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              if (_fbKey.currentState.saveAndValidate()) {
                                print(_fbKey.currentState.value);
                                var userData = _fbKey.currentState.value;
                                _saveData(userData);
                                Navigator.pop(context);
                              }
                            }),
                      )
                    ],
                  ),
                ),
              );
            }));
  }

  _saveData(Map<String, dynamic> updateData) {
    FirebaseFirestore.instance
        .collection('wellness_users')
        .doc(uid)
        .update(updateData);
  }
}
