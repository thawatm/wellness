import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/dashboard/models/meals_list_data.dart';
import 'package:wellness/main.dart';
import 'package:flutter/material.dart';
import 'package:wellness/models/fooddata.dart';
import 'package:wellness/models/state_model.dart';

class MealsListView extends StatefulWidget {
  const MealsListView(
      {Key key, this.mainScreenAnimationController, this.mainScreenAnimation})
      : super(key: key);

  final AnimationController mainScreenAnimationController;
  final Animation<dynamic> mainScreenAnimation;

  @override
  _MealsListViewState createState() => _MealsListViewState();
}

class _MealsListViewState extends State<MealsListView>
    with TickerProviderStateMixin {
  AnimationController animationController;
  List<MealsListData> mealsListData;

  String uid;
  List<FoodMonitor> todayData;
  String today = DateFormat.yMd().format(DateTime.now());
  int totalServing = 0;

  @override
  void initState() {
    uid = ScopedModel.of<StateModel>(context).uid;
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('wellness_data')
          .doc(uid)
          .collection('food')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();

        List<DocumentSnapshot> snapshotData = snapshot.data.docs;

        snapshotData = snapshot.data.docs
          ..sort((a, b) =>
              b.data()['date'].toDate().compareTo(a.data()['date'].toDate()));

        todayData = snapshotData
            .map((data) => FoodMonitor.fromSnapshot(data))
            .where((v) => (DateFormat.yMd().format(v.date) == today))
            .toList();

        totalServing = todayData.fold(0, (a, b) => a + int.tryParse(b.serving));

        mealsListData = todayData
            .map((f) => MealsListData(
                  imagePath: f.imageUrl,
                  titleTxt: f.menu,
                  serving: f.serving,
                  meals: <String>['', f.dateString],
                  startColor: '#6F72CA',
                  endColor: '#1E1466',
                ))
            .toList();

        mealsListData.insert(
            0,
            MealsListData(
              isAddIcon: true,
              startColor: '#738AE6',
              endColor: '#5C5EDD',
            ));

        return AnimatedBuilder(
          animation: widget.mainScreenAnimationController,
          builder: (BuildContext context, Widget child) {
            return FadeTransition(
              opacity: widget.mainScreenAnimation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - widget.mainScreenAnimation.value), 0.0),
                child: Container(
                  height: 216,
                  width: double.infinity,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 0, right: 16, left: 16),
                    itemCount: mealsListData.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int index) {
                      final int count =
                          mealsListData.length > 10 ? 10 : mealsListData.length;

                      final Animation<double> animation =
                          Tween<double>(begin: 0.0, end: 1.0).animate(
                              CurvedAnimation(
                                  parent: animationController,
                                  curve: Interval((1 / count) * index, 1.0,
                                      curve: Curves.fastOutSlowIn)));
                      animationController.forward();
                      return MealsView(
                          mealsListData: mealsListData[index],
                          animation: animation,
                          animationController: animationController,
                          totalServing: totalServing,
                          uid: uid);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MealsView extends StatelessWidget {
  const MealsView(
      {Key key,
      this.mealsListData,
      this.animationController,
      this.animation,
      this.totalServing,
      this.uid})
      : super(key: key);

  final MealsListData mealsListData;
  final AnimationController animationController;
  final Animation<dynamic> animation;
  final String uid;
  final int totalServing;

  @override
  Widget build(BuildContext context) {
    AssetImage blankImage = AssetImage('assets/images/blank.png');
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation.value), 0.0, 0.0),
            child: mealsListData.isAddIcon
                ? mealAddView(totalServing)
                : SizedBox(
                    width: 130,
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 32, left: 8, right: 8, bottom: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  // alignment: Alignment(0, 0),
                                  fit: BoxFit.cover,
                                  //  add image URL
                                  image: mealsListData.imagePath == null
                                      ? blankImage
                                      : (NetworkImage(
                                              mealsListData.imagePath)) ??
                                          blankImage),
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: HexColor(mealsListData.endColor)
                                        .withOpacity(0.6),
                                    offset: const Offset(1.1, 4.0),
                                    blurRadius: 8.0),
                              ],
                              gradient: LinearGradient(
                                colors: <HexColor>[
                                  HexColor(mealsListData.startColor),
                                  HexColor(mealsListData.endColor),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(8.0),
                                bottomLeft: Radius.circular(8.0),
                                topLeft: Radius.circular(8.0),
                                topRight: Radius.circular(8.0),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 54, left: 16, right: 16, bottom: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    mealsListData.titleTxt,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.2,
                                      color: AppTheme.white,
                                    ),
                                  ),
                                  mealsListData.serving != ''
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Text(
                                              mealsListData.serving,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: AppTheme.fontName,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 24,
                                                letterSpacing: 0.2,
                                                color: AppTheme.white,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4, bottom: 3),
                                              child: Text(
                                                'serving',
                                                style: TextStyle(
                                                  fontFamily: AppTheme.fontName,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 10,
                                                  letterSpacing: 0.2,
                                                  color: AppTheme.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                            color: AppTheme.nearlyWhite,
                                            shape: BoxShape.circle,
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: AppTheme.nearlyBlack
                                                      .withOpacity(0.4),
                                                  offset: Offset(8.0, 8.0),
                                                  blurRadius: 8.0),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Icon(
                                              Icons.add,
                                              color: HexColor(
                                                  mealsListData.endColor),
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Positioned(
                        //   top: 0,
                        //   left: 0,
                        //   child: Container(
                        //     width: 150,
                        //     height: 100,
                        //     decoration: BoxDecoration(
                        //       color: AppTheme.nearlyWhite.withOpacity(0.2),
                        //       shape: BoxShape.circle,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget mealAddView(int totalServing) {
    AssetImage fruitImage = AssetImage('assets/images/fruit.png');
    AssetImage vegetableImage = AssetImage('assets/images/vegetable.png');
    String total = 'เพิ่มผักผลไม้';
    if (totalServing > 0) total = " ผลรวม  $totalServing ";
    return SizedBox(
      width: 130,
      child: Stack(
        children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.only(top: 32, left: 8, right: 8, bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: HexColor(mealsListData.endColor).withOpacity(0.6),
                      offset: const Offset(1.1, 4.0),
                      blurRadius: 8.0),
                ],
                gradient: LinearGradient(
                  colors: <HexColor>[
                    HexColor(mealsListData.startColor),
                    HexColor(mealsListData.endColor),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 0, left: 12, right: 12, bottom: 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      child: Stack(children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: AppTheme.nearlyBlack.withOpacity(0.4),
                                  offset: Offset(8.0, 8.0),
                                  blurRadius: 8.0),
                            ],
                          ),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  image: vegetableImage, fit: BoxFit.fill),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.nearlyWhite,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color:
                                        AppTheme.nearlyBlack.withOpacity(0.4),
                                    offset: Offset(4.0, 4.0),
                                    blurRadius: 4.0),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0.5),
                              child: Icon(
                                Icons.add,
                                color: HexColor(mealsListData.endColor),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      onTap: () {
                        _saveData('ผัก');
                      },
                    ),
                    SizedBox(height: 12),
                    InkWell(
                      child: Stack(children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                  color: AppTheme.nearlyBlack.withOpacity(0.4),
                                  offset: Offset(8.0, 8.0),
                                  blurRadius: 8.0),
                            ],
                          ),
                          child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                  image: DecorationImage(image: fruitImage))),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.nearlyWhite,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color:
                                        AppTheme.nearlyBlack.withOpacity(0.4),
                                    offset: Offset(4.0, 4.0),
                                    blurRadius: 4.0),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(0.5),
                              child: Icon(
                                Icons.add,
                                color: HexColor(mealsListData.endColor),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ]),
                      onTap: () {
                        _saveData('ผลไม้');
                      },
                    ),
                    SizedBox(height: 8),
                    Text(
                      total,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        letterSpacing: 0.2,
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: 0,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: AppTheme.nearlyWhite.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveData(String menu) {
    DateTime now = DateTime.now();
    Map<String, dynamic> monitorData = {
      'date': now,
      'menu': '',
      'serving': '1'
    };
    int timestamp = now.millisecondsSinceEpoch;
    String url =
        'https://firebasestorage.googleapis.com/v0/b/bsp-kiosk.appspot.com/o/default_images%2Ffruit.jpg?alt=media';

    if (menu == 'ผัก')
      url =
          'https://firebasestorage.googleapis.com/v0/b/bsp-kiosk.appspot.com/o/default_images%2Fvegetable.jpg?alt=media';

    monitorData['imageUrl'] = url;

    monitorData['menu'] = menu;

    FirebaseFirestore.instance
        .collection('wellness_data')
        .doc(uid)
        .collection('food')
        .doc(timestamp.toString())
        .set(monitorData);
  }
}
