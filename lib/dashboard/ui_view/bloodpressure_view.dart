import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:wellness/models/healthdata.dart';
import 'package:wellness/models/rulebase_ai.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/widgets/webview.dart';

class BloodPressureView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;

  const BloodPressureView({Key key, this.animationController, this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String uid = ScopedModel.of<StateModel>(context).uid;
    int bpupper = 0;
    int bplower = 0;
    int hr = 0;
    String recordDate = 'ไม่มีข้อมูล';
    String kioskDocumentId;

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
              (v) =>
                  v.data()['pressureUpper'] != null &&
                  v.data()['pressureLower'] != null,
              orElse: () => null);

          if (snapshotData != null) {
            HealthMonitor bloodData = HealthMonitor.fromSnapshot(snapshotData);
            bpupper = bloodData.pressureUpper ?? 0;
            bplower = bloodData.pressureLower ?? 0;
            recordDate = DateFormat.yMMMd().format(bloodData.date);
            kioskDocumentId = snapshotData.data()['kioskDocumentId'];
            date1 = bloodData.date;
          }

          DocumentSnapshot snapshotData1 = snapshot.data.docs
              .lastWhere((v) => v.data()['hr'] != null, orElse: () => null);

          if (snapshotData != null) {
            HealthMonitor bloodData = HealthMonitor.fromSnapshot(snapshotData1);
            hr = bloodData.hr ?? 0;
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
                                FontAwesomeIcons.heartbeat,
                                color: Colors.pink.withOpacity(0.9),
                                size: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 4.0),
                                child: Text(
                                  'ความดันโลหิต',
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
                              kioskDocumentId != null
                                  ? InkWell(
                                      child: Icon(FontAwesomeIcons.kickstarter,
                                          size: 20,
                                          color: Colors.cyan.shade300),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => CustomWebView(
                                                    url:
                                                        'http://bsp-kiosk.ddns.net/?id=' +
                                                            kioskDocumentId)));
                                      },
                                    )
                                  : SizedBox(width: 0),
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
                              top: 16, left: 12, right: 24, bottom: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, bottom: 3),
                                    child: Text(
                                      bpupper.toString() +
                                          '/' +
                                          bplower.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 30,
                                        color: RuleBaseAI.bloodPressure(
                                                bpupper, bplower)
                                            .display
                                            .color,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2, bottom: 8),
                                    child: Text(
                                      'mmHg',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                        color: AppTheme.kTextLightColor,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 4, bottom: 3),
                                    child: Text(
                                      hr.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 30,
                                        color: RuleBaseAI.bloodPressure(
                                                bpupper, bplower)
                                            .display
                                            .color,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2, bottom: 8),
                                    child: Text(
                                      'bpm',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                        color: AppTheme.kTextLightColor,
                                      ),
                                    ),
                                  ),

                                  // Padding(
                                  //   padding: const EdgeInsets.only(
                                  //       left: 0, bottom: 8),
                                  //   child: Text(
                                  //     RuleBaseAI.bloodPressure(bpupper, bplower)
                                  //         .display
                                  //         .desc,
                                  //     textAlign: TextAlign.end,
                                  //     style: TextStyle(
                                  //       fontFamily: AppTheme.fontName,
                                  //       fontWeight: FontWeight.w500,
                                  //       fontSize: 16,
                                  //       letterSpacing: -0.2,
                                  //       color: RuleBaseAI.bloodPressure(
                                  //               bpupper, bplower)
                                  //           .display
                                  //           .color,
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
