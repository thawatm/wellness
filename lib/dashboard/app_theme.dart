import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF2F3F8);
  static const Color nearlyDarkBlue = Color(0xFF2633C5);

  static const Color nearlyBlue = Color(0xFF00B6F0);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color dark_grey = Color(0xFF313A44);
  static const Color nearlyPurple = Color(0xFF5C5EDD);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'Prompt';

  // static const Color appBarColor1 = Color(0xFF448AFF);
  // static const Color appBarColor2 = Color(0xFF2633C5);
  // static const Color buttonColor = Color(0xFF448AFF);
  static const Color appBarColor1 = Color(0xFF738AE6);
  static const Color appBarColor2 = Color(0xFF5C5EDD);
  static const Color buttonColor = Color(0xFF738AE6);

  // Colors
  static const kBackgroundColor = Color(0xFFFEFEFE);
  static const kTitleTextColor = Color(0xFF303030);
  static const kBodyTextColor = Color(0xFF4B4B4B);
  static const kTextLightColor = Color(0xFF959595);
  static const kInfectedColor = Color(0xFFFF8748);
  static const kDeathColor = Color(0xFFFF4848);
  static const kRecovercolor = Color(0xFF36C12C);
  static const kPrimaryColor = Color(0xFF3382CC);
  final kShadowColor = Color(0xFFB7B7B7).withOpacity(.16);
  final kActiveShadowColor = Color(0xFF4056C6).withOpacity(.15);

// Text Style
  static const kHeadingTextStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const kSubTextStyle = TextStyle(fontSize: 14, color: kTextLightColor);

  static const kTitleTextstyle = TextStyle(
    fontSize: 18,
    color: kTitleTextColor,
    fontWeight: FontWeight.bold,
  );

  static const TextTheme textTheme = TextTheme(
    headline4: display1,
    headline5: headline,
    headline6: title,
    subtitle2: subtitle,
    bodyText1: body2,
    bodyText2: body1,
    caption: caption,
  );

  static const TextStyle display1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );
}
