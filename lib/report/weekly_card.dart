import 'package:flutter/material.dart';

class WeeklyCard extends StatelessWidget {
  final Color iconColor;
  final Color dataColor;
  final IconData icon;
  final String title;
  final String data;
  final TextStyle whiteText = TextStyle(color: Colors.grey.shade700);
  final double width;

  WeeklyCard(
      {this.dataColor,
      this.iconColor,
      this.icon,
      this.title,
      this.data,
      this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(8.0),
      // height: 100.0,
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(4.0),
      //   color: color,
      // ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            color: iconColor,
          ),
          SizedBox(width: 5),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Spacer(),
          Text(
            data,
            style: TextStyle(color: dataColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
