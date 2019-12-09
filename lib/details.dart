import 'package:flutter/material.dart';
import 'model/news.dart';
import 'home2.dart';

class NewsDetails extends StatefulWidget {
  final Article article;

  NewsDetails(this.article);

  @override
  _NewsDetailsState createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {
  get position => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Details'),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            verticalDirection: VerticalDirection.up,
            children: <Widget>[
              Column(
                children: <Widget>[
                  Image.network(widget.article.urlToImage),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${widget.article.river} near ${widget.article.city}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'At ${widget.article.date} level was ${widget.article.level}'
                    ),
                  )
                ],
              ),
            ],
          ),
        ));
  }
}