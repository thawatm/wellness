import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wellness/fitness_app/app_theme.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/models/userdata.dart';
import 'package:wellness/widgets/edit_profile.dart';
import 'package:intl/intl.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:wellness/widgets/appbar_ui.dart';
import 'package:wellness/widgets/image_source.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key key, this.animationController}) : super(key: key);
  final AnimationController animationController;
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  Animation<double> topBarAnimation;
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  // UserProfile profileData;
  TextEditingController _numberController;
  FirebaseUser currentUser;

  final FirebaseStorage storage =
      FirebaseStorage(storageBucket: 'gs://wellness-296bf.appspot.com');
  UserProfile profileData;
  ImageProvider profileImage;
  bool _isTempImage = false;
  File tempImage;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
    currentUser = ScopedModel.of<StateModel>(context).currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: <Widget>[
          _buildBody(context),
          AppBarUI(
            animationController: widget.animationController,
            topBarAnimation: topBarAnimation,
            topBarOpacity: topBarOpacity,
            title: 'ผู้ใช้งาน',
            isPop: true,
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          )
        ]),
      ),
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
        profileData = UserProfile.fromSnapshot(snapshot.data);

        if (profileData.pictureUrl != null) {
          profileImage = CachedNetworkImageProvider(profileData.pictureUrl);
        } else {
          profileImage = AssetImage('assets/images/user.png');
        }

        return profileData != null
            ? _buildList(context, snapshot.data)
            : LinearProgressIndicator();
      },
    );
  }

  Widget _buildList(BuildContext context, DocumentSnapshot snapshot) {
    Map<String, dynamic> header = {
      'profileImage': 'รูปโปร์ไฟล์',
      'firstName': 'ชื่อ',
      'lastName': 'นามสกุล',
      'memberId': 'เลขที่สมาชิก',
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

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            bottomLeft: Radius.circular(8.0),
            bottomRight: Radius.circular(8.0),
            topRight: Radius.circular(8.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
              color: AppTheme.grey.withOpacity(0.2),
              offset: Offset(1.1, 1.1),
              blurRadius: 10.0),
        ],
      ),
      child: ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.only(
            top: AppBar().preferredSize.height +
                MediaQuery.of(context).padding.top +
                24,
            bottom: 62 + MediaQuery.of(context).padding.bottom,
          ),
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

            if (key == 'profileImage') {
              return buildHeaderData();
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
                                style: TextStyle(
                                    color: Colors.lightBlue.shade700)))
                        : null,
                    onTap: () =>
                        inputOption(key, header[key], snapshot.data[key])),
                Divider(
                  height: 2.0,
                ),
              ],
            );
          }),
    );
  }

  void inputOption(String key, String title, dynamic value) {
    switch (key) {
      case 'phoneNumber':
        break;
      case 'memberId':
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

  Widget buildHeaderData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: new Border.all(color: Colors.grey.shade300, width: 2),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: _isTempImage ? FileImage(tempImage) : profileImage,
                )),
          ),
          onTap: () => showRoundedModalBottomSheet(
              context: context,
              builder: (context) => ImageSourceModal(
                    onTabCamera: () => getCameraImage(),
                    onTabGallery: () => getGalleryImage(),
                  )),
        ),
        // SizedBox(height: 10),
        // Text(
        //   "เลขที่สมาชิก: ${profileData.memberId ?? '-'}",
        //   style: TextStyle(color: AppTheme.lightText, fontSize: 18),
        // ),
        SizedBox(height: 20),
      ],
    );
  }

  Future getCameraImage() async {
    File image = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 200.0,
    );
    if (image != null) {
      setState(() {
        tempImage = image;
        _isTempImage = true;
      });
      uploadPictureProfile(image);
    }
  }

  Future getGalleryImage() async {
    File image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200.0,
    );
    if (image != null) {
      setState(() {
        tempImage = image;
        _isTempImage = true;
      });
      uploadPictureProfile(image);
    }
  }

  uploadPictureProfile(File image) {
    Map updateData = Map<String, dynamic>();

    final uploadPath = '/profile_images/' + currentUser.uid + '.jpg';
    final StorageReference ref = storage.ref().child(uploadPath);
    final StorageUploadTask uploadTask = ref.putFile(image);

    uploadTask.onComplete
        .then((snapshot) => snapshot.ref.getDownloadURL())
        .then((url) {
      updateData['pictureUrl'] = url;

      DocumentReference ref =
          Firestore.instance.collection("users").document(currentUser.uid);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.update(ref, updateData);

        _isTempImage = false;
      });
    });
  }
}
