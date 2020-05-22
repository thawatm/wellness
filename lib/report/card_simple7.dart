import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/report/weekly_card.dart';

class Simple7Card extends StatelessWidget {
  final String workout;
  final String food;
  final String bmi;
  final String pressure;
  final String cholesterol;
  final String ldl;
  final String glucose;
  final String hba1c;

  Simple7Card(
      {Key key,
      @required this.workout,
      @required this.food,
      @required this.bmi,
      @required this.pressure,
      @required this.cholesterol,
      @required this.ldl,
      @required this.glucose,
      @required this.hba1c})
      : super(key: key);

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
            WeeklyCard(
              iconColor: Colors.blueGrey,
              dataColor: Colors.green,
              icon: Icons.fitness_center,
              title: "ออกกำลังกายรวม",
              data: workout + " นาที",
              width: width - 16,
            ),
            WeeklyCard(
              iconColor: Colors.green,
              dataColor: Colors.green,
              icon: Icons.album,
              title: "ผักผลไม้เฉลี่ยวันละ",
              data: food + " ส่วน",
              width: width - 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                WeeklyCard(
                  iconColor: Colors.teal,
                  dataColor: Colors.green,
                  icon: Icons.person,
                  title: "BMI",
                  data: bmi,
                  width: width / 2 - 16,
                ),
                WeeklyCard(
                  iconColor: Colors.pink,
                  dataColor: Colors.green,
                  icon: Icons.favorite,
                  title: "ความดัน",
                  data: pressure,
                  width: width / 2 - 16,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                WeeklyCard(
                  iconColor: Colors.blue,
                  dataColor: Colors.green,
                  icon: Icons.fastfood,
                  title: "ไขมันรวม",
                  data: cholesterol,
                  width: width / 2 - 16,
                ),
                WeeklyCard(
                  iconColor: Colors.purple,
                  dataColor: Colors.green,
                  icon: Icons.menu,
                  title: "LDL",
                  data: ldl,
                  width: width / 2 - 16,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                WeeklyCard(
                  iconColor: Colors.orangeAccent,
                  dataColor: Colors.green,
                  icon: Icons.subtitles,
                  title: "น้ำตาล",
                  data: glucose,
                  width: width / 2 - 16,
                ),
                WeeklyCard(
                  iconColor: Colors.yellow.shade600,
                  dataColor: Colors.green,
                  icon: Icons.list,
                  title: "น้ำตาลสะสม",
                  data: hba1c,
                  width: width / 2 - 16,
                ),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      // child: BarChartSample1(),
    );
  }
}
