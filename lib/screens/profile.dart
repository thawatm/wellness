import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellness/fitness_app/app_theme.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/models/userdata.dart';
import 'package:wellness/screens/user_profile.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/widgets/appbar_ui.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key, this.animationController}) : super(key: key);
  final AnimationController animationController;
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Animation<double> topBarAnimation;
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  final FirebaseStorage storage =
      FirebaseStorage(storageBucket: 'gs://wellness-296bf.appspot.com');
  UserProfile profileData;
  FirebaseUser currentUser;
  ImageProvider profileImage;
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
        body: buildBody(context),
      ),
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
          buildNotificationPanel(width, height),
          AppBarUI(
            animationController: widget.animationController,
            topBarAnimation: topBarAnimation,
            topBarOpacity: topBarOpacity,
            title: 'การตั้งค่า',
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          )
        ],
      ),
    );
  }

  Widget buildNotificationPanel(double width, double height) {
    return Positioned(
      width: width,
      height: height * .70 - 80,
      top: height * 0.30 - 100,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, left: 16, top: 0, bottom: 0),
        child: SingleChildScrollView(
          child: Container(
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
                            routeName: '/user',
                            startColor: Color(0xFFFA7D82),
                            endColor: Color(0xFFFFB295)),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, top: 8, bottom: 8),
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                        ),
                        buildNotificationItem(
                            icon: Icons.group_add,
                            title: 'กลุ่ม',
                            subtitle: 'สำหรับติดตามผลสมาชิกในกลุ่ม',
                            routeName: '/group',
                            startColor: Color(0xFF738AE6),
                            endColor: Color(0xFF5C5EDD)),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, top: 8, bottom: 8),
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                        ),
                        buildNotificationItem(
                            icon: Icons.email,
                            title: 'ติดต่อเรา',
                            subtitle: 'ผู้พัฒนาโปรแกรม',
                            routeName: '/contact',
                            startColor: Color(0xFFFE95B6),
                            endColor: Color(0xFFFF5287)),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, top: 8, bottom: 8),
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                        ),
                        buildNotificationItem(
                            icon: Icons.exit_to_app,
                            title: 'ออกจากระบบ',
                            subtitle: '',
                            routeName: '/logout',
                            startColor: Color(0xFF6F72CA),
                            endColor: Color(0xFF1E1466)),
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

  Widget buildNotificationItem(
      {IconData icon,
      String title,
      String subtitle,
      String routeName,
      Color startColor,
      Color endColor}) {
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
              colors: [startColor, endColor],
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
              color: AppTheme.lightText),
        ),
        subtitle: Text(
          subtitle,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        onTap: () {
          // Navigator.pushNamed(context, routeName);
          switch (routeName) {
            case '/user':
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UserProfilePage(
                            animationController: widget.animationController,
                          )));
              break;
            case '/logout':
              _signOut();
              break;
            default:
              Navigator.pushNamed(context, routeName);
          }
        },
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
