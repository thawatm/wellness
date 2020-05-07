import 'package:flutter/material.dart';
import 'package:wellness/fitness_app/app_theme.dart';

class Counter extends StatelessWidget {
  final num number;
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
    String display = '-';
    if (number > 0) display = '$number';
    return Column(
      children: <Widget>[
        // Container(
        //   padding: EdgeInsets.all(6),
        //   height: 25,
        //   width: 25,
        //   decoration: BoxDecoration(
        //     shape: BoxShape.circle,
        //     color: color.withOpacity(.26),
        //   ),
        //   child: Container(
        //     decoration: BoxDecoration(
        //       shape: BoxShape.circle,
        //       color: Colors.transparent,
        //       border: Border.all(
        //         color: color,
        //         width: 2,
        //       ),
        //     ),
        //   ),
        // ),
        // SizedBox(height: 10),
        Text(
          display,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        Text(title, style: AppTheme.kSubTextStyle),
      ],
    );
  }
}
