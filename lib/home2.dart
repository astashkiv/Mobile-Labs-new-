import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'main.dart';
import 'model/news.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity/connectivity.dart';

void main() => runApp(new MyApp());

class HomePage extends StatefulWidget {
  String newsType;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  StreamSubscription<ConnectivityResult> _subscription;
  
  @override
  void initState() {
    _subscription = Connectivity().onConnectivityChanged.listen(onConnectivityChange);
    super.initState();
  }

Future<List<Article>> getData(String newsType) async {
    List<Article> list;
    String link = "https://mobile-iot-lab.firebaseio.com/.json";
    var res = await http
        .get(Uri.encodeFull(link), headers: {"Accept": "application/json"});
    // print(res.body);
    if (res.statusCode == 200) {
      var data = json.decode(res.body);
      var rest = data["articles"] as List;
      print(rest);
      list = rest.map<Article>((json) => Article.fromJson(json)).toList();
    }
    print("List Size: ${list.length}");
    return list;
  }

  Widget listViewWidget(List<Article> Article) {
    return Container(
      child: ListView.builder(
          itemCount: Article.length,
          padding: const EdgeInsets.all(1.0),
          itemBuilder: (context, position) {
            return Card(
              child: Container(
                height: 120.0,
                width: 120.0,
                child: Center(
                  child: ListTile(
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        'At ${Article[position].date} level was ${Article[position].level}',
                      ),
                    ),
                    title: Text(
                      '${Article[position].river} near ${Article[position].city}',
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    leading: Container(
                      child: Article[position].urlToImage == null
                          ? Image.asset('images/no_image_available.png',height: 200,)
                          : Image.network('${Article[position].urlToImage}',height: 200,),
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  void onConnectivityChange(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      _scaffoldKey.currentState.showSnackBar(_buildNoNetworkSnackBar());
    }
  }

  Widget _buildNoNetworkSnackBar() {
    return new SnackBar(
      content: Text('No internet connection'),
      backgroundColor: Colors.redAccent,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: new AppBar(
          title: new Text('Home'),
          actions: <Widget>[
            new FlatButton(
                child: new Text('Logout',
                    style: new TextStyle(fontSize: 17.0, color: Colors.white)),
                onPressed: () {
                auth.signOut().then((onValue) {
                  Navigator.of(context).pushReplacementNamed('/login');
                });
              }),
          ],
        ),
      body: FutureBuilder(
          future: getData(widget.newsType),
          builder: (context, snapshot) {
            return snapshot.data != null
                ? listViewWidget(snapshot.data)
                : Center(child: CircularProgressIndicator());
          }),
    );
  }
}
