import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:wellness/models/healthdata.dart';
import 'package:wellness/models/rulebase_ai.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/widgets/counter.dart';

class FatView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;

  const FatView({Key key, this.animationController, this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String uid = ScopedModel.of<StateModel>(context).uid;
    double bodyFat = 0;
    int bodyAge = 0;
    double visceralFat = 0;
    String recordDate = 'ไม่มีข้อมูล';

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('wellness_data')
          .document(uid)
          .collection('healthdata')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        try {
          DocumentSnapshot snapshotData = snapshot.data.documents
              .lastWhere((v) => v.data['bodyFat'] != null);

          if (snapshotData != null) {
            HealthMonitor fatData = HealthMonitor.fromSnapshot(snapshotData);
            bodyAge = fatData.bodyAge ?? 0;
            bodyFat = fatData.bodyFat ?? 0;
            visceralFat = fatData.visceralFat ?? 0;
            recordDate = DateFormat.yMMMd().format(fatData.date);
          }
        } catch (e) {
          print(e);
        }
        return AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget child) {
            return FadeTransition(
              opacity: animation,
              child: new Transform(
                transform: new Matrix4.translationValues(
                    0.0, 30 * (1.0 - animation.value), 0.0),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 16),
                  child: Container(
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
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 24, top: 24, bottom: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.cookieBite,
                                color: Colors.purple.withOpacity(0.9),
                                size: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'องค์ประกอบร่างกาย',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    letterSpacing: 0.0,
                                    color: AppTheme.nearlyBlack,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Icon(
                                Icons.access_time,
                                color: AppTheme.grey.withOpacity(0.5),
                                size: 14,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: Text(
                                  recordDate,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    letterSpacing: 0.0,
                                    color: AppTheme.grey.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 24, right: 24, top: 16, bottom: 16),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Counter(
                                    color:
                                        RuleBaseAI.fat(bodyFat).display.color,
                                    number: bodyFat.toString(),
                                    title: "Body Fat",
                                  ),
                                  Counter(
                                    color: RuleBaseAI.fat(visceralFat)
                                        .display
                                        .color,
                                    number: visceralFat.toString(),
                                    title: "Visceral Fat",
                                  ),
                                  Counter(
                                    color:
                                        RuleBaseAI.fat(bodyAge).display.color,
                                    number: bodyAge.toString(),
                                    title: "Body Age",
                                  ),
                                ])),
                      ],
                    ),
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
