import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/dashboard/ui_view/bloodpressure_view.dart';
import 'package:wellness/dashboard/ui_view/bloodtest_view.dart';
import 'package:wellness/dashboard/ui_view/body_measurement.dart';
import 'package:wellness/dashboard/ui_view/fat_view.dart';
import 'package:wellness/dashboard/ui_view/sleep_view.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/dashboard/my_diary/meals_list_view.dart';
import 'package:wellness/dashboard/my_diary/water_view.dart';
import 'package:flutter/material.dart';
import 'package:wellness/dashboard/ui_view/workout_view.dart';
import 'package:wellness/models/fitkitdata.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/models/userdata.dart';
import 'package:wellness/widgets/appbar_ui.dart';

class MyDiaryScreen extends StatefulWidget {
  const MyDiaryScreen({Key key, this.animationController}) : super(key: key);

  final AnimationController animationController;
  @override
  _MyDiaryScreenState createState() => _MyDiaryScreenState();
}

class _MyDiaryScreenState extends State<MyDiaryScreen>
    with TickerProviderStateMixin {
  Animation<double> topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;
  String uid;
  UserProfile userProfile;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
    uid = ScopedModel.of<StateModel>(context).uid;
    userProfile = ScopedModel.of<StateModel>(context).userProfile;

    getFitData();

    if (userProfile.citizenId is String && userProfile.citizenId.length == 13) {
      getKioskData();
    }
  }

  void getKioskData() {
    try {
      Firestore.instance
          .collection("data")
          .where('citizenId', isEqualTo: userProfile.citizenId)
          .getDocuments()
          .then((snapshot) {
        if (snapshot != null) {
          snapshot.documents.forEach((doc) {
            _saveKioskData(doc);
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _saveKioskData(DocumentSnapshot document) {
    String dateString = document.documentID;
    if (dateString.length >= 14) {
      int yStr = int.parse(dateString.substring(0, 4));
      if (yStr > 2500 && yStr < 2600) {
        yStr = yStr - 543;
        dateString = yStr.toString() + dateString.substring(4);
      }
      String temp =
          dateString.substring(0, 8) + 'T' + dateString.substring(8, 14);
      DateTime date = DateTime.parse(temp);
      int timestamp = date.millisecondsSinceEpoch;

      num bpupper = document.data["bpupper"];
      num bplower = document.data["bplower"];
      num pulse = document.data["pulse"];

      num height = document.data["height"];
      num weight = document.data["weight"];
      num bmi = weight * 100 * 100 / (height * height);

      String kioskLocation = document.data["location"];

      Map<String, dynamic> kioskData = {
        'date': date,
        'pressureUpper': bpupper,
        'pressureLower': bplower,
        'hr': pulse,
        'weight': weight,
        'height': height,
        'bmi': num.parse(bmi.toStringAsFixed(2)),
        'kioskDocumentId': document.documentID,
        'kioskLocation': kioskLocation
      };
      kioskData.forEach((key, value) {
        if (value is num && value < 0) kioskData[key] = null;
      });

      try {
        Firestore.instance
            .collection('wellness_data')
            .document(uid)
            .collection('healthdata')
            .document(timestamp.toString())
            .setData(kioskData);
      } catch (e) {
        print(e);
      }
    }
  }

  void getFitData() {
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
          _saveFitData(recordDate, sum.toInt());
        });
      }
    });
  }

  void _saveFitData(DateTime recordDate, int stepsCount) {
    int timestamp = recordDate.millisecondsSinceEpoch;

    Map<String, dynamic> monitorData = {
      'date': recordDate,
      'steps': stepsCount,
      'totalWorkout': stepsCount ~/ 400,
    };
    try {
      Firestore.instance
          .collection('wellness_data')
          .document(uid)
          .collection('workout')
          .document(timestamp.toString())
          .setData(monitorData);
    } catch (e) {
      print(e);
    }
  }

  void addAllListData() {
    const int count = 9;

    listViews.add(
      InkWell(
        onTap: () => Navigator.of(context).pushNamed('/workout'),
        child: WorkoutView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController,
                  curve: Interval((1 / count) * 1, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController,
        ),
      ),
    );

    listViews.add(
      InkWell(
        onTap: () => Navigator.of(context).pushNamed('/food'),
        child: MealsListView(
          mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController,
                  curve: Interval((1 / count) * 3, 1.0,
                      curve: Curves.fastOutSlowIn))),
          mainScreenAnimationController: widget.animationController,
        ),
      ),
    );

    listViews.add(
      InkWell(
        onTap: () => Navigator.of(context).pushNamed('/weight'),
        child: BodyMeasurementView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController,
                  curve: Interval((1 / count) * 5, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController,
        ),
      ),
    );

    listViews.add(
      InkWell(
        onTap: () => Navigator.of(context).pushNamed('/pressure'),
        child: BloodPressureView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController,
                  curve: Interval((1 / count) * 5, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController,
        ),
      ),
    );

    listViews.add(
      InkWell(
        onTap: () => Navigator.of(context).pushNamed('/blood'),
        child: BloodTestView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController,
                  curve: Interval((1 / count) * 5, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController,
        ),
      ),
    );

    listViews.add(
      InkWell(
        onTap: () => Navigator.of(context).pushNamed('/drink'),
        child: WaterView(
          mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController,
                  curve: Interval((1 / count) * 7, 1.0,
                      curve: Curves.fastOutSlowIn))),
          mainScreenAnimationController: widget.animationController,
        ),
      ),
    );

    listViews.add(
      InkWell(
        onTap: () => Navigator.of(context).pushNamed('/sleep'),
        child: SleepView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController,
                  curve: Interval((1 / count) * 5, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController,
        ),
      ),
    );

    listViews.add(
      InkWell(
        onTap: () => Navigator.of(context).pushNamed('/fat'),
        child: FatView(
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: widget.animationController,
                  curve: Interval((1 / count) * 5, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: widget.animationController,
        ),
      ),
    );
  }

  Future<bool> getData() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            getMainListViewUI(),
            AppBarUI(
              animationController: widget.animationController,
              topBarAnimation: topBarAnimation,
              topBarOpacity: topBarOpacity,
              title: 'สุขภาพวันนี้',
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          if (listViews.isEmpty) addAllListData();
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top +
                  24,
              bottom: 62 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              widget.animationController.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }
}
