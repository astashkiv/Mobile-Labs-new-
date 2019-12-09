import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_ios_app/model/news.dart';

import 'details.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    var recentJobsRef = FirebaseDatabase.instance.reference().child('articles');
    return Container(
      child: StreamBuilder(
        stream: recentJobsRef.onValue,
        builder: (context, snapshot) {
          List<Article> list = [];
          Map<dynamic, dynamic> values;
          if (snapshot != null && snapshot.data != null)
            values = snapshot.data.snapshot.value;
          if (values != null && snapshot.data != null)
            values.forEach((key, values) {
              var artical1 = Article();
              artical1.city = values['city'];
              artical1.river = values['river'];
              artical1.level = values['level'];
              artical1.urlToImage = values['urlToImage'];
              artical1.date = values['date'];
              list.add(artical1);
            });
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (list.length == 0) {
            return Center(
              child: Text("No News Found!"),
            );
          } else {
            return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20),
                itemCount: list.length,
                itemBuilder: (BuildContext context, int index) {
                  var artical = list[index];
                  return Card(
                    child: Container(
                      height: 120.0,
                      width: 120.0,
                      child: Center(
                        child: ListTile(
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              'At ${artical.date} level was ${artical.level}',
                            ),
                          ),
                          title: Text(
                            '${artical.river} near ${artical.city}',
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          leading: Container(
                            width: 100,
                            height: 100,
                            child: artical.urlToImage == null
                                ? Image.asset(
                                    'images/no_image_available.png',
                                    fit: BoxFit.fill,
                                  )
                                : Image.network(
                                    '${artical.urlToImage}',
                                    fit: BoxFit.fill,
                                  ),
                          ),
                          onTap: () => _onTapItem(context, artical),
                        ),
                      ),
                    ),
                  );
                });
          }
        },
      ),
    );
  }

  void _onTapItem(BuildContext context, Article article) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => NewsDetails(article)));
  }
}
