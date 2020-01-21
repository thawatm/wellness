import 'package:wellness/fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';

import 'package:wellness/screens/monitor.dart';
import 'package:wellness/screens/newsfeed.dart';
import 'package:wellness/screens/profile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 1;
  final _pageOptions = [
    NewsPage(),
    MonitorPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _pageOptions[_selectedTab],
        bottomNavigationBar: FancyBottomNavigation(
          initialSelection: 1,
          tabs: [
            TabData(iconData: Icons.rss_feed, title: "ข่าว"),
            TabData(iconData: Icons.home, title: "หน้าหลัก"),
            TabData(iconData: Icons.person, title: "ข้อมูลส่วนตัว")
          ],
          onTabChangedListener: (position) {
            setState(() {
              _selectedTab = position;
            });
          },
        ));
  }
}
