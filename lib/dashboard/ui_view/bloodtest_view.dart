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

class BloodTestView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;

  const BloodTestView({Key key, this.animationController, this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String uid = ScopedModel.of<StateModel>(context).uid;
    int cholesterol = 0;
    int ldl = 0;
    int glucose = 0;
    double hba1c = 0;
    String recordDate = 'ไม่มีข้อมูล';

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('wellness_data')
          .doc(uid)
          .collection('healthdata')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        try {
          DateTime date1;
          DateTime date2;

          DocumentSnapshot snapshotData = snapshot.data.docs.lastWhere(
              (v) => v.data()['cholesterol'] != null,
              orElse: () => null);

          if (snapshotData != null) {
            HealthMonitor bloodData = HealthMonitor.fromSnapshot(snapshotData);
            cholesterol = bloodData.cholesterol ?? 0;
            ldl = bloodData.ldl ?? 0;
            recordDate = DateFormat.yMMMd().format(bloodData.date);
            date1 = bloodData.date;
          }

          DocumentSnapshot snapshotData1 = snapshot.data.docs.lastWhere(
              (v) => v.data()['glucose'] != null,
              orElse: () => null);

          if (snapshotData1 != null) {
            HealthMonitor bloodData = HealthMonitor.fromSnapshot(snapshotData1);
            glucose = bloodData.glucose ?? 0;
            hba1c = bloodData.hba1c ?? 0;
            date2 = bloodData.date;
            if (date1 is DateTime && date2.isAfter(date1)) {
              recordDate = DateFormat.yMMMd().format(bloodData.date);
            }
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
                      left: 16, right: 16, top: 16, bottom: 0),
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
                              left: 16, right: 24, top: 16, bottom: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                FontAwesomeIcons.tint,
                                color: Colors.pink.withOpacity(0.9),
                                size: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  'ค่าผลเลือด',
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
                                padding: const EdgeInsets.only(left: 4.0),
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
                                left: 16, right: 24, top: 16, bottom: 16),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Counter(
                                    color: RuleBaseAI.cholesterol(cholesterol)
                                        .display
                                        .color,
                                    number: cholesterol.toString(),
                                    title: "Cholesterol",
                                  ),
                                  Counter(
                                    color: RuleBaseAI.ldl(ldl).display.color,
                                    number: ldl.toString(),
                                    title: "LDL",
                                  ),
                                  Counter(
                                    color: RuleBaseAI.glucose(glucose)
                                        .display
                                        .color,
                                    number: glucose.toString(),
                                    title: "Glucose",
                                  ),
                                  Counter(
                                    color:
                                        RuleBaseAI.hba1c(hba1c).display.color,
                                    number: hba1c.toString(),
                                    title: "HbA1c",
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
