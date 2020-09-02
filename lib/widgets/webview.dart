import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/dashboard/app_theme.dart';

class WebView extends StatelessWidget {
  final url;
  WebView({Key key, @required this.url}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: url,
      scrollBar: false,
      appBar: GradientAppBar(
        title: Text('รายละเอียด'),
        gradient: LinearGradient(
            colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
      ),
      withLocalStorage: true,
      hidden: true,
    );
  }
}
