import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellness/dashboard/app_theme.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text('ติดต่อเรา'),
        gradient: LinearGradient(
            colors: [AppTheme.appBarColor1, AppTheme.appBarColor2]),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.local_hospital),
              title: Text(
                  'ศูนย์สุขภาพดีวัยทำงาน สำนักบริหารยุทธศาสตร์สุขภาพดีวิถีชีวิตไทย',
                  style: TextStyle(fontSize: 16)),
              onTap: () => _launchURL('https://www.facebook.com/moph.wellness'),
            ),
            Divider(height: 2.0),
            ListTile(
              leading: Icon(Icons.sim_card),
              title: Text('ศูนย์เทคโนโลยีสิ่งอำนวยความสะดวกและเครื่องมือแพทย์',
                  style: TextStyle(fontSize: 16)),
              onTap: () => _launchURL('https://www.facebook.com/A.MED.nstda/'),
            ),
            Divider(height: 2.0),
            ListTile(
              leading: Icon(Icons.link),
              title: Text(
                'DrSant บทความสุขภาพ',
                style: TextStyle(fontSize: 16),
              ),
              onTap: () => _launchURL('http://visitdrsant.blogspot.com/'),
            ),
            Divider(
              height: 2,
            ),
            SizedBox(
              height: 50,
            ),
            InkWell(
              child: Container(
                padding: EdgeInsets.only(top: 30),
                height: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    image: DecorationImage(
                      image: AssetImage('assets/images/logo1.png'),
                      fit: BoxFit.fitHeight,
                    )),
              ),
              onTap: () => _launchURL(
                  'https://www.facebook.com/pages/category/Health-Beauty/%E0%B8%A8%E0%B8%B9%E0%B8%99%E0%B8%A2%E0%B9%8C%E0%B8%AA%E0%B8%B8%E0%B8%82%E0%B8%A0%E0%B8%B2%E0%B8%9E%E0%B8%94%E0%B8%B5%E0%B8%A7%E0%B8%B1%E0%B8%A2%E0%B8%97%E0%B8%B3%E0%B8%87%E0%B8%B2%E0%B8%99-%E0%B8%AA%E0%B8%B3%E0%B8%99%E0%B8%B1%E0%B8%81%E0%B8%9A%E0%B8%A3%E0%B8%B4%E0%B8%AB%E0%B8%B2%E0%B8%A3%E0%B8%A2%E0%B8%B8%E0%B8%97%E0%B8%98%E0%B8%A8%E0%B8%B2%E0%B8%AA%E0%B8%95%E0%B8%A3%E0%B9%8C%E0%B8%AA%E0%B8%B8%E0%B8%82%E0%B8%A0%E0%B8%B2%E0%B8%9E%E0%B8%94%E0%B8%B5%E0%B8%A7%E0%B8%B4%E0%B8%96%E0%B8%B5%E0%B8%8A%E0%B8%B5%E0%B8%A7%E0%B8%B4%E0%B8%95%E0%B9%84%E0%B8%97%E0%B8%A2-112373673575949/'),
            ),
            SizedBox(height: 30),
            InkWell(
              child: Container(
                padding: EdgeInsets.all(8),
                height: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    image: DecorationImage(
                      image: AssetImage('assets/images/amedlogo.png'),
                      fit: BoxFit.fitHeight,
                    )),
              ),
              onTap: () => _launchURL('https://www.facebook.com/A.MED.nstda/'),
            ),
            InkWell(
              child: Container(
                padding: EdgeInsets.only(top: 30),
                height: 100,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    image: DecorationImage(
                      image: AssetImage('assets/images/wecare_logo.png'),
                      fit: BoxFit.fitHeight,
                    )),
              ),
              onTap: () => _launchURL('https://www.wellnesswecare.com/'),
            ),
          ],
        ),
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
