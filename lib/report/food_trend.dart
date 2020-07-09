import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/fooddata.dart';
import 'package:wellness/widgets/bar_chart.dart';
import 'package:wellness/widgets/first_load.dart';
import 'package:wellness/widgets/social_date.dart';
import 'package:intl/intl.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class FoodTrendChart extends StatefulWidget {
  const FoodTrendChart({Key key, this.snapshot}) : super(key: key);

  final QuerySnapshot snapshot;
  @override
  _FoodTrendChartState createState() => _FoodTrendChartState();
}

class _FoodTrendChartState extends State<FoodTrendChart> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollViewController;

  List<DocumentSnapshot> snapshotData;
  List<FoodMonitor> foodData;
  File tempImage;

  DateTime today;

  int chartDays = 5;
  final Map<int, Widget> chartPeriod = const <int, Widget>{
    5: Text('สัปดาห์'),
    30: Text('เดือน'),
    365: Text('ปี'),
    99999: Text('ทั้งหมด'),
  };

  List<charts.Series<FoodMonitor, DateTime>> caleriesData() {
    List<FoodMonitor> tempData = foodData
        .map((o) => FoodMonitor(
            date: o.date,
            dateString: o.dateString,
            totalServing: int.parse(o.serving)))
        .toList()
          ..removeWhere((v) => today.difference(v.date).inDays > chartDays);

    if (tempData.isNotEmpty) {
      tempData = groupBy(tempData, (obj) => obj.dateString)
          .map((k, v) => MapEntry(k, v.reduce((a, b) {
                a.totalServing = a.totalServing + b.totalServing;
                return a;
              })))
          .values
          .toList();

      return [
        new charts.Series<FoodMonitor, DateTime>(
          id: 'Serving',
          colorFn: (_, __) => charts.MaterialPalette.cyan.shadeDefault,
          domainFn: (FoodMonitor food, _) =>
              DateTime(food.date.year, food.date.month, food.date.day),
          measureFn: (FoodMonitor food, _) => food.totalServing,
          data: tempData,
        )
      ];
    }
    return [];
  }

  List<charts.Series<FoodMonitor, DateTime>> eatHoursData() {
    List<FoodMonitor> tempData = foodData
        .map((o) => FoodMonitor(
              date: o.date,
              dateString: o.dateString,
            ))
        .toList()
          ..removeWhere((v) => today.difference(v.date).inDays > chartDays);

    if (tempData.isNotEmpty) {
      tempData = groupBy(tempData, (obj) => obj.dateString)
          .map((k, v) => MapEntry(k, v.reduce((a, b) {
                a.eatHours = getEatHours(a.date, b.date);
                return a;
              })))
          .values
          .toList();
      return [
        new charts.Series<FoodMonitor, DateTime>(
          id: 'ชั่วโมง',
          colorFn: (_, __) => charts.MaterialPalette.lime.shadeDefault,
          domainFn: (FoodMonitor food, _) =>
              DateTime(food.date.year, food.date.month, food.date.day),
          measureFn: (FoodMonitor food, _) => food.eatHours,
          data: tempData,
        )
      ];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    initData();
  }

  initData() {
    snapshotData = widget.snapshot.documents
      ..sort(
          (a, b) => b.data['date'].toDate().compareTo(a.data['date'].toDate()));

    foodData =
        snapshotData.map((data) => FoodMonitor.fromSnapshot(data)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        body: NestedScrollView(
          controller: _scrollViewController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text("ผักผลไม้"),
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.appBarColor1,
                        AppTheme.appBarColor2,
                      ],
                    ),
                  ),
                ),
                bottom: TabBar(
                  tabs: <Tab>[
                    Tab(
                      key: Key('FoodList'),
                      text: "ผักผลไม้",
                      // icon: Icon(Icons.add),
                    ),
                    Tab(
                      key: Key('Chart'),
                      text: "กราฟ",
                      // icon: Icon(Icons.add),
                    ),
                  ],
                ),
                // actions: _buildMenuActions(context),
              ),
            ];
          },
          body: buildBody(),
        ),
      ),
    );
  }

  Widget buildBody() {
    return TabBarView(
      children: <Widget>[
        snapshotData.isEmpty
            ? FirstLoad(title: "ไม่มีข้อมูล")
            : _buildImagesList(context, foodData),

        snapshotData.isEmpty
            ? FirstLoad(title: "ไม่มีข้อมูล")
            : _buildHistoryChart(),
        // _buildHistory(),
      ],
    );
  }

  Widget _buildImagesList(BuildContext context, List<FoodMonitor> foodData) {
    var foodDataMap = groupBy(foodData, (obj) => obj.dateString);

    List<FoodMonitor> totalServing = foodDataMap
        .map((k, v) => MapEntry(k, v.reduce((a, b) {
              a.totalServing = a.totalServing + b.totalServing;
              return a;
            })))
        .values
        .toList();

    return ListView.builder(
        padding: const EdgeInsets.only(top: 20.0),
        itemCount: totalServing.length,
        itemBuilder: (BuildContext context, int index) {
          String key = totalServing[index].dateString;
          return _buildImagesTitleItem(
              context, foodDataMap[key].toList(), totalServing[index]);
        });
  }

  Widget _buildImagesTitleItem(
      BuildContext context, List<FoodMonitor> foodList, FoodMonitor total) {
    Widget title = SectionTitle(
      title: socialDate(total.date),
      serving: total.totalServing.toString(),
      hours: getEatHours(foodList.first.date, foodList.last.date).toString(),
    );

    return Column(
      children:
          foodList.map((data) => _buildImagesListItem(context, data)).toList()
            ..insert(0, title),
    );
  }

  Widget _buildImagesListItem(BuildContext context, FoodMonitor content) {
    // DateTime _date = news.data['record_date'];
    return SafeArea(
      top: false,
      bottom: false,
      child: Center(
        child: SizedBox(
          height: 298.0,
          child: Card(
            clipBehavior: Clip.antiAlias,
            margin: EdgeInsets.all(12.0),
            child: InkWell(
              onTap: () {},
              splashColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
              highlightColor: Colors.transparent,
              child: FoodContent(
                food: content,
                tempImage: tempImage,
              ),
            ),
          ),
        ),
      ),
    );
  }

  int getEatHours(DateTime first, DateTime last) {
    if (first == null || last == null) return 0;
    return first.difference(last).inHours;
  }

  Widget _buildHistoryChart() {
    return ListView(children: <Widget>[
      SizedBox(
        height: 40,
        child: CupertinoSegmentedControl<int>(
          children: chartPeriod,
          selectedColor: Colors.blueAccent,
          borderColor: Colors.blueAccent,
          onValueChanged: (int newValue) {
            setState(() {
              chartDays = newValue;
            });
          },
          groupValue: chartDays,
        ),
      ),
      SizedBox(height: 10),
      Container(
        height: 240,
        child: TimeSeriesBar(caleriesData(), animate: true, unit: 'Serving'),
      ),
      SizedBox(height: 30),
      Container(
        height: 240,
        child: TimeSeriesBar(eatHoursData(), animate: true, unit: 'ชั่วโมง'),
      ),
    ]);
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key key,
    this.title: 'ผักผลไม้',
    this.serving,
    this.hours,
  }) : super(key: key);

  final String title;
  final String serving;
  final String hours;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 0.0, 8.0, 6.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(title, style: Theme.of(context).textTheme.headline5),
          ),
        ),
        Text(' $serving ส่วน', style: Theme.of(context).textTheme.subtitle1),
        Expanded(
          child: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 12),
            child: Text('$hours ชั่วโมง',
                style: Theme.of(context).textTheme.subtitle1),
          ),
        )

        // style: TextStyle(color: Colors.green, fontSize: 16))
      ],
    );
  }
}

class FoodContent extends StatelessWidget {
  const FoodContent({Key key, @required this.food, this.tempImage})
      : assert(food != null),
        super(key: key);

  final FoodMonitor food;
  final File tempImage;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle =
        theme.textTheme.headline6.copyWith(color: Colors.white);
    TextStyle subtitleStyle =
        theme.textTheme.subtitle2.copyWith(color: Colors.white);

    final List<Widget> children = <Widget>[
      // Photo and title.
      SizedBox(
        height: 274.0,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: Ink.image(
                image: food.imageUrl != null
                    ? CachedNetworkImageProvider(food.imageUrl)
                    : FileImage(tempImage),
                fit: BoxFit.cover,
                child: Container(),
              ),
            ),
            Positioned(
              bottom: 36.0,
              left: 16.0,
              right: 16.0,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: Text(
                  food.menu,
                  style: titleStyle,
                ),
              ),
            ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    "${food.serving} Serving(s)",
                    style: subtitleStyle,
                  )),
            ),
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomRight,
                child: Text(
                  DateFormat.Hm().format(food.date),
                  style: subtitleStyle,
                ),
              ),
            ),
          ],
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
