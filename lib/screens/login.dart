import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:wellness/fitness_app/app_theme.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AssetImage _backgroundImage = new AssetImage("assets/images/icon.png");

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(child: buildBody, inAsyncCall: _isLoading);
  }

  Widget get buildBody {
    final logo = Container(
      // margin: EdgeInsets.all(16),
      // width: MediaQuery.of(context).size.width,
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.fill,
          image: _backgroundImage,
        ),
      ),
    );

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SingleChildScrollView(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.appBarColor1, AppTheme.appBarColor2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: 180),
              Center(child: logo),
              SizedBox(height: 8),
              Text(
                'ศูนย์สุขภาพดีวัยทำงาน',
                style: TextStyle(
                    fontSize: 24,
                    // fontWeight: FontWeight.bold,
                    color: Colors.grey.shade200),
              ),
              Text(
                'Wellness Center',
                style: TextStyle(
                    fontSize: 24,
                    // fontWeight: FontWeight.bold,
                    color: Colors.grey.shade100),
              ),
              SizedBox(height: height - 560),
              Container(
                height: 50,
                width: 300,
                child: OutlineButton.icon(
                  borderSide: BorderSide(width: 1, color: Colors.white54),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  icon: Icon(Icons.person_add, color: Colors.white70),
                  // elevation: 7.0,
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  // padding: EdgeInsets.all(12),
                  // color: Colors.grey.shade100,
                  label: Text('ผู้ใช้งานใหม่',
                      style: TextStyle(color: Colors.white70, fontSize: 18)),
                ),
              ),
              SizedBox(height: 30.0),
              Container(
                height: 50,
                width: 300,
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  icon: Icon(Icons.vpn_key, color: AppTheme.nearlyDarkBlue),
                  // elevation: 7.0,
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  // padding: EdgeInsets.all(12),
                  color: Colors.grey.shade300,
                  label: Text('เข้าสู่ระบบ',
                      style: TextStyle(
                          color: AppTheme.nearlyDarkBlue, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
