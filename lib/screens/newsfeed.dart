import 'dart:io';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellness/fitness_app/fitness_app_theme.dart';
import 'package:wellness/models/news.dart';
import 'package:wellness/widgets/appbar_ui.dart';

Future<News> loadData() async {
  // add facebook graph link
  String url =
      'https://graph.facebook.com/v5.0/me?fields=posts%7Bmessage%2Cpermalink_url%2Cfull_picture%2Ccreated_time%7D&access_token=EAAUgHKSUGGIBAGQNlKU8g8ZAbZBRy9AVM55PZClHXNdb8q4edT8IISZCMJhto4wEbWZA8DeknucmwKls91aOvyxxkcfjZCp2fgJeDsqbCgW3YceGyF4BDWwF1yCPTIzduwEHM4H3FjnuJRBn8UZCPLqNb1AOaG0LvOJhIFjDhEE7k0oXCvbGPUDnCJre3sotC4ZD';
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
    newsList = loadData();

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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FitnessAppTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
            child: Stack(children: [
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
        ])),
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
      itemCount: news.posts.data.length,
      itemBuilder: (context, i) {
        return GestureDetector(
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
            margin: EdgeInsets.fromLTRB(0, 8, 0, 8),
            elevation: 1,
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
                            image: CachedNetworkImageProvider(
                                news.posts.data[i].fullPicture),
                          ),
                        ),
                      )
                    : SizedBox(),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  //  add message
                  child: Text(
                    news.posts.data[i].message,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
                  ),
                ),
                // Padding(
                //   padding: EdgeInsets.all(16.0),
                //   //  add message
                //   child: Text(news.posts.data[i].createdTime),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
