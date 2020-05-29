import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/screens/profile.dart';

class AppBarUI extends StatelessWidget {
  final AnimationController animationController;
  final Animation<double> topBarAnimation;
  final double topBarOpacity;
  final String title;
  final bool isPop;
  final Widget calendar;
  final bool isMenu;
  final double letterSpacing;
  AppBarUI(
      {@required this.animationController,
      @required this.topBarAnimation,
      @required this.topBarOpacity,
      @required this.title,
      this.isPop: false,
      this.calendar,
      this.isMenu: true,
      this.letterSpacing: 1.2});
  @override
  Widget build(BuildContext context) {
    SystemUiOverlayStyle _currentStyle = SystemUiOverlayStyle.dark;

    return AnnotatedRegion(
      value: _currentStyle,
      child: Column(
        children: <Widget>[
          AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget child) {
              return FadeTransition(
                opacity: topBarAnimation,
                child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 30 * (1.0 - topBarAnimation.value), 0.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.white.withOpacity(topBarOpacity),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color:
                                AppTheme.grey.withOpacity(0.4 * topBarOpacity),
                            offset: const Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).padding.top,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 12,
                              right: 12,
                              top: 16 - 8.0 * topBarOpacity,
                              bottom: 12 - 8.0 * topBarOpacity),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              isPop
                                  ? InkWell(
                                      onTap: () => Navigator.pop(context),
                                      child: Icon(
                                        Icons.arrow_back_ios,
                                        color: AppTheme.darkerText,
                                      ),
                                    )
                                  : SizedBox(),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    title,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 22 + 4 - 4 * topBarOpacity,
                                      letterSpacing: letterSpacing,
                                      color: AppTheme.darkerText,
                                    ),
                                  ),
                                ),
                              ),
                              calendar ?? SizedBox(),
                              !isMenu
                                  ? SizedBox()
                                  : InkWell(
                                      onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => ProfilePage(
                                                    animationController:
                                                        animationController)),
                                          ),
                                      child: Icon(Icons.menu))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
