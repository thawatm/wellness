import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/fitness_app/fitness_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:wellness/models/healthdata.dart';
import 'package:wellness/models/state_model.dart';
import 'package:wellness/widgets/counter.dart';

class BloodTestView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;

  const BloodTestView({Key key, this.animationController, this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseUser currentUser = ScopedModel.of<StateModel>(context).currentUser;
    int cholesterol = 0;
    int ldl = 0;
    int glucose = 0;
    double hba1c = 0;
    String recordDate = '';

    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('monitor')
          .document(currentUser.uid)
          .collection('bloodtests')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        DocumentSnapshot snapshotData = snapshot.data.documents
            .lastWhere((v) => v.data['cholesterol'] != null);

        if (snapshotData != null) {
          HealthMonitor bloodData = HealthMonitor.fromSnapshot(snapshotData);
          cholesterol = bloodData.cholesterol ?? 0;
          ldl = bloodData.ldl ?? 0;
          glucose = bloodData.glucose ?? 0;
          hba1c = bloodData.hba1c ?? 0;
          recordDate = DateFormat.yMMMd().format(bloodData.date);
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
                      color: FitnessAppTheme.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topRight: Radius.circular(8.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: FitnessAppTheme.grey.withOpacity(0.2),
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
                                    color: FitnessAppTheme.kRecovercolor,
                                    number: cholesterol,
                                    title: "Cholesterol",
                                  ),
                                  Counter(
                                    color: FitnessAppTheme.kInfectedColor,
                                    number: ldl,
                                    title: "LDL",
                                  ),
                                  Counter(
                                    color: FitnessAppTheme.kDeathColor,
                                    number: glucose,
                                    title: "Glucose",
                                  ),
                                  Counter(
                                    color: FitnessAppTheme.kRecovercolor,
                                    number: hba1c,
                                    title: "HbA1c",
                                  ),
                                ])),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24, right: 24, top: 8, bottom: 8),
                          child: Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: FitnessAppTheme.background,
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
                                color: FitnessAppTheme.grey.withOpacity(0.5),
                                size: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Text(
                                  recordDate,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: FitnessAppTheme.fontName,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    letterSpacing: 0.0,
                                    color:
                                        FitnessAppTheme.grey.withOpacity(0.5),
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
