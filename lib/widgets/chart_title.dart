import 'package:flutter/material.dart';

class ChartPercentTitle extends StatelessWidget {
  const ChartPercentTitle({
    Key key,
    @required this.title,
    this.first,
    this.last,
    this.color,
  })  : assert(title != null),
        super(key: key);

  final String title;
  final dynamic first;
  final dynamic last;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Color percentColor;
    double change = percentChange(first, last);
    String sign = '';
    if (change > 0) {
      percentColor = Colors.red;
      sign = '+';
    } else {
      percentColor = Colors.green;
    }

    return ListTile(
      title: Text(title, style: TextStyle(color: color)),
      trailing: Text(
        sign + change.toStringAsFixed(2) + ' %',
        style: TextStyle(color: percentColor, fontSize: 16),
      ),
    );
  }

  double percentChange(dynamic first, dynamic last) {
    if (first == null || last == null) return 0;
    return (first - last) * 100 / last;
  }
}
