import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/dashboard/ui_view/wave_view.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/main.dart';
import 'package:flutter/material.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/models/waterdata.dart';

class WaterView extends StatefulWidget {
  const WaterView({
    Key key,
    this.mainScreenAnimationController,
    this.mainScreenAnimation,
  }) : super(key: key);

  final AnimationController mainScreenAnimationController;
  final Animation<dynamic> mainScreenAnimation;

  @override
  _WaterViewState createState() => _WaterViewState();
}

class _WaterViewState extends State<WaterView> with TickerProviderStateMixin {
  int drink = 0;
  double drinkPercent = 0;
  String lastDrink = 'ท่านยังไม่ได้ดื่มน้ำ';
  String uid;
  List<DocumentSnapshot> snapshotData;

  List<WaterMonitor> todayData;

  int recommend = 2500;

  DateTime today;

  @override
  void initState() {
    uid = ScopedModel.of<StateModel>(context).uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String today = DateFormat.yMd().format(DateTime.now());
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation.value), 0.0),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('wellness_data')
                  .doc(uid)
                  .collection('water')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return SizedBox();
                snapshotData = snapshot.data.docs;

                todayData = snapshotData
                    .map((data) => WaterMonitor.fromSnapshot(data))
                    .where((v) => (DateFormat.yMd().format(v.date) == today))
                    .toList();

                // Gauge display
                if (todayData != null && todayData.isNotEmpty) {
                  drink = todayData.length * 200;
                  drinkPercent = drink > 2100 ? 100 : drink * 100 / 2100;
                  lastDrink = 'ดื่มล่าสุด ' +
                      DateFormat.Hm().format(todayData.last.date);
                }

                return Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topRight: Radius.circular(8.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: AppTheme.grey.withOpacity(0.2),
                            offset: const Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          top: 16, left: 16, right: 16, bottom: 16),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, bottom: 8, top: 0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(
                                            FontAwesomeIcons.glassWhiskey,
                                            color: Colors.blueAccent,
                                            size: 16,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12.0),
                                            child: Text(
                                              'ดื่มน้ำ',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: AppTheme.fontName,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                letterSpacing: -0.1,
                                                color: AppTheme.nearlyBlack,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, bottom: 0, top: 0),
                                          child: Text(
                                            '$drink',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 32,
                                              color: AppTheme.nearlyDarkBlue,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, bottom: 8),
                                          child: Text(
                                            'ml',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              letterSpacing: -0.2,
                                              color: AppTheme.nearlyDarkBlue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 10),
                                          child: Icon(
                                            Icons.access_time,
                                            color:
                                                AppTheme.grey.withOpacity(0.5),
                                            size: 14,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 4.0),
                                          child: Text(
                                            '$lastDrink',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              letterSpacing: 0.0,
                                              color: AppTheme.grey
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(
                                    //       left: 4, top: 2, bottom: 8),
                                    //   child: Text(
                                    //     'จากทั้งหมด 2.4L',
                                    //     textAlign: TextAlign.center,
                                    //     style: TextStyle(
                                    //       fontFamily: AppTheme.fontName,
                                    //       fontWeight: FontWeight.w500,
                                    //       fontSize: 14,
                                    //       letterSpacing: 0.0,
                                    //       color: AppTheme.darkText,
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.only(
                                //       left: 4, right: 4, top: 8, bottom: 4),
                                //   child: Container(
                                //     height: 2,
                                //     decoration: BoxDecoration(
                                //       color: AppTheme.background,
                                //       borderRadius: const BorderRadius.all(
                                //           Radius.circular(4.0)),
                                //     ),
                                //   ),
                                // ),
                                // Padding(
                                //   padding: const EdgeInsets.only(top: 8),
                                //   child: Column(
                                //     mainAxisAlignment: MainAxisAlignment.center,
                                //     crossAxisAlignment: CrossAxisAlignment.end,
                                //     children: <Widget>[
                                //       Row(
                                //         mainAxisAlignment:
                                //             MainAxisAlignment.start,
                                //         crossAxisAlignment:
                                //             CrossAxisAlignment.center,
                                //         children: <Widget>[
                                //           Padding(
                                //             padding:
                                //                 const EdgeInsets.only(left: 4),
                                //             child: Icon(
                                //               Icons.access_time,
                                //               color: AppTheme.grey
                                //                   .withOpacity(0.5),
                                //               size: 16,
                                //             ),
                                //           ),
                                //           Padding(
                                //             padding: const EdgeInsets.only(
                                //                 left: 4.0),
                                //             child: Text(
                                //               '$lastDrink',
                                //               textAlign: TextAlign.center,
                                //               style: TextStyle(
                                //                 fontFamily: AppTheme.fontName,
                                //                 fontWeight: FontWeight.w500,
                                //                 fontSize: 14,
                                //                 letterSpacing: 0.0,
                                //                 color: AppTheme.grey
                                //                     .withOpacity(0.5),
                                //               ),
                                //             ),
                                //           ),
                                //         ],
                                //       ),
                                //       // Padding(
                                //       //   padding: const EdgeInsets.only(top: 4),
                                //       //   child: Row(
                                //       //     mainAxisAlignment:
                                //       //         MainAxisAlignment.start,
                                //       //     crossAxisAlignment:
                                //       //         CrossAxisAlignment.center,
                                //       //     children: <Widget>[
                                //       //       SizedBox(
                                //       //         width: 24,
                                //       //         height: 24,
                                //       //         child: Image.asset(
                                //       //             'assets/fitness_app/bell.png'),
                                //       //       ),
                                //       //       Flexible(
                                //       //         child: Text(
                                //       //           'ควรดื่มน้ำอย่างน้อยวันละ 8 แก้ว',
                                //       //           textAlign: TextAlign.start,
                                //       //           style: TextStyle(
                                //       //             fontFamily: AppTheme.fontName,
                                //       //             fontWeight: FontWeight.w500,
                                //       //             fontSize: 12,
                                //       //             letterSpacing: 0.0,
                                //       //             color: HexColor('#F65283'),
                                //       //           ),
                                //       //         ),
                                //       //       ),
                                //       //     ],
                                //       //   ),
                                //       // ),
                                //     ],
                                //   ),
                                // )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 24, top: 0),
                            child: InkWell(
                              onTap: _saveData,
                              child: Container(
                                width: 55,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: HexColor('#E8EDFE'),
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(80.0),
                                      bottomLeft: Radius.circular(80.0),
                                      bottomRight: Radius.circular(80.0),
                                      topRight: Radius.circular(80.0)),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: AppTheme.grey.withOpacity(0.4),
                                        offset: const Offset(2, 2),
                                        blurRadius: 4),
                                  ],
                                ),
                                child: WaveView(
                                  percentageValue: drinkPercent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _saveData() {
    try {
      Map<String, dynamic> monitorData = {
        'date': DateTime.now(),
      };
      int timestamp = monitorData['date'].millisecondsSinceEpoch;
      monitorData['drinkTime'] = DateFormat.Hm().format(monitorData['date']);
      monitorData['waterVolume'] = 200;
      FirebaseFirestore.instance
          .collection('wellness_data')
          .doc(uid)
          .collection('water')
          .doc(timestamp.toString())
          .set(monitorData)
          .then((value) => monitorData['date'] =
              monitorData['date'].add(Duration(seconds: 1)));
    } catch (e) {
      print(e);
    }
  }
}
