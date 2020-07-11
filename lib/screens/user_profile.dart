import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/datepicker_custom.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/models/userdata.dart';
import 'package:wellness/widgets/edit_profile.dart';
import 'package:intl/intl.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:scoped_model/scoped_model.dart';
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
  bool isLinkKiosk = false;
  String uid;

  final FirebaseStorage storage =
      FirebaseStorage(storageBucket: 'gs://bsp-kiosk.appspot.com');
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
    uid = ScopedModel.of<StateModel>(context).uid;
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
            isMenu: false,
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
          .collection('wellness_users')
          .document(uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();
        profileData = UserProfile.fromSnapshot(snapshot.data);

        if (profileData.pictureUrl != null) {
          profileImage = CachedNetworkImageProvider(profileData.pictureUrl);
        } else {
          profileImage = AssetImage('assets/images/user.png');
        }

        final citizenId = snapshot.data.data['citizenId'];
        (citizenId != null && citizenId.length == 13)
            ? isLinkKiosk = true
            : isLinkKiosk = false;

        return profileData != null
            ? _buildList(context, snapshot.data)
            : LinearProgressIndicator();
      },
    );
  }

  _buildList(BuildContext context, DocumentSnapshot data) {
    String bDate = data['birthdate'] == null
        ? ''
        : DateFormat('dd/MM/yyyy').format(data['birthdate'].toDate());
    String gender;
    String smoke = (data['smoke']) ? 'สูบ' : 'ไม่สูบ';

    if (data['gender'] == 'male') gender = 'ชาย';
    if (data['gender'] == 'female') gender = 'หญิง';

    return ListView(
      padding: EdgeInsets.all(8),
      children: <Widget>[
        SizedBox(height: 80),
        buildHeaderData(),
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
        ListTile(
          leading: Icon(FontAwesomeIcons.male),
          title: Text("ส่วนสูง", style: TextStyle(color: Colors.black54)),
          trailing: Text("${data['height'] ?? '-'} cm",
              style: TextStyle(color: Colors.cyan[800], fontSize: 16)),
          onTap: () =>
              inputOption('height', 'ส่วนสูง', data['height'].toString()),
        ),
        Divider(
          height: 2.0,
        ),
        ListTile(
          leading: data['smoke']
              ? Icon(FontAwesomeIcons.smoking)
              : Icon(FontAwesomeIcons.smokingBan),
          title: Text("ท่านสูบบุหรีหรือไม่",
              style: TextStyle(color: Colors.black54)),
          trailing: Text("${smoke ?? 'ไม่ระบุ'} ",
              style: TextStyle(color: Colors.cyan[800], fontSize: 16)),
          onTap: () => inputOption('smoke', 'สูบบุหรี่', smoke),
        ),
        Divider(
          height: 2.0,
        ),
        isLinkKiosk
            ? ListTile(
                leading: Icon(FontAwesomeIcons.idCard),
                title: Text("เลขบัตรประชาชน",
                    style: TextStyle(color: Colors.black54)),
                trailing: Text("${data['citizenId'] ?? ''}",
                    style: TextStyle(color: Colors.cyan[800], fontSize: 16)),
                // onTap: () =>
                //     inputOption('citizenId', 'เลขบัตรประชาชน', data['citizenId']),
              )
            : SizedBox(),
        Divider(
          height: 2.0,
        ),
        SizedBox(height: 30),
        !isLinkKiosk
            ? ListTile(
                title: Wrap(
                children: <Widget>[
                  Text("เชื่อมต่อเพื่อดูข้อมูลจากระบบ NSTDA Kiosk",
                      style: TextStyle(color: Colors.black54)),
                  // InkResponse(
                  //   child: Text('(ดูข้อมูลเพิ่มเติม)',
                  //       style: TextStyle(color: Colors.blue)),
                  //   onTap: () {
                  //     Navigator.pushNamed(context, '/kioskinfo');
                  //   },
                  // )
                ],
              ))
            : ListTile(
                title: Text("ท่านได้เชื่อมต่อกับระบบ NSTDA Kiosk แล้ว",
                    style: TextStyle(color: Colors.black54))),
        isLinkKiosk ? unlinkKioskButton() : linkKioskButton(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FlatButton(
              padding: EdgeInsets.all(12),
              color: Colors.blueAccent,
              child: Text('ข้อมูลทางการแพทย์',
                  style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () {
                // await unlinkKiosk();
                Navigator.pushNamed(context, '/medical');
              }),
        )
      ],
    );
  }

  void inputOption(String key, String title, dynamic value) async {
    if (isLinkKiosk && !(key == 'height' || key == 'smoke'))
      return _buildDialog(context, 'แจ้งเตือน',
          'ไม่สามารถแก้ไขได้เนื่องจากท่านได้เชื่อมต่อข้อมูลกับระบบ NSTDA Kiosk');
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
              currentTime: value != null ? value.toDate() : DateTime.now()),
        );
        break;
      case 'gender':
        showRoundedModalBottomSheet(
            context: context, builder: (context) => inputGender());
        break;
      case 'smoke':
        showRoundedModalBottomSheet(
            context: context, builder: (context) => inputSmoke());
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
              // maxLength: 13,
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
                  dynamic updateValue = _numberController.value.text;
                  if (key == 'height') updateValue = int.tryParse(updateValue);
                  saveData(key, updateValue);
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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

  Widget inputSmoke() {
    return Container(
      height: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          InkWell(
            onTap: () {
              saveData('smoke', true);
              Navigator.pop(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(FontAwesomeIcons.smoking, size: 60, color: Colors.red),
                Text(
                  'สูบ',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () {
              saveData('smoke', false);
              Navigator.pop(context);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(FontAwesomeIcons.smokingBan,
                    size: 60, color: Colors.green),
                Text(
                  'ไม่สูบ',
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
    if (value == null || uid == null) return;
    Map updateData = Map<String, dynamic>();

    updateData[updateKey] = value;

    DocumentReference ref =
        Firestore.instance.collection('wellness_users').document(uid);
    Firestore.instance.runTransaction((transaction) async {
      await transaction.update(ref, updateData);
    });
  }

  unlinkKiosk() async {
    Map updateData = Map<String, dynamic>();
    updateData['citizenId'] = '';
    DocumentReference ref =
        Firestore.instance.collection('wellness_users').document(uid);
    Firestore.instance.runTransaction((transaction) {
      transaction.update(ref, updateData).then((_) => _buildDialog(
          context, 'ยกเลิก', 'ยกเลิกการเชื่อมต่อกับ NSTDA Kiosk สำเร็จ'));
      deleteKioskData();
      return;
    });
  }

  deleteKioskData() {
    Firestore.instance
        .collection('wellness_data')
        .document(uid)
        .collection('healthdata')
        .getDocuments()
        .then((value) {
      value.documents.forEach((doc) {
        if (doc['kioskDocumentId'] != null) {
          Firestore.instance
              .collection('wellness_data')
              .document(uid)
              .collection('healthdata')
              .document(doc.documentID)
              .delete();
        }
      });
    }).catchError((e) {
      print(e);
    });
  }

  Widget unlinkKioskButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: OutlineButton(
          padding: EdgeInsets.all(12),
          color: Colors.blueAccent,
          borderSide: BorderSide(color: Colors.blue.shade600),
          child: Text('ยกเลิกการเชื่อมต่อ',
              style: TextStyle(color: Colors.blue.shade600, fontSize: 16)),
          onPressed: () async {
            await unlinkKiosk();
          }),
    );
  }

  Widget linkKioskButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FlatButton(
          padding: EdgeInsets.all(12),
          color: Colors.blueAccent,
          child: Text('เชื่อมต่อกับ NSTDA Kiosk',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          onPressed: () {
            // await unlinkKiosk();
            Navigator.pushNamed(context, '/verifycitizenId');
          }),
    );
  }

  Future _buildDialog(BuildContext context, _title, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          // shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.all(Radius.circular(5))),
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

  Widget buildHeaderData() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          child: Container(
            height: 80,
            width: 80,
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

    final uploadPath = '/profile_images/' + uid + '.jpg';
    final StorageReference ref = storage.ref().child(uploadPath);
    final StorageUploadTask uploadTask = ref.putFile(image);

    uploadTask.onComplete
        .then((snapshot) => snapshot.ref.getDownloadURL())
        .then((url) {
      updateData['pictureUrl'] = url;

      DocumentReference ref =
          Firestore.instance.collection('wellness_users').document(uid);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.update(ref, updateData);

        _isTempImage = false;
      });
    });
  }
}
