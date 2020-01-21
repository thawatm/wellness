import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final String title;
  final String unit;

  SimpleTimeSeriesChart(this.seriesList, {this.animate, this.title, this.unit});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
  factory SimpleTimeSeriesChart.withSampleData() {
    return new SimpleTimeSeriesChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
      title: '',
      unit: '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      defaultRenderer: new charts.LineRendererConfig(),
      behaviors: [
        // new charts.ChartTitle(title,
        //     titleStyleSpec: TextStyleSpec(fontFamily: 'Kanit'),
        //     // subTitle: 'kg',
        //     behaviorPosition: charts.BehaviorPosition.top,
        //     titleOutsideJustification:
        //         charts.OutsideJustification.middleDrawArea,
        //     innerPadding: 18),
        new charts.ChartTitle(unit,
            titleStyleSpec: charts.TextStyleSpec(fontSize: 10),
            behaviorPosition: charts.BehaviorPosition.start,
            titleOutsideJustification:
                charts.OutsideJustification.middleDrawArea),
        // new charts.SeriesLegend(
        //   position: charts.BehaviorPosition.bottom,
        //   horizontalFirst: false,
        //   showMeasures: true,
        // ),
        new charts.SeriesLegend(
          position: charts.BehaviorPosition.bottom,
          horizontalFirst: false,
          cellPadding: new EdgeInsets.only(right: 4.0, bottom: 4.0),
          showMeasures: true,
          measureFormatter: (num value) {
            return "${value ?? '-'}";
          },
        ),
      ],
      customSeriesRenderers: [
        new charts.LineRendererConfig(
            // ID used to link series to this renderer.
            customRendererId: 'customArea',
            includeArea: true,
            includePoints: true,
            stacked: true),
        new charts.LineRendererConfig(
          // ID used to link series to this renderer.
          customRendererId: 'customPoint',
          includePoints: true,
        )
        //
      ],
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData() {
    final data = [
      new TimeSeriesSales(new DateTime(2017, 9, 19), 5),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 25),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 100),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 75),
    ];

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
