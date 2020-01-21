import 'package:flutter/material.dart';

class FirstLoad extends StatelessWidget {
  const FirstLoad({this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          SizedBox(height: 150),
          Icon(
            Icons.touch_app,
            size: 90,
            color: Colors.blue,
          ),
          SizedBox(height: 30),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
