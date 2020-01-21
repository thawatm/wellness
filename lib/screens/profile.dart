import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wellness/logic/constant.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/models/userdata.dart';
import 'package:wellness/widgets/image_source.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:rounded_modal/rounded_modal.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseStorage storage =
      FirebaseStorage(storageBucket: 'gs://wellness-296bf.appspot.com');
  UserProfile profileData;
  FirebaseUser currentUser;
  ImageProvider profileImage;
  bool _isTempImage = false;
  File tempImage;

  @override
  void initState() {
    super.initState();
    currentUser = ScopedModel.of<StateModel>(context).currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: StreamBuilder<DocumentSnapshot>(
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
                ? buildBody(context)
                : LinearProgressIndicator();
          }),
    );
  }

  Widget buildBody(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.shade100,
                  Colors.blueAccent.shade700
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          buildHeader(width, height),
          buildHeaderData(height, width),
          buildNotificationPanel(width, height),
        ],
      ),
    );
  }

  Widget buildHeader(double width, double height) {
    return Positioned(
      top: 24,
      child: Container(
        width: width,
        height: height * .30,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  FlatButton(
                    child: Text(
                      "Sign Out",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () => _signOut(),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildHeaderData(double height, double width) {
    return Positioned(
      top: (height * .30) / 2 - 40,
      width: width,
      child: Column(
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
          SizedBox(height: 5),
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/user'),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "${profileData.firstName ?? ''} " +
                      "${profileData.lastName ?? ''}",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.pushNamed(context, '/user'),
            child: Text(
              "เลขสมาชิก ${profileData.memberId ?? '-'}",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNotificationPanel(double width, double height) {
    return Positioned(
      width: width,
      height: height * .70 - 80,
      top: height * 0.30 + 20,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, left: 16, top: 0, bottom: 0),
        child: SingleChildScrollView(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 15, bottom: 15),
              child: Column(
                children: <Widget>[
                  Material(
                    // elevation: 1,
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        buildNotificationItem(
                            icon: Icons.person,
                            title: 'ข้อมูลส่วนตัว',
                            subtitle: 'รายละเอียดส่วนตัว',
                            routeName: '/user'),
                        Divider(
                          height: 3,
                          color: Colors.black87,
                        ),
                        buildNotificationItem(
                            icon: Icons.local_hospital,
                            title: 'ข้อมูลทางการแพทย์',
                            subtitle: 'ประวัติแพ้ยาและอาหาร',
                            routeName: '/medical'),
                        Divider(
                          height: 3,
                          color: Colors.black87,
                        ),
                        // buildNotificationItem(
                        //     icon: Icons.chat,
                        //     title: 'แบบสอบถาม',
                        //     subtitle: 'Smart Body',
                        //     routeName: '/questionnaire'),
                        // Divider(
                        //   height: 3,
                        //   color: Colors.black87,
                        // ),
                        buildNotificationItem(
                            icon: Icons.phone_in_talk,
                            title: 'ติดต่อเรา',
                            subtitle: 'หมายเลขฉุกเฉิน',
                            routeName: '/contact'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBodyCardTitle({String title}) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              color: Color(0xff06866C),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "View All",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget buildNotificationItem(
      {IconData icon, String title, String subtitle, String routeName}) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 10),
        leading: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [appBarColor1, appBarColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            icon,
            size: 28,
            color: Colors.white70,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700),
        ),
        subtitle: Text(
          subtitle,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        trailing: Container(
          height: 40,
          width: 70,
          child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 30,
              )),
        ),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
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
