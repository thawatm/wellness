import 'package:flutter/material.dart';
import 'package:wellness/dashboard/app_theme.dart';

class Counter extends StatelessWidget {
  final String number;
  final Color color;
  final String title;
  const Counter({
    Key key,
    this.number,
    this.color,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          number,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(title, style: AppTheme.kSubTextStyle),
      ],
    );
  }
}
