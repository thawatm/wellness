import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/fitness_app/app_theme.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/models/userdata.dart';
import 'package:wellness/widgets/edit_profile.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:scoped_model/scoped_model.dart';

class MedicalProfilePage extends StatefulWidget {
  @override
  _MedicalProfilePageState createState() => _MedicalProfilePageState();
}

class _MedicalProfilePageState extends State<MedicalProfilePage> {
  FirebaseUser currentUser;

  bool _isDrugAllergy = false;
  bool _isDrugAllergySuspect = false;
  bool _isFoodAllergy = false;

  UserProfile profileData;

  @override
  void initState() {
    super.initState();
    currentUser = ScopedModel.of<StateModel>(context).currentUser;

    final DocumentReference ref =
        Firestore.instance.collection('users').document(currentUser.uid);

    ref.get().then((snapshot) {
      if (snapshot.data.containsKey('isDrugAllergy')) {
        _isDrugAllergy = snapshot.data['isDrugAllergy'];
      }
      if (snapshot.data.containsKey('isDrugAllergySuspect')) {
        _isDrugAllergySuspect = snapshot.data['isDrugAllergySuspect'];
      }
      if (snapshot.data.containsKey('isFoodAllergy')) {
        _isFoodAllergy = snapshot.data['isFoodAllergy'];
      }
    });
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
            stream: Firestore.instance
                .collection('users')
                .document(currentUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
              profileData = UserProfile.fromSnapshot(snapshot.data);

              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.only(top: 8.0),
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        'เคยมีการแพ้ยาจากการตรวจวินิจฉัยของแพทย์หรือไม่',
                        style: TextStyle(color: Colors.black),
                      ),
                      trailing: Switch(
                        value: _isDrugAllergy,
                        onChanged: (bool value) {
                          setState(() {
                            _isDrugAllergy = value;
                            if (_isDrugAllergy) _isDrugAllergySuspect = false;
                            _saveData();
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _isDrugAllergy = !_isDrugAllergy;
                          if (_isDrugAllergy) _isDrugAllergySuspect = false;
                          _saveData();
                        });
                      },
                    ),
                    _isDrugAllergy ? buildDrugAllergy() : buildNoDrugAllergy(),
                    (_isDrugAllergySuspect && !_isDrugAllergy)
                        ? buildDrugAllergySuspect()
                        : SizedBox(height: 0),
                    ListTile(
                      title: Text(
                        'มีการแพ้อาหารใดหรือไม่',
                        style: TextStyle(color: Colors.black),
                      ),
                      trailing: Switch(
                        value: _isFoodAllergy,
                        onChanged: (bool value) {
                          setState(() {
                            _isFoodAllergy = value;
                            _saveData();
                          });
                        },
                      ),
                      onTap: () {
                        setState(() {
                          _isFoodAllergy = !_isFoodAllergy;
                          _saveData();
                        });
                      },
                    ),
                    _isFoodAllergy ? buildFoodAllergy() : SizedBox(height: 0),
                  ],
                ),
              );
            }));
  }

  Widget buildDrugAllergy() {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(
            'ชนิดยาที่แพ้',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            '${profileData.drugAllergy ?? ''}',
            style: TextStyle(color: Colors.cyan[800], fontSize: 16),
          ),
          onTap: () => showRoundedModalBottomSheet(
              context: context,
              builder: (context) => EditProfile(
                    currentUser: currentUser,
                    title: 'ชนิดยาที่แพ้',
                    initialValue: '${profileData.drugAllergy ?? ''}',
                    updateKey: 'drugAllergy',
                  )),
        ),
        ListTile(
          title: Text(
            'โรงพยาบาลที่วินิจฉัยการแพ้',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            '${profileData.diagnoseHospital ?? ''}',
            style: TextStyle(color: Colors.cyan[800], fontSize: 16),
          ),
          onTap: () => showRoundedModalBottomSheet(
              context: context,
              builder: (context) => EditProfile(
                    currentUser: currentUser,
                    title: 'โรงพยาบาลที่วินิจฉัยการแพ้',
                    initialValue: '${profileData.diagnoseHospital ?? ''}',
                    updateKey: 'diagnoseHospital',
                  )),
        ),
        ListTile(
          title: Text(
            'อาการที่เกิดจากอาการแพ้',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            '${profileData.allergySymptom ?? ''}',
            style: TextStyle(color: Colors.cyan[800], fontSize: 16),
          ),
          onTap: () => showRoundedModalBottomSheet(
              context: context,
              builder: (context) => EditProfile(
                    currentUser: currentUser,
                    title: 'อาการที่เกิดจากอาการแพ้',
                    initialValue: '${profileData.allergySymptom ?? ''}',
                    updateKey: 'allergySymptom',
                  )),
        ),
        ListTile(
          title: Text(
            'แพทย์ที่ดูแล',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            '${profileData.doctor ?? ''}',
            style: TextStyle(color: Colors.cyan[800], fontSize: 16),
          ),
          onTap: () => showRoundedModalBottomSheet(
              context: context,
              builder: (context) => EditProfile(
                    currentUser: currentUser,
                    title: 'แพทย์ที่ดูแล',
                    initialValue: '${profileData.doctor ?? ''}',
                    updateKey: 'doctor',
                  )),
        ),
        ListTile(
          title: Text(
            'โรงพยาบาลที่รับการรักษา',
            style: TextStyle(color: Colors.black),
          ),
          subtitle: Text(
            '${profileData.treatmentHospital ?? ''}',
            style: TextStyle(color: Colors.cyan[800], fontSize: 16),
          ),
          onTap: () => showRoundedModalBottomSheet(
              context: context,
              builder: (context) => EditProfile(
                    currentUser: currentUser,
                    title: 'โรงพยาบาลที่รับการรักษา',
                    initialValue: '${profileData.treatmentHospital ?? ''}',
                    updateKey: 'treatmentHospital',
                  )),
        ),
      ],
    );
  }

  Widget buildNoDrugAllergy() {
    return ListTile(
      title: Text(
        'มีอาการที่สงสัยว่าอาจจะเกิดจากอาการแพ้หรือไม่',
        style: TextStyle(color: Colors.black),
      ),
      trailing: Switch(
        value: _isDrugAllergySuspect,
        onChanged: (bool value) {
          setState(() {
            _isDrugAllergySuspect = value;
            _saveData();
          });
        },
      ),
      onTap: () {
        setState(() {
          _isDrugAllergySuspect = !_isDrugAllergySuspect;
          _saveData();
        });
      },
    );
  }

  Widget buildDrugAllergySuspect() {
    return ListTile(
      title: Text(
        'ระบุอาการ',
        style: TextStyle(color: Colors.black),
      ),
      subtitle: Text(
        '${profileData.suspectSymptom ?? ''}',
        style: TextStyle(color: Colors.cyan[800], fontSize: 16),
      ),
      onTap: () => showRoundedModalBottomSheet(
          context: context,
          builder: (context) => EditProfile(
                currentUser: currentUser,
                title: 'ระบุอาการ',
                initialValue: '${profileData.suspectSymptom ?? ''}',
                updateKey: 'suspectSymptom',
              )),
    );
  }

  Widget buildFoodAllergy() {
    return Column(children: <Widget>[
      ListTile(
        title: Text(
          'ชนิดอาหาร',
          style: TextStyle(color: Colors.black),
        ),
        subtitle: Text(
          '${profileData.foodAllergy ?? ''}',
          style: TextStyle(color: Colors.cyan[800], fontSize: 16),
        ),
        onTap: () => showRoundedModalBottomSheet(
            context: context,
            builder: (context) => EditProfile(
                  currentUser: currentUser,
                  title: 'ชนิดอาหาร',
                  initialValue: '${profileData.foodAllergy ?? ''}',
                  updateKey: 'foodAllergy',
                )),
      ),
      ListTile(
        title: Text(
          'วัตถุดิบ หรือส่วนผสมต่างๆ',
          style: TextStyle(color: Colors.black),
        ),
        subtitle: Text(
          '${profileData.ingredientAllergy ?? ''}',
          style: TextStyle(color: Colors.cyan[800], fontSize: 16),
        ),
        onTap: () => showRoundedModalBottomSheet(
            context: context,
            builder: (context) => EditProfile(
                  currentUser: currentUser,
                  title: 'วัตถุดิบ หรือส่วนผสมต่างๆ',
                  initialValue: '${profileData.ingredientAllergy ?? ''}',
                  updateKey: 'ingredientAllergy',
                )),
      )
    ]);
  }

  _saveData() {
    Map updateData = Map<String, dynamic>();

    updateData['isDrugAllergy'] = _isDrugAllergy;
    updateData['isDrugAllergySuspect'] = _isDrugAllergySuspect;
    updateData['isFoodAllergy'] = _isFoodAllergy;

    DocumentReference ref =
        Firestore.instance.collection("users").document(currentUser.uid);
    Firestore.instance.runTransaction((transaction) async {
      await transaction.update(ref, updateData);
    });
  }
}
