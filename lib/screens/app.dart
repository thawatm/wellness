import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_alert/easy_alert.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wellness/group/group_join.dart';
import 'package:wellness/screens/blood_tests.dart';
import 'package:wellness/screens/contact.dart';
import 'package:wellness/screens/disclaimer.dart';
import 'package:wellness/screens/fat.dart';
import 'package:wellness/screens/intro_page.dart';
import 'package:wellness/screens/kiosk_info_page.dart';
import 'package:wellness/screens/knowledge_simple7.dart';
import 'package:wellness/screens/medical_profile.dart';
import 'package:wellness/screens/newuser.dart';
import 'package:wellness/screens/serving_calulate.dart';
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

class WellnessApp extends StatefulWidget {
  @override
  _WellnessAppState createState() => _WellnessAppState();
}

class _WellnessAppState extends State<WellnessApp> {
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  Future<void> _initializeFlutterFireFuture;

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    // Wait for Firebase to initialize
    await Firebase.initializeApp();

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    // Pass all uncaught errors to Crashlytics.
    Function originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      originalOnError(errorDetails);
    };
  }

  @override
  void initState() {
    super.initState();
    _initializeFlutterFireFuture = _initializeFlutterFire();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initializeFlutterFireFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return loading();
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return AlertProvider(
              config: AlertConfig(
                ok: "OK",
                cancel: "CANCEL",
                useIosStyle: false,
              ),
              child: MaterialApp(
                navigatorObservers: [
                  FirebaseAnalyticsObserver(analytics: analytics),
                ],
                title: 'Wellness Center',

                // debugShowCheckedModeBanner: false,
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
                  '/disclaimer': (context) => DisclaimerPage(),
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
                  '/servingcal': (context) => ServingCalculatePage(),
                  '/knowledge_simple7': (context) => KnowledgeSimple7Page(),
                },
              ),
            );
          }
          return loading();
        });
  }

  Widget _getMainPage() {
    return StreamBuilder<User>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (!snapshot.hasData) {
          //Loading
          if (ScopedModel.of<StateModel>(context).isLoading) return SizedBox();

          //Unauthenticated
          ScopedModel.of<StateModel>(context).isLoading = false;
          return IntroPage();
        }

        //Authenticated
        ScopedModel.of<StateModel>(context).addUser(snapshot.data);
        FirebaseCrashlytics.instance.setUserIdentifier(snapshot.data.uid);
        FirebaseCrashlytics.instance
            .setCustomKey('UserName', snapshot.data.phoneNumber);

        return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('wellness_users')
                .doc(snapshot.data.uid)
                .snapshots(),
            builder: (BuildContext context, userSn) {
              if (!userSn.hasData) return SizedBox();
              if (userSn.data.data() == null) return NewUserPage();

              if (userSn.data.data().isNotEmpty) {
                // logged in
                ScopedModel.of<StateModel>(context).addUserProfile(userSn.data);
                return HomePage();
              }
              return SizedBox();
            });
      },
    );
  }

  Widget loading() {
    return MaterialApp(
        home: Scaffold(
      body: LinearProgressIndicator(),
    ));
  }
}
