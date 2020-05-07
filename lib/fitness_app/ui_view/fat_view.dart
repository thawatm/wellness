import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/fitness_app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:wellness/models/healthdata.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/widgets/counter.dart';

class FatView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;

  const FatView({Key key, this.animationController, this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseUser currentUser = ScopedModel.of<StateModel>(context).currentUser;
    double bodyFat = 0;
    int bodyAge = 0;
    double visceralFat = 0;
    String recordDate = 'ไม่มีข้อมูล';

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('monitor')
          .document(currentUser.uid)
          .collection('weightfat')
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
                      left: 24, right: 24, top: 16, bottom: 18),
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
                                left: 24, right: 24, top: 16, bottom: 8),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Counter(
                                    color: AppTheme.nearlyDarkBlue,
                                    number: bodyFat,
                                    title: "Body Fat",
                                  ),
                                  Counter(
                                    color: AppTheme.nearlyDarkBlue,
                                    number: visceralFat,
                                    title: "Visceral Fat",
                                  ),
                                  Counter(
                                    color: AppTheme.nearlyDarkBlue,
                                    number: bodyAge,
                                    title: "Body Age",
                                  ),
                                ])),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, top: 8, bottom: 8),
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4.0)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, top: 0, bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                Icons.access_time,
                                color: AppTheme.grey.withOpacity(0.5),
                                size: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  recordDate,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    letterSpacing: 0.0,
                                    color: AppTheme.grey.withOpacity(0.5),
                                  ),
                                ),
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
