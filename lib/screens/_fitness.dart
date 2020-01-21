import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:wellness/models/news.dart';

Future<News> loadData() async {
  // add facebook graph link
  String url =
      'https://graph.facebook.com/v3.2/me?fields=id%2Cname%2Cposts%7Bmessage%2Clink%2Ccreated_time%2Cpicture%7D&access_token=EAAEzLmZAA3W4BAIJbisa9ul6LnfZBO3fcjM4bZBZA3jjOeWZCepfEnu5eZCZBwitkwbTu9pt3K0cpzGJJ1QMn2SuLiWiBUk3fIFbIYZC9QahiGBJBQfqvnJixvgUMj3Rvqloq0RCa8rRfNxTSPEGTbyOBXe2jaWIxPkOG8gCJSlhcIg7ANwviRI10uBZAkNTDfuPwjAie51uTFwZDZD';
  File file = await DefaultCacheManager().getSingleFile(url);
  Map jsonString = jsonDecode(file.readAsStringSync());

  return News.fromJson(jsonString);
}

class FitnessPage extends StatefulWidget {
  @override
  _FitnessPageState createState() => _FitnessPageState();
}

class _FitnessPageState extends State<FitnessPage> {
  Future<News> newsList;

  @override
  void initState() {
    super.initState();
    newsList = loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Fitness Program"),
        ),
        body: Center(
          child: FutureBuilder<News>(
              future: newsList,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return _buildList(context, snapshot);
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              }),
        ));
  }

  Widget _buildList(BuildContext context, snapshot) {
    return ListView.builder(
      itemCount: snapshot.data.posts.data.length,
      itemBuilder: (context, i) {
        return GestureDetector(
          onTap: () async {
            //  add facebook link
            final url = snapshot.data.posts.data[i].link;
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
          child: Card(
            margin: EdgeInsets.fromLTRB(0, 8, 0, 16),
            elevation: 8,
            child: Column(
              children: <Widget>[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      // alignment: Alignment(0, 0),
                      fit: BoxFit.cover,
                      //  add image URL
                      image: CachedNetworkImageProvider(
                          snapshot.data.posts.data[i].picture),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  //  add message
                  child: Text(snapshot.data.posts.data[i].message),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
