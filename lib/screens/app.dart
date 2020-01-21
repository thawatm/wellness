import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/screens/blood_tests.dart';
import 'package:wellness/screens/contact.dart';
import 'package:wellness/screens/medical_profile.dart';
import 'package:wellness/screens/newuser.dart';
import 'package:wellness/screens/user_profile.dart';
import 'package:wellness/screens/weight_bmi.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'package:wellness/models/state_model.dart';
import 'package:wellness/screens/home.dart';
import 'package:wellness/screens/login.dart';
import 'package:wellness/screens/phone_signup.dart';
import 'package:wellness/screens/drink_monitor.dart';
import 'package:wellness/screens/food_monitor.dart';
import 'package:wellness/screens/health_monitor.dart';
import 'package:wellness/screens/sleep_monitor.dart';

class WellnessApp extends StatelessWidget {
  final String questionnaire =
      'https://docs.google.com/forms/d/e/1FAIpQLSer0Mx_f40Ia5usYm98xVaZfPakFf2ANlsWHQ6IEnCuo7Fn2A/viewform';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellness Center',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Kanit',
        primarySwatch: Colors.blue,
        primaryTextTheme: TextTheme(
          title: TextStyle(color: Colors.white),
        ),
      ),
      routes: {
        '/': (context) => _getMainPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/signup': (context) => SignInPage(),
        '/newuser': (context) => NewUserPage(),
        '/health': (context) => HealthMonitorPage(),
        '/weight': (context) => WeightPage(),
        '/blood': (context) => BloodTestPage(),
        '/food': (context) => FoodMonitorPage(),
        '/sleep': (context) => SleepMonitorPage(),
        '/drink': (context) => DrinkMonitorPage(),
        '/medical': (context) => MedicalProfilePage(),
        '/user': (context) => UserProfilePage(),
        '/contact': (context) => ContactPage(),
        '/questionnaire': (context) => WebviewScaffold(
              url: questionnaire,
              appBar: GradientAppBar(
                title: const Text("Smart Body"),
                gradient: LinearGradient(
                    colors: [Color(0xff38bbad), Color(0xff2b7a98)]),
              ),
              withLocalStorage: true,
              hidden: true,
            ),
      },
    );
  }

  Widget _getMainPage() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          // logged in
          ScopedModel.of<StateModel>(context).addUser(snapshot.data);
          return HomePage();
        } else {
          ScopedModel.of<StateModel>(context).dispose();
          return LoginPage();
        }
      },
    );
  }
}
