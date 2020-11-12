import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/state_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:wellness/widgets/appbar_ui.dart';

class KnowledgePage extends StatefulWidget {
  const KnowledgePage({Key key, this.animationController}) : super(key: key);
  final AnimationController animationController;
  @override
  _KnowledgePageState createState() => _KnowledgePageState();
}

class _KnowledgePageState extends State<KnowledgePage> {
  Animation<double> topBarAnimation;
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

  String uid;
  ImageProvider profileImage;
  File tempImage;

  @override
  void initState() {
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: widget.animationController,
            curve: Interval(0, 0.5, curve: Curves.fastOutSlowIn)));

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
    uid = ScopedModel.of<StateModel>(context).uid;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: buildBody(context),
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          buildNotificationPanel(width, height),
          AppBarUI(
            animationController: widget.animationController,
            topBarAnimation: topBarAnimation,
            topBarOpacity: topBarOpacity,
            title: 'ความรู้',
            isPop: true,
            isMenu: false,
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          )
        ],
      ),
    );
  }

  Widget buildNotificationPanel(double width, double height) {
    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 16, top: 130, bottom: 0),
      child: SingleChildScrollView(
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
          child: Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: Column(
              children: <Widget>[
                Material(
                  // elevation: 1,
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      buildNotificationItem(
                          icon: FontAwesomeIcons.filePdf,
                          title: 'Life’s Simple 7',
                          subtitle: 'ตัวชี้วัดสุขภาพ 7 ตัว',
                          url: 'https://www.youtube.com/watch?v=J5wor5ZxhgQ',
                          startColor: Color(0xFF738AE6),
                          endColor: Color(0xFF5C5EDD)),
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
                      buildNotificationItem(
                          icon: FontAwesomeIcons.filePdf,
                          title: 'เล่ม 1',
                          subtitle: 'คู่มือการดำเนินศูนย์สุขภาพดีวัยทำงาน 1',
                          url: 'http://18.141.44.152/wellness/wellness1.pdf',
                          startColor: Color(0xFF738AE6),
                          endColor: Color(0xFF5C5EDD)),
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
                      buildNotificationItem(
                          icon: FontAwesomeIcons.filePdf,
                          title: 'เล่ม 2',
                          subtitle: 'คู่มือการดำเนินศูนย์สุขภาพดีวัยทำงาน 2',
                          url: 'http://18.141.44.152/wellness/wellness2.pdf',
                          startColor: Color(0xFF738AE6),
                          endColor: Color(0xFF5C5EDD)),
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
                      buildNotificationItem(
                          icon: FontAwesomeIcons.filePdf,
                          title: '7 Weeks',
                          subtitle: '7 สัปดาห์ สุขภาพดี หุ่นดี ที่บ้าน',
                          url:
                              'http://multimedia.anamai.moph.go.th/wp-content/uploads/2020/06/7-WEEKS-Fit@home.pdf',
                          startColor: Color(0xFF738AE6),
                          endColor: Color(0xFF5C5EDD)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildNotificationItem(
      {IconData icon,
      String title,
      String subtitle,
      String url,
      Color startColor,
      Color endColor}) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 10),
        leading: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            icon,
            size: 28,
            color: Colors.white70,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.lightText),
        ),
        subtitle: Text(
          subtitle,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        onTap: () async {
          if (url == 'simple7') {
            Navigator.pushNamed(context, '/knowledge_simple7');
          } else if (await canLaunch(url)) {
            await launch(url);
          } else {
            throw 'Could not launch $url';
          }
        },
      ),
    );
  }
}
