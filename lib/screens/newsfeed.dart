import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellness/dashboard/app_theme.dart';
import 'package:wellness/models/news.dart';
import 'package:wellness/widgets/appbar_ui.dart';

Future<News> loadData() async {
  // add facebook graph link
  String url =
      'https://graph.facebook.com/v6.0/me?fields=posts%7Bmessage%2Cpermalink_url%2Cfull_picture%2Ccreated_time%7D&access_token=EAAUgHKSUGGIBAKNQQxnNXgFrz0Lkep7fVeYlIgHS0omujhZC0OFYzS2VAwBdXxEZBGOpoZBtQ15ZATrgeLh9sRu6hVyODAw0i6FDupcerPmz3Lm986xwfwmmAbxhdZCkH0VudKMZAfRspS7oaZC5JINsQxIZAIuJEeSzLcYZAeWC03cCRRx4afAOrgiCT2xm1NXwZD';
  File file = await DefaultCacheManager().getSingleFile(url);
  if (file != null) {
    Map jsonString = jsonDecode(file.readAsStringSync());
    return News.fromJson(jsonString);
  } else {
    return null;
  }
}

class NewsPage extends StatefulWidget {
  const NewsPage({Key key, this.animationController}) : super(key: key);
  final AnimationController animationController;
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  Future<News> newsList;
  Animation<double> topBarAnimation;

  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.0;

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
    newsList = loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          _buildBody(context),
          AppBarUI(
            animationController: widget.animationController,
            topBarAnimation: topBarAnimation,
            topBarOpacity: topBarOpacity,
            title: 'ข่าวสาร',
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom,
          )
        ]),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder<News>(
      future: newsList,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return _buildList(context, snapshot.data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return LinearProgressIndicator();
      },
    );
  }

  Widget _buildList(BuildContext context, News news) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(
        top: AppBar().preferredSize.height +
            MediaQuery.of(context).padding.top +
            24,
        bottom: 62 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: news.posts.data.length,
      itemBuilder: (context, i) {
        return InkWell(
          onTap: () async {
            //  add facebook link
            final url = news.posts.data[i].permalinkUrl;
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
          child: Card(
            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
            elevation: 2,
            child: Column(
              children: <Widget>[
                news.posts.data[i].fullPicture != null
                    ? Container(
                        height: 200,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            // alignment: Alignment(0, 0),
                            fit: BoxFit.cover,
                            //  add image URL
                            image: NetworkImage(news.posts.data[i].fullPicture),
                          ),
                        ),
                      )
                    : SizedBox(),
                news.posts.data[i].message == null
                    ? SizedBox()
                    : Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        //  add message
                        child: Text(
                          news.posts.data[i].message,
                          style: TextStyle(
                              fontSize: 16, color: Colors.grey.shade800),
                        )),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.access_time,
                        color: AppTheme.grey.withOpacity(0.6),
                        size: 16,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: Text(
                          _convertDate(news.posts.data[i].createdTime),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            letterSpacing: 0.0,
                            color: AppTheme.grey.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  String _convertDate(String src) {
    DateTime date = DateTime.parse(src);
    return DateFormat.yMMMd().format(date);
  }
}
