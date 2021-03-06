import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_package_manager/flutter_package_manager.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/dashboard/my_diary/my_diary_screen.dart';
import 'package:wellness/group/group_screen.dart';

import 'package:wellness/report/report_screen.dart';

import 'package:wellness/screens/newsfeed.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedTab = 0;
  AnimationController animationController;

  List _pageOptions;
  User currentUser;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _pageOptions = [
      MyDiaryScreen(animationController: animationController),
      ReportScreen(animationController: animationController),
      GroupScreen(animationController: animationController),
      NewsPage(animationController: animationController),
    ];

    if (Platform.isAndroid) {
      FlutterPackageManager.getPackageInfo('com.google.android.apps.fitness')
          .then((value) {
        if (value == null)
          SchedulerBinding.instance
              .addPostFrameCallback((_) => _showGoogleFitAlert(context));
      });
    }
  }

  @override
  dispose() {
    animationController.dispose(); // you need this
    super.dispose();
  }

  Future<void> _showGoogleFitAlert(BuildContext context) async {
    if (context == null) return;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('แจ้งเตือน'),
          content: Text(
              'ท่านต้องติดตั้ง Google Fit และเปิดเข้าไป Setup ใช้งานครั้งแรก พร้อมทั้งเปิดการ Track Activities'),
          actions: <Widget>[
            FlatButton(
              child: Text(' OK '),
              onPressed: () {
                launch(
                    'https://play.google.com/store/apps/details?id=com.google.android.apps.fitness');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pageOptions[_selectedTab],
      bottomNavigationBar: gBar(),
    );
  }

  Widget gBar() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
      ]),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              duration: Duration(milliseconds: 800),
              tabBackgroundColor: Colors.grey[800],
              tabs: [
                GButton(
                  iconActiveColor: AppTheme.nearlyPurple,
                  iconColor: Colors.grey.shade500,
                  textColor: AppTheme.nearlyPurple,
                  backgroundColor: AppTheme.nearlyPurple.withOpacity(.2),
                  iconSize: 24,
                  icon: Icons.home,
                  text: 'Today',
                ),
                GButton(
                  iconActiveColor: AppTheme.nearlyPurple,
                  iconColor: Colors.grey.shade500,
                  textColor: AppTheme.nearlyPurple,
                  backgroundColor: AppTheme.nearlyPurple.withOpacity(.2),
                  iconSize: 24,
                  icon: Icons.insert_chart,
                  text: 'Weekly',
                ),
                GButton(
                  icon: Icons.group,
                  text: 'Group',
                  iconActiveColor: AppTheme.nearlyPurple,
                  iconColor: Colors.grey.shade500,
                  textColor: AppTheme.nearlyPurple,
                  backgroundColor: AppTheme.nearlyPurple.withOpacity(.2),
                  iconSize: 24,
                ),
                GButton(
                  icon: Icons.rss_feed,
                  text: 'News',
                  iconActiveColor: AppTheme.nearlyPurple,
                  iconColor: Colors.grey.shade500,
                  textColor: AppTheme.nearlyPurple,
                  backgroundColor: AppTheme.nearlyPurple.withOpacity(.2),
                  iconSize: 24,
                ),
              ],
              selectedIndex: _selectedTab,
              onTabChange: (index) {
                setState(() {
                  _selectedTab = index;
                });
              }),
        ),
      ),
    );
  }
}
