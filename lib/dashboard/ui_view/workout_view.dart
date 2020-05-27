import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/main.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:wellness/models/state_model.dart';
import 'package:wellness/models/workoutdata.dart';

class WorkoutView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;

  const WorkoutView({Key key, this.animationController, this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String uid = ScopedModel.of<StateModel>(context).uid;
    int steps = 0;
    int run = 0;
    double runPercent = 0;
    int cycling = 0;
    double cyclingPercent = 0;
    int etc = 0;
    double etcPercent = 0;
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('wellness_data')
          .document(uid)
          .collection('workout')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return SizedBox();
        List<DocumentSnapshot> snapshotData;

        snapshotData = snapshot.data.documents;

        String todayString = DateFormat.yMd().format(DateTime.now());
        List<WorkoutMonitor> todayData = snapshotData
            .map((data) => WorkoutMonitor.fromSnapshot(data))
            .where((v) => (DateFormat.yMd().format(v.date) == todayString))
            .toList();

        // Gauge display
        if (todayData.isNotEmpty) {
          if (todayData.where((t) => t.steps != null).length > 0)
            steps = todayData
                .where((t) => t.steps != null)
                .fold(0, (a, b) => a + b.steps);

          if (todayData.where((t) => t.run != null).length > 0)
            run = todayData
                .where((t) => t.run != null)
                .fold(0, (a, b) => a + b.run);

          if (todayData.where((t) => t.cycling != null).length > 0)
            cycling = todayData
                .where((t) => t.cycling != null)
                .fold(0, (a, b) => a + b.cycling);

          if (todayData.where((t) => t.etc != null).length > 0)
            etc = todayData
                .where((t) => t.etc != null)
                .fold(0, (a, b) => a + b.etc);

          runPercent = run / 60 < 1 ? run / 60 : 1;
          cyclingPercent = cycling / 60 < 1 ? cycling / 60 : 1;
          etcPercent = etc / 60 < 1 ? etc / 60 : 1;
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
                              top: 16, left: 16, right: 16),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 16),
                                child: Center(
                                  child: Stack(
                                    overflow: Overflow.visible,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          width: 150,
                                          height: 150,
                                          decoration: BoxDecoration(
                                            color: AppTheme.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(120.0),
                                            ),
                                            border: new Border.all(
                                                width: 4,
                                                color: AppTheme.nearlyDarkBlue
                                                    .withOpacity(0.2)),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              SizedBox(height: 10),
                                              Text(
                                                '${(steps * animation.value).toInt()}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: AppTheme.fontName,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 32,
                                                  letterSpacing: 0.0,
                                                  color:
                                                      AppTheme.nearlyDarkBlue,
                                                ),
                                              ),
                                              // FaIcon(FontAwesomeIcons.walking,
                                              //     size: 16,
                                              //     color: AppTheme.grey
                                              //         .withOpacity(0.5)),
                                              Text(
                                                '10,000 steps',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: AppTheme.fontName,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  letterSpacing: 0.0,
                                                  color: AppTheme.grey
                                                      .withOpacity(0.5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: CustomPaint(
                                          painter: CurvePainter(
                                              colors: [
                                                AppTheme.nearlyDarkBlue,
                                                HexColor("#8A98E8"),
                                                HexColor("#8A98E8")
                                              ],
                                              angle: 6000 / 10000 * 360 +
                                                  (360 - 6000 / 10000 * 360) *
                                                      (1.0 - animation.value)),
                                          child: SizedBox(
                                            width: 158,
                                            height: 158,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
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
                              left: 24, right: 24, top: 8, bottom: 16),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'วิ่ง',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        letterSpacing: -0.2,
                                        color: AppTheme.darkText,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Container(
                                        height: 4,
                                        width: 70,
                                        decoration: BoxDecoration(
                                          color: HexColor('#87A0E5')
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4.0)),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Container(
                                              width: (runPercent *
                                                  70 *
                                                  animation.value),
                                              height: 4,
                                              decoration: BoxDecoration(
                                                gradient:
                                                    LinearGradient(colors: [
                                                  HexColor('#87A0E5'),
                                                  HexColor('#87A0E5')
                                                      .withOpacity(0.5),
                                                ]),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(4.0)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        '$run' + ' นาที',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: AppTheme.grey.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'ปั่น',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            letterSpacing: -0.2,
                                            color: AppTheme.darkText,
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Container(
                                            height: 4,
                                            width: 70,
                                            decoration: BoxDecoration(
                                              color: HexColor('#F56E98')
                                                  .withOpacity(0.2),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4.0)),
                                            ),
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  width: (cyclingPercent *
                                                      70 *
                                                      animationController
                                                          .value),
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        LinearGradient(colors: [
                                                      HexColor('#F56E98')
                                                          .withOpacity(0.1),
                                                      HexColor('#F56E98'),
                                                    ]),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                4.0)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: Text(
                                            '$cycling' + ' นาที',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: AppTheme.grey
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'อื่นๆ',
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                            letterSpacing: -0.2,
                                            color: AppTheme.darkText,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 0, top: 4),
                                          child: Container(
                                            height: 4,
                                            width: 70,
                                            decoration: BoxDecoration(
                                              color: HexColor('#F1B440')
                                                  .withOpacity(0.2),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4.0)),
                                            ),
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  width: (etcPercent *
                                                      70 *
                                                      animationController
                                                          .value),
                                                  height: 4,
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        LinearGradient(colors: [
                                                      HexColor('#F1B440')
                                                          .withOpacity(0.1),
                                                      HexColor('#F1B440'),
                                                    ]),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                4.0)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: Text(
                                            '$etc' + ' นาที',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                              color: AppTheme.grey
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
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

class CurvePainter extends CustomPainter {
  final double angle;
  final List<Color> colors;

  CurvePainter({this.colors, this.angle = 140});

  @override
  void paint(Canvas canvas, Size size) {
    List<Color> colorsList = List<Color>();
    if (colors != null) {
      colorsList = colors;
    } else {
      colorsList.addAll([Colors.white, Colors.white]);
    }

    final shdowPaint = new Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final shdowPaintCenter = new Offset(size.width / 2, size.height / 2);
    final shdowPaintRadius =
        math.min(size.width / 2, size.height / 2) - (14 / 2);
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.3);
    shdowPaint.strokeWidth = 16;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.2);
    shdowPaint.strokeWidth = 20;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle)),
        false,
        shdowPaint);

    shdowPaint.color = Colors.grey.withOpacity(0.1);
    shdowPaint.strokeWidth = 22;
    canvas.drawArc(
        new Rect.fromCircle(center: shdowPaintCenter, radius: shdowPaintRadius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle)),
        false,
        shdowPaint);

    final rect = new Rect.fromLTWH(0.0, 0.0, size.width, size.width);
    final gradient = new SweepGradient(
      startAngle: degreeToRadians(268),
      endAngle: degreeToRadians(270.0 + 360),
      tileMode: TileMode.repeated,
      colors: colorsList,
    );
    final paint = new Paint()
      ..shader = gradient.createShader(rect)
      ..strokeCap = StrokeCap.round // StrokeCap.round is not recommended.
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    final center = new Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - (14 / 2);

    canvas.drawArc(
        new Rect.fromCircle(center: center, radius: radius),
        degreeToRadians(278),
        degreeToRadians(360 - (365 - angle)),
        false,
        paint);

    final gradient1 = new SweepGradient(
      tileMode: TileMode.repeated,
      colors: [Colors.white, Colors.white],
    );

    var cPaint = new Paint();
    cPaint..shader = gradient1.createShader(rect);
    cPaint..color = Colors.white;
    cPaint..strokeWidth = 14 / 2;
    canvas.save();

    final centerToCircle = size.width / 2;
    canvas.save();

    canvas.translate(centerToCircle, centerToCircle);
    canvas.rotate(degreeToRadians(angle + 2));

    canvas.save();
    canvas.translate(0.0, -centerToCircle + 14 / 2);
    canvas.drawCircle(new Offset(0, 0), 14 / 5, cPaint);

    canvas.restore();
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  double degreeToRadians(double degree) {
    var redian = (math.pi / 180) * degree;
    return redian;
  }
}
