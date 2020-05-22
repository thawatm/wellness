import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/dashboard/my_diary/my_diary_screen.dart';
import 'package:wellness/models/fitkitdata.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/report/report_screen.dart';

import 'package:wellness/screens/newsfeed.dart';
import 'package:wellness/screens/profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedTab = 0;
  AnimationController animationController;

  List _pageOptions;
  FirebaseUser currentUser;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _pageOptions = [
      MyDiaryScreen(animationController: animationController),
      NewsPage(animationController: animationController),
      ReportScreen(animationController: animationController),
      ProfilePage(animationController: animationController),
    ];
    super.initState();
    currentUser = ScopedModel.of<StateModel>(context).currentUser;
    DateTime start = DateTime.now().subtract(Duration(days: 7));
    DateTime dateFrom = DateTime(start.year, start.month, start.day);
    FitKitData(dateFrom: dateFrom).read().then((fitData) {
      if (fitData != null && fitData.isNotEmpty) {
        var data = fitData.map((v) {
          return {
            'date': DateFormat('yyyyMMdd').format(v.dateFrom),
            'value': v.value
          };
        });
        groupBy(data, (obj) => obj['date']).forEach((k, v) {
          DateTime recordDate = DateTime.parse(k);
          num sum = v.fold(0, (a, b) => a + b['value']);
          _saveData(recordDate, sum);
        });
      }
    });
  }

  void _saveData(DateTime recordDate, int stepsCount) async {
    int timestamp = recordDate.millisecondsSinceEpoch;
    Map<String, dynamic> monitorData = {
      'date': recordDate,
      'steps': stepsCount,
      'totalWorkout': stepsCount ~/ 400,
    };

    DocumentReference monitor = Firestore.instance
        .collection("monitor")
        .document(currentUser.uid)
        .collection('workout')
        .document(timestamp.toString());
    Firestore.instance.runTransaction((transaction) async {
      await transaction.set(monitor, monitorData);
    });
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
                  iconColor: Colors.grey.shade600,
                  textColor: AppTheme.nearlyPurple,
                  backgroundColor: AppTheme.nearlyPurple.withOpacity(.2),
                  iconSize: 24,
                  icon: Icons.home,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.rss_feed,
                  text: 'News',
                  iconActiveColor: Colors.pink,
                  iconColor: Colors.grey.shade600,
                  textColor: Colors.pink,
                  backgroundColor: Colors.pink.withOpacity(.2),
                  iconSize: 24,
                ),
                GButton(
                  icon: Icons.insert_chart,
                  text: 'Report',
                  iconActiveColor: Colors.blueAccent,
                  iconColor: Colors.grey.shade600,
                  textColor: Colors.blueAccent,
                  backgroundColor: Colors.blueAccent.withOpacity(.2),
                  iconSize: 24,
                ),
                GButton(
                  iconActiveColor: Colors.teal,
                  iconColor: Colors.grey.shade600,
                  textColor: Colors.teal,
                  backgroundColor: Colors.teal.withOpacity(.2),
                  iconSize: 24,
                  icon: Icons.settings,
                  text: 'Setting',
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
