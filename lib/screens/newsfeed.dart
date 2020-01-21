import 'dart:io';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellness/logic/constant.dart';
import 'package:wellness/models/news.dart';

Future<News> loadData() async {
  // add facebook graph link
  String url =
      'https://graph.facebook.com/v5.0/me?fields=posts%7Bmessage%2Cpermalink_url%2Cfull_picture%2Ccreated_time%7D&access_token=EAAUgHKSUGGIBAGQNlKU8g8ZAbZBRy9AVM55PZClHXNdb8q4edT8IISZCMJhto4wEbWZA8DeknucmwKls91aOvyxxkcfjZCp2fgJeDsqbCgW3YceGyF4BDWwF1yCPTIzduwEHM4H3FjnuJRBn8UZCPLqNb1AOaG0LvOJhIFjDhEE7k0oXCvbGPUDnCJre3sotC4ZD';
  File file = await DefaultCacheManager().getSingleFile(url);
  Map jsonString = jsonDecode(file.readAsStringSync());

  return News.fromJson(jsonString);
}

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  Future<News> newsList;

  @override
  void initState() {
    super.initState();
    newsList = loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: GradientAppBar(
        title: Text('ข่าวสาร'),
        gradient: LinearGradient(colors: [appBarColor1, appBarColor2]),
      ),
      body: SafeArea(child: _buildBody(context)),
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
