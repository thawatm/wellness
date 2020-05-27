import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellness/group/group_join.dart';
import 'package:wellness/screens/blood_tests.dart';
import 'package:wellness/screens/contact.dart';
import 'package:wellness/screens/fat.dart';
import 'package:wellness/screens/intro_page.dart';
import 'package:wellness/screens/kiosk_info_page.dart';
import 'package:wellness/screens/medical_profile.dart';
import 'package:wellness/screens/newuser.dart';
import 'package:wellness/screens/user_profile.dart';
import 'package:wellness/screens/verify_citizenId_page.dart';
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
import 'package:wellness/group/group_add.dart';

class WellnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertProvider(
      config: AlertConfig(
        ok: "OK",
        cancel: "CANCEL",
        useIosStyle: false,
      ),
      child: MaterialApp(
        title: 'Wellness Center',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Prompt',
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
          '/medical': (context) => MedicalProfilePage(),
          '/user': (context) => UserProfilePage(),
          '/contact': (context) => ContactPage(),
          '/workout': (context) => WorkoutPage(),
          '/verifycitizenId': (context) => VerifyCitizenIdPage(),
          '/kioskinfo': (context) => KioskInfoPage(),
          '/groupadd': (context) => GroupAddPage(),
          '/groupjoin': (context) => GroupJoinPage(),
        },
      ),
    );
  }

  Widget _getMainPage() {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        return StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance
                .collection('wellness_users')
                .document(snapshot?.data?.uid)
                .snapshots(),
            builder: (BuildContext context, userSn) {
              if (snapshot.hasData && userSn.hasData) {
                //Authenticated
                ScopedModel.of<StateModel>(context).addUser(snapshot.data);

                // new user
                if (userSn.data.data == null) return NewUserPage();

                // logged in
                ScopedModel.of<StateModel>(context).addUserProfile(userSn.data);
                return HomePage();
              } else {
                //Loading
                if (ScopedModel.of<StateModel>(context).isLoading)
                  return SizedBox();

                //Unauthenticated
                ScopedModel.of<StateModel>(context).dispose();
                return IntroPage();
              }
            });
      },
    );
  }
}
