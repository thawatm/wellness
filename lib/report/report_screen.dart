import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:jiffy/jiffy.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/dashboard/ui_view/glass_view.dart';
import 'package:wellness/dashboard/ui_view/title_view.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/report/card_simple7.dart';
import 'package:wellness/report/food_trend.dart';
import 'package:wellness/report/food_view.dart';
import 'package:wellness/report/sleep_trend.dart';
import 'package:wellness/report/sleep_view.dart';
import 'package:wellness/report/stepcount_view.dart';
import 'package:wellness/report/totalworkout_view.dart';
import 'package:wellness/report/water_trend.dart';
import 'package:wellness/report/water_view.dart';
import 'package:wellness/report/workout_trend.dart';
import 'package:wellness/widgets/appbar_ui.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key key, this.animationController, this.uid})
      : super(key: key);

  final AnimationController animationController;
  final String uid;
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with TickerProviderStateMixin {
  Animation<double> topBarAnimation;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  String uid;
  String totalWorkout = '-';
  String avgServing = '-';
  String bmi = '-';
  String pressure = '-';
  String cholesterol = '-';
  String ldl = '-';
  String glucose = '-';
  String hba1c = '-';
  DateTime startDate = DateTime.now();
  Future<bool> initData; //changed

  QuerySnapshot healthSn;
  QuerySnapshot workoutSn;
  QuerySnapshot foodSn;
  QuerySnapshot waterSn;
  QuerySnapshot sleepSn;

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
    uid = ScopedModel.of<StateModel>(context).uid;
    initData = getData();
    super.initState();
  }

  void addAllListData() {
    listViews.add(
      GlassView(
        text:
            "สุขภาพของท่านอยู่ในเกณฑ์ที่ดี การออกกำลังกายมากกว่าอาทิตย์ที่ผ่านมา ควรเพิ่มการกินผักและผลไม้ให้มากขึ้น",
      ),
    );

    listViews.add(Simple7Card(
      workout: totalWorkout,
      food: avgServing,
      bmi: bmi,
      pressure: pressure,
      cholesterol: cholesterol,
      ldl: ldl,
      glucose: glucose,
      hba1c: hba1c,
    ));

    listViews.add(
      TitleView(
        titleTxt: 'ก้าวเดิน',
        subTxt: 'เพิ่ม',
        targetPage: WorkoutTrendChart(snapshot: workoutSn),
      ),
    );
    listViews.add(
      StepCountChartView(
        startDate: startDate,
        snapshot: workoutSn,
      ),
    );
    listViews.add(
      TitleView(
        titleTxt: 'ออกกำลังกาย',
        subTxt: '',
        targetPage: WorkoutTrendChart(snapshot: workoutSn),
      ),
    );
    listViews.add(
      TotalWorkoutChartView(
        startDate: startDate,
        snapshot: workoutSn,
      ),
    );
    listViews.add(
      TitleView(
        titleTxt: 'ผักและผลไม้',
        subTxt: 'เพิ่ม',
        targetPage: FoodTrendChart(snapshot: foodSn),
      ),
    );
    listViews.add(
      FoodChartView(
        startDate: startDate,
        snapshot: foodSn,
      ),
    );
    listViews.add(
      TitleView(
        titleTxt: 'ดื่มน้ำ',
        subTxt: 'เพิ่ม',
        targetPage: WaterTrendChart(snapshot: waterSn),
      ),
    );
    listViews.add(
      WaterChartView(
        startDate: startDate,
        snapshot: waterSn,
      ),
    );
    listViews.add(
      TitleView(
        titleTxt: 'การนอน',
        subTxt: 'เพิ่ม',
        targetPage: SleepTrendChart(snapshot: sleepSn),
      ),
    );
    listViews.add(
      SleepChartView(
        startDate: startDate,
        snapshot: sleepSn,
      ),
    );
  }

  Future<bool> getData() async {
    DocumentReference docRef =
        Firestore.instance.collection('wellness_data').document(uid);

    await docRef.collection('workout').getDocuments().then((snapshot) {
      workoutSn = snapshot;
    });
    await docRef.collection('food').getDocuments().then((snapshot) {
      foodSn = snapshot;
    });
    await docRef.collection('healthdata').getDocuments().then((snapshot) {
      healthSn = snapshot;
    });
    await docRef.collection('water').getDocuments().then((snapshot) {
      waterSn = snapshot;
    });
    await docRef.collection('sleep').getDocuments().then((snapshot) {
      sleepSn = snapshot;
    });
    buildSimple7Data(startDate);
    return true;
  }

  void buildSimple7Data(DateTime startDate) {
    DateTime s = DateTime.now();
    if (startDate != null) s = startDate;
    // DateTime lastweek = s.subtract(Duration(days: 7));
    List<DocumentSnapshot> workoutSnapshot =
        getWeeklyData(workoutSn, 'date', 'totalWorkout', s);
    totalWorkout = getSum(workoutSnapshot, 'totalWorkout').toString();
    List<DocumentSnapshot> foodSnapshot =
        getWeeklyData(foodSn, 'date', 'serving', s);
    avgServing = (getSum(foodSnapshot, 'serving') / 7).toStringAsFixed(1);
    pressure = getLastPressureData(healthSn);
    bmi = getLastData(healthSn, 'bmi', decimal: 1);
    cholesterol = getLastData(healthSn, 'cholesterol');
    ldl = getLastData(healthSn, 'ldl');
    glucose = getLastData(healthSn, 'glucose');
    hba1c = getLastData(healthSn, 'hba1c', decimal: 1, unit: '%');
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
              title: 'รายงาน',
              // calendar: _buildWeeklyCalendar(),
              isPop: true,
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCalendar() {
    return Row(
      children: <Widget>[
        InkWell(
            child: Text('< ',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.nearlyBlack)),
            onTap: () {
              setState(() {
                startDate = startDate.subtract(Duration(days: 7));
                listViews = [];
                buildSimple7Data(startDate);
              });
            }),
        InkWell(
          child: Text(getWeekDayList(startDate),
              style: TextStyle(fontSize: 20, color: AppTheme.nearlyBlack)),
        ),
        InkWell(
            child: Text(' >',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.nearlyBlack)),
            onTap: () {
              setState(() {
                startDate = startDate.add(Duration(days: 7));
                listViews = [];
                buildSimple7Data(startDate);
              });
            }),
      ],
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: initData,
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

  List<DocumentSnapshot> getWeeklyData(
      QuerySnapshot snapshot, String date, String value, DateTime startDate) {
    try {
      DateTime s = DateTime.now();
      if (startDate != null) s = startDate;
      List<DocumentSnapshot> snapshotData = snapshot.documents.where((v) {
        DateTime d = v.data[date].toDate();
        return v.data[value] != null &&
            Jiffy(d).week == Jiffy(s).week &&
            Jiffy(d).year == Jiffy(s).year;
      }).toList();
      return snapshotData;
    } catch (e) {
      print(e);
    }
    return null;
  }

  num getSumByDay(
      List<DocumentSnapshot> snapshotData, String date, String value) {
    if (snapshotData != null) {
      var data = snapshotData.map((v) {
        return {
          'day': Jiffy(v.data[date].toDate()).day,
          'value': v.data[value]
        };
      });
      groupBy(data, (obj) => obj['day']).forEach((k, v) {
        num sum = v.fold(0, (a, b) {
          if (b['value'] is String) return a + num.parse(b['value']);
          return a + b['value'];
        });
        return sum;
      });
    }
    return 0;
  }

  num getSum(List<DocumentSnapshot> snapshotData, String key) {
    if (snapshotData != null) {
      num sum = snapshotData.where((v) => v[key] != null).fold(0, (a, b) {
        if (b[key] is String) return a + num.parse(b[key]);
        return a + b[key];
      });
      return sum;
    }
    return 0;
  }

  String getLastData(QuerySnapshot snapshot, String key,
      {int decimal: 0, String unit: ''}) {
    try {
      DocumentSnapshot s4 =
          snapshot.documents.where((v) => v[key] != null).last;
      if (s4 != null) {
        return s4.data[key].toStringAsFixed(0);
      }
    } catch (e) {
      print(e);
    }
    return '-';
  }

  String getLastPressureData(QuerySnapshot snapshot) {
    try {
      DocumentSnapshot s = snapshot.documents
          .where(
              (v) => v['pressureUpper'] != null && v['pressureLower'] != null)
          .last;
      if (s != null) {
        return s.data['pressureUpper'].toStringAsFixed(0) +
            '/' +
            s.data['pressureLower'].toStringAsFixed(0);
      }
    } catch (e) {
      print(e);
    }
    return '-';
  }

  String getWeekDayList(DateTime startDate) {
    DateTime sDate = Jiffy(startDate).startOf(Units.WEEK);
    DateTime eDate = Jiffy(startDate).endOf(Units.WEEK);

    String s = Jiffy(sDate).MMMd;
    String e = Jiffy(eDate).MMMd;

    if (sDate.month == eDate.month) e = Jiffy(eDate).date.toString();
    if (sDate.year != DateTime.now().year) {
      s = Jiffy(sDate).yMMMd;
      e = Jiffy(eDate).yMMMd;
    }

    return s + ' - ' + e;
  }
}
