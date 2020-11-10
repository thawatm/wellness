import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';

class ServingCalculatePage extends StatelessWidget {
  final String header1 = 'ผัก 1 ส่วน เทียบได้กับ';
  final String desc1 = '''
    ▪ ผักดิบ 1 ถ้วยตวง (240 มล)
    ▪ ผักสุก (ผักต้ม) 1/2 ถ้วยตวง (120 มล)
    ▪ น้ำผักปั่นก่อนเติมน้ำ 1/2 ถ้วยตวง (160 มล)
  ''';
  final String header2 = 'ผลไม้ 1 ส่วน เทียบได้กับ';
  final String desc2 = '''
    ▪ แอปเปิล 1 ผล (150 กรัม) เท่ากำปั้นผู้ใหญ่
    ▪ ผลไม้แช่แข็งหรือผลไม้กระป๋อง 1/2 ถ้วย (120 มล)
    ▪ ผลไม้แห้ง 1/4 ถ้วย (60 มล)
  ''';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text('ตัวอย่างการคำนวณ serving'),
        gradient: LinearGradient(
            colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 24, 8, 8),
          children: <Widget>[
            Text(
              header1,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              desc1,
            ),
            Text(
              header2,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              desc2,
            ),
          ],
        ),
      ),
    );
  }
}
