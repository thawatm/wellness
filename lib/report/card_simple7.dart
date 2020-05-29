import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/rulebase_ai.dart';
import 'package:wellness/report/food_trend.dart';
import 'package:wellness/report/health_trend.dart';
import 'package:wellness/report/weekly_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wellness/report/workout_trend.dart';

class Simple7Card extends StatelessWidget {
  final num workout;
  final num food;
  final num bmi;
  final num bpupper;
  final num bplower;
  final num cholesterol;
  final num ldl;
  final num glucose;
  final num hba1c;
  final QuerySnapshot workoutSnapshot;
  final QuerySnapshot foodSnapshot;
  final QuerySnapshot healthSnapshot;
  final bool smoke;

  Simple7Card({
    Key key,
    @required this.workout,
    @required this.food,
    @required this.bmi,
    @required this.bpupper,
    @required this.bplower,
    @required this.cholesterol,
    @required this.ldl,
    @required this.glucose,
    @required this.hba1c,
    @required this.workoutSnapshot,
    @required this.foodSnapshot,
    @required this.healthSnapshot,
    this.smoke: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 0, bottom: 18),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.0),
              bottomLeft: Radius.circular(8.0),
              bottomRight: Radius.circular(8.0),
              topRight: Radius.circular(8.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: AppTheme.grey.withOpacity(0.2),
                offset: Offset(1.1, 1.1),
                blurRadius: 10.0),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        WorkoutTrendChart(snapshot: workoutSnapshot)),
              ),
              child: WeeklyCard(
                iconColor: Colors.blue,
                dataColor: RuleBaseAI.workout(workout).display.color,
                icon: FontAwesomeIcons.running,
                title: "ออกกำลังกายรวม",
                data: workout.toString() + " นาที",
                width: width - 16,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FoodTrendChart(snapshot: foodSnapshot)),
              ),
              child: WeeklyCard(
                iconColor: Colors.green,
                dataColor: RuleBaseAI.food(food).display.color,
                icon: FontAwesomeIcons.appleAlt,
                title: "ผักผลไม้เฉลี่ยวันละ",
                data: food.toStringAsFixed(1) + " ส่วน",
                width: width - 16,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HealthTrendChart(snapshot: healthSnapshot)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  WeeklyCard(
                    iconColor: Colors.teal,
                    dataColor: RuleBaseAI.bmi(bmi).display.color,
                    icon: FontAwesomeIcons.weight,
                    title: "BMI",
                    data: bmi.toStringAsFixed(1),
                    width: width / 2 - 16,
                  ),
                  WeeklyCard(
                    iconColor: Colors.pink,
                    dataColor: RuleBaseAI.bloodPressure(bpupper, bplower)
                        .display
                        .color,
                    icon: Icons.favorite,
                    title: "ความดัน",
                    data: bpupper.toString() + '/' + bplower.toString(),
                    width: width / 2 - 16,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HealthTrendChart(snapshot: healthSnapshot)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  WeeklyCard(
                    iconColor: Colors.grey,
                    dataColor:
                        RuleBaseAI.cholesterol(cholesterol).display.color,
                    icon: Icons.fastfood,
                    title: "ไขมันรวม",
                    data: cholesterol.toString(),
                    width: width / 2 - 16,
                  ),
                  WeeklyCard(
                    iconColor: Colors.purple,
                    dataColor: RuleBaseAI.ldl(ldl).display.color,
                    icon: FontAwesomeIcons.tint,
                    title: "LDL",
                    data: ldl.toString(),
                    width: width / 2 - 16,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        HealthTrendChart(snapshot: healthSnapshot)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  WeeklyCard(
                    iconColor: Colors.orangeAccent,
                    dataColor: RuleBaseAI.glucose(glucose).display.color,
                    icon: FontAwesomeIcons.cookie,
                    title: "น้ำตาล",
                    data: glucose.toString(),
                    width: width / 2 - 16,
                  ),
                  WeeklyCard(
                    iconColor: Colors.yellow.shade600,
                    dataColor: RuleBaseAI.hba1c(hba1c).display.color,
                    icon: FontAwesomeIcons.stroopwafel,
                    title: "น้ำตาลสะสม",
                    data: hba1c.toStringAsFixed(1) + '%',
                    width: width / 2 - 16,
                  ),
                ],
              ),
            ),
            !smoke
                ? SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.smoking,
                          color: Colors.red,
                          size: 16,
                        ),
                        SizedBox(width: 12),
                        Text('สูบบุหรี่',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey.shade700))
                      ],
                    ),
                  ),
            SizedBox(height: 10)
          ],
        ),
      ),
      // child: BarChartSample1(),
    );
  }
}
