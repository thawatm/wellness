import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';

class GroupAdminPage extends StatefulWidget {
  @override
  _GroupAdminPageState createState() => _GroupAdminPageState();
}

class _GroupAdminPageState extends State<GroupAdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
            title: Text('เพิ่มผู้ดูแล'),
            gradient: LinearGradient(
                colors: [AppTheme.appBarColor1, AppTheme.appBarColor2])),
        body: buildBody());
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              IconButton(icon: Icon(Icons.search), onPressed: null),
            ],
          )
        ],
      ),
    );
  }
}
