import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:wellness/logic/constant.dart';

class MonitorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text('สุขภาพประจำวัน'),
        gradient: LinearGradient(colors: [appBarColor1, appBarColor2]),
      ),
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.only(top: 4),
          child: GridView.count(
            padding: EdgeInsets.all(8.0),
            crossAxisCount: 2,
            children: <Widget>[
              GridTile(
                child: InkResponse(
                  onTap: () => Navigator.pushNamed(context, '/pressure'),
                  child: Card(
                    color: Colors.blueAccent,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.favorite, size: 60, color: Colors.white),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Text(
                              'ความดัน หัวใจ',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GridTile(
                child: InkResponse(
                  onTap: () => Navigator.pushNamed(context, '/weight'),
                  child: Card(
                    color: Colors.blueAccent,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.perm_contact_calendar,
                              size: 60, color: Colors.white),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Text(
                              'น้ำหนัก ไขมัน',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GridTile(
                child: InkResponse(
                  onTap: () => Navigator.pushNamed(context, '/blood'),
                  child: Card(
                    color: Colors.blueAccent,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.library_books,
                              size: 60, color: Colors.white),
                          Text(
                            'ค่าผลเลือด',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GridTile(
                child: InkResponse(
                  onTap: () => Navigator.pushNamed(context, '/food'),
                  child: Card(
                    color: Colors.blueAccent,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.restaurant, size: 60, color: Colors.white),
                          Text(
                            'อาหาร',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GridTile(
                child: InkResponse(
                  onTap: () => Navigator.pushNamed(context, '/drink'),
                  child: Card(
                    color: Colors.blueAccent,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.local_drink,
                              size: 60, color: Colors.white),
                          Text(
                            'การดื่มน้ำ',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              GridTile(
                child: InkResponse(
                  onTap: () => Navigator.pushNamed(context, '/sleep'),
                  child: Card(
                    color: Colors.blueAccent,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.local_hotel,
                              size: 60, color: Colors.white),
                          Text(
                            'การนอน',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
