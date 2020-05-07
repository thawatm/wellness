import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellness/screens/blood_tests.dart';
import 'package:wellness/screens/contact.dart';
import 'package:wellness/screens/fat.dart';
import 'package:wellness/screens/medical_profile.dart';
import 'package:wellness/screens/newuser.dart';
import 'package:wellness/screens/user_profile.dart';
import 'package:wellness/screens/weight_bmi.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:wellness/models/state_model.dart';
import 'package:wellness/screens/home.dart';
import 'package:wellness/screens/login.dart';
import 'package:wellness/screens/phone_signup.dart';
import 'package:wellness/screens/drink_monitor.dart';
import 'package:wellness/screens/food_monitor.dart';
import 'package:wellness/screens/health_monitor.dart';
import 'package:wellness/screens/sleep_monitor.dart';
import 'package:wellness/screens/workout.dart';

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
          headline6: TextStyle(color: Colors.white),
        ),
      ),
      routes: {
        '/': (context) => _getMainPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/signup': (context) => SignInPage(),
        '/newuser': (context) => NewUserPage(),
        '/pressure': (context) => HealthMonitorPage(),
        '/weight': (context) => WeightPage(),
        '/fat': (context) => FatPage(),
        '/blood': (context) => BloodTestPage(),
        '/food': (context) => FoodMonitorPage(),
        '/sleep': (context) => SleepMonitorPage(),
        '/drink': (context) => DrinkMonitorPage(),
        '/group': (context) => MedicalProfilePage(),
        '/user': (context) => UserProfilePage(),
        '/contact': (context) => ContactPage(),
        '/workout': (context) => WorkoutPage(),
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
