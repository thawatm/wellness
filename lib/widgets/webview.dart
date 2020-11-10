import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';

class CustomWebView extends StatelessWidget {
  final url;
  CustomWebView({Key key, @required this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          title: Text('รายละเอียด'),
          gradient: LinearGradient(
              colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
        ),
        body: WebView(
          initialUrl: url,
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
