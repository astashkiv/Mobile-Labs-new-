import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: <Widget>[
          FutureBuilder(
            future: FirebaseAuth.instance.currentUser(),
            builder: (BuildContext context, AsyncSnapshot user) {
              if (user.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              print(user.data.photoUrl);
              return Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: 40),
                        CircleAvatar(
                          backgroundImage: user.data.photoUrl == null
                              ? AssetImage('assets/account.png')
                              : NetworkImage(user.data.photoUrl),
                          radius: 60,
                        ),
                        SizedBox(height: 10),
                        Text(
                          user.data.displayName.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          user.data.email.toString(),
                          style: TextStyle(),
                        ),
                        SizedBox(height: 20),
                        FlatButton(
                          color: Theme.of(context).accentColor,
                          textColor: Colors.white,
                          child: Text('Edit Profile'),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(
                                user: user.data,
                              ),
                            ),
                          ),
                        ),
               
                      ]));
            },
          ),
        ],
      ),
    );
  }
}
