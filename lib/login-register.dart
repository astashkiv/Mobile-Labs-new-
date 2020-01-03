import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'styles.dart';

class LoginRegister extends StatefulWidget {
  @override
  _LoginRegisterState createState() => _LoginRegisterState();
}

class _LoginRegisterState extends State<LoginRegister> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PersistentBottomSheetController _sheetController;
  String _email;
  String _password;
  String _displayName;
  String _phone;
  bool _loading = false;
  bool _autoValidate = false;
  String errorMsg = "";

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    //Logo
    Widget _logo() {
      return new Hero(
        tag: 'hero',
        child: Padding(
          padding: EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 50.0),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 40.0,
            child: Image.asset('assets/logo.png'),
          ),
        ),
      );
    }

    //button widgets
    Widget filledButton(String text, Color splashColor, Color highlightColor,
        Color fillColor, Color textColor, void function()) {
      return RaisedButton(
        splashColor: splashColor,
        highlightColor: highlightColor,
        elevation: 0.0,
        color: fillColor,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        child: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: textColor, fontSize: 20),
        ),
        onPressed: () {
          function();
        },
      );
    }

    outlineButton(void function()) {
      return OutlineButton(
        highlightedBorderColor: primaryColor,
        borderSide: BorderSide(color: primaryColor, width: 2.0),
        highlightElevation: 0.0,
        splashColor: primaryColor,
        highlightColor: primaryColor,
        color: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(30.0),
        ),
        child: Text(
          "Register",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: primaryColor, fontSize: 20),
        ),
        onPressed: () {
          function();
        },
      );
    }

    void _validateLoginInput() async {
      final FormState form = _formKey.currentState;
      if (_formKey.currentState.validate()) {
        form.save();
        _sheetController.setState(() {
          _loading = true;
        });
        try {
          AuthResult authResult = await FirebaseAuth.instance
              .signInWithEmailAndPassword(email: _email, password: _password);

          FirebaseUser user = authResult.user;
          Navigator.of(context).pushReplacementNamed('/home');
        } catch (error) {
          switch (error.code) {
            case "ERROR_USER_NOT_FOUND":
              {
                _sheetController.setState(() {
                  errorMsg = "User with this email/pass not found :(";
                  _loading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                      );
                    });
              }
              break;
            case "ERROR_WRONG_PASSWORD":
              {
                _sheetController.setState(() {
                  errorMsg = "Password doesn\'t match your email.";
                  _loading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                      );
                    });
              }
              break;
            default:
              {
                _sheetController.setState(() {
                  errorMsg = "";
                });
              }
          }
        }
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    }

    void _validateRegisterInput() async {
      final FormState form = _formKey.currentState;
      if (_formKey.currentState.validate()) {
        form.save();
        _sheetController.setState(() {
          _loading = true;
        });
        try {
          AuthResult authResult = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
                  email: _email, password: _password);
          FirebaseUser user = authResult.user;

          UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
          userUpdateInfo.displayName = _displayName;
          user.updateProfile(userUpdateInfo).then((onValue) {
            Navigator.of(context).pushReplacementNamed('/home');
            Firestore.instance.collection('users').document().setData({
              'email': _email,
              'displayName': _displayName,
              'phone': _phone
            }).then((onValue) {
              _sheetController.setState(() {
                _loading = false;
              });
            });
          });
        } catch (error) {
          switch (error.code) {
            case "ERROR_EMAIL_ALREADY_IN_USE":
              {
                _sheetController.setState(() {
                  errorMsg = "This email is already in use.";
                  _loading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                      );
                    });
              }
              break;
            default:
              {
                _sheetController.setState(() {
                  errorMsg = "";
                });
              }
          }
        }
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    }

    String emailValidator(String value) {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (value.isEmpty) return 'Required';
      if (!regex.hasMatch(value))
        return 'Please enter a valid email!';
      else
        return null;
    }

    void loginSheet() {
      _sheetController = _scaffoldKey.currentState
          .showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0)),
            child: Container(
              child: ListView(
                padding: Styles.allPadding,
                children: <Widget>[
                  SingleChildScrollView(
                      child: Form(
                    key: _formKey,
                    autovalidate: _autoValidate,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 50,
                        ),
                        Padding(
                            padding: Styles.inputFormPadding,
                            child: TextFormField(
                              maxLines: 1,
                              keyboardType: TextInputType.emailAddress,
                              autofocus: false,
                              decoration: new InputDecoration(
                                  hintText: "Email",
                                  icon: new Icon(
                                    Icons.mail,
                                    color: Colors.grey,
                                  )),
                              validator: emailValidator,
                              onSaved: (input) {
                                _email = input;
                              },
                            )),
                        Padding(
                            padding: Styles.inputFormPadding,
                            child: TextFormField(
                              maxLines: 1,
                              autofocus: false,
                              obscureText: true,
                              decoration: new InputDecoration(
                                  hintText: "Password",
                                  icon: new Icon(
                                    Icons.lock,
                                    color: Colors.grey,
                                  )),
                              validator: (input) =>
                                  input.isEmpty ? "Required" : null,
                              onSaved: (input) => _password = input,
                            )),
                        SizedBox(
                          height: 30,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: _loading == true
                              ? CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      primaryColor),
                                )
                              : Container(
                                  child: filledButton(
                                      "Login",
                                      Colors.white,
                                      primaryColor,
                                      primaryColor,
                                      Colors.white,
                                      _validateLoginInput),
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
              height: MediaQuery.of(context).size.height / 1.1,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
          ),
        );
      });
    }

    void registerSheet() {
      _sheetController = _scaffoldKey.currentState
          .showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0)),
            child: Container(
              child: ListView(
                padding: Styles.allPadding,
                children: <Widget>[
                  SingleChildScrollView(
                      child: Form(
                    child: Column(children: <Widget>[
                      SizedBox(
                        height: 50,
                      ),
                      Padding(
                          padding: Styles.inputFormPadding,
                          child: TextFormField(
                            maxLines: 1,
                            autofocus: false,
                            decoration: new InputDecoration(
                                hintText: "Name",
                                icon: new Icon(
                                  Icons.account_circle,
                                  color: Colors.grey,
                                )),
                            validator: (value) {
                              if (value.isEmpty) return 'Name can\'t be empty';
                              if (value.length < 1) return 'Name is too short';
                              return null;
                            },
                            onSaved: (input) => _displayName = input,
                          )),
                      Padding(
                          padding: Styles.inputFormPadding,
                          child: TextFormField(
                            maxLines: 1,
                            autofocus: false,
                            decoration: new InputDecoration(
                                hintText: "Email",
                                icon: new Icon(
                                  Icons.email,
                                  color: Colors.grey,
                                )),
                            validator: (value) =>
                                value.isEmpty ? 'Email can\'t be empty' : null,
                            onSaved: (input) => _email = input,
                          )),
                      Padding(
                          padding: Styles.inputFormPadding,
                          child: TextFormField(
                            maxLines: 1,
                            autofocus: false,
                            decoration: new InputDecoration(
                                hintText: "Phone",
                                icon: new Icon(
                                  Icons.phone,
                                  color: Colors.grey,
                                )),
                            validator: (value) =>
                                value.isEmpty ? 'Phone can\'t be empty' : null,
                            onSaved: (input) => _phone = input,
                          )),
                      Padding(
                          padding: Styles.inputFormPadding,
                          child: TextFormField(
                            maxLines: 1,
                            autofocus: false,
                            obscureText: true,
                            decoration: new InputDecoration(
                                hintText: "Password",
                                icon: new Icon(
                                  Icons.lock,
                                  color: Colors.grey,
                                )),
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Password can\'t be empty';
                              if (value.length < 8)
                                return 'Password is too short';
                              return null;
                            },
                            onSaved: (input) => _password = input,
                          )),
                      SizedBox(
                        height: 30,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: _loading
                            ? CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    primaryColor),
                              )
                            : Container(
                                child: filledButton(
                                    "Register",
                                    Colors.white,
                                    primaryColor,
                                    primaryColor,
                                    Colors.white,
                                    _validateRegisterInput),
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                              ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ]),
                    key: _formKey,
                    autovalidate: _autoValidate,
                  )),
                ],
              ),
              height: MediaQuery.of(context).size.height / 1.1,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
          ),
        );
      });
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: new Text("IOT Early Flood Detection"),
        ),
        body: Column(
          children: <Widget>[
            _logo(),
            Padding(
              child: Container(
                child: filledButton("Login", primaryColor, Colors.white,
                    primaryColor, Colors.white, loginSheet),
                height: 50,
              ),
              padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            ),
            Padding(
              child: Container(
                child: outlineButton(registerSheet),
                height: 50,
              ),
              padding: EdgeInsets.only(top: 10, left: 20, right: 20),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ));
  }
}
