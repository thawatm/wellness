import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:wellness/fitness_app/my_diary/my_diary_screen.dart';

import 'package:wellness/screens/monitor.dart';
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

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    _pageOptions = [
      MyDiaryScreen(animationController: animationController),
      NewsPage(animationController: animationController),
      MonitorPage(),
      ProfilePage(animationController: animationController),
    ];
    super.initState();
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
                  iconActiveColor: Colors.purple,
                  iconColor: Colors.grey.shade600,
                  textColor: Colors.purple,
                  backgroundColor: Colors.purple.withOpacity(.2),
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
                  icon: Icons.chat,
                  text: 'Report',
                  iconActiveColor: Colors.amber[600],
                  iconColor: Colors.grey.shade600,
                  textColor: Colors.amber[600],
                  backgroundColor: Colors.amber[600].withOpacity(.2),
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
