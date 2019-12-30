import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:my_ios_app/model/news.dart';
import 'package:path/path.dart' as path;
import 'styles.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

class Add extends StatefulWidget {
  @override
  _AddState createState() => _AddState();
}

class _AddState extends State<Add> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _autoValidate = false;
  String errorMsg = "";
  String _city;
  String _river;
  String _level;
  DateTime _date;
  File _image;
  var format = new DateFormat('dd.MM.yyyy');

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    return Container(
      child: ListView(
        padding: Styles.allPadding,
        children: <Widget>[
          SingleChildScrollView(
              child: Form(
            child: Column(children: <Widget>[
              Padding(
                  padding: Styles.inputFormPadding,
                  child: TextFormField(
                    maxLines: 1,
                    autofocus: false,
                    decoration: new InputDecoration(
                      hintText: "City",
                    ),
                    validator: (value) {
                      if (value.isEmpty) return 'City can\'t be empty';
                      return null;
                    },
                    onSaved: (input) => _city = input,
                  )),
              Padding(
                  padding: Styles.inputFormPadding,
                  child: TextFormField(
                    maxLines: 1,
                    autofocus: false,
                    decoration: new InputDecoration(hintText: "River"),
                    validator: (value) =>
                        value.isEmpty ? 'River can\'t be empty' : null,
                    onSaved: (input) => _river = input,
                  )),
              Padding(
                  padding: Styles.inputFormPadding,
                  child: TextFormField(
                    maxLines: 1,
                    autofocus: false,
                    decoration: new InputDecoration(hintText: "Level"),
                    validator: (value) =>
                        value.isEmpty ? 'Level can\'t be empty' : null,
                    onSaved: (input) => _level = input,
                  )),
              Padding(
                padding: Styles.inputFormPadding,
                child: DateTimeField(
                  format: format,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime(1900),
                        initialDate: currentValue ?? DateTime.now(),
                        lastDate: DateTime(2100));
                  },
                  validator: (value) =>
                      value.toString().length < 10 ? 'Invalid Date' : null,
                  decoration: InputDecoration(hintText: 'Date'),
                  onChanged: (dt) => setState(() => _date = dt),
                ),
              ),
              Padding(
                  padding: Styles.inputFormPadding,
                  child: Column(
                    children: <Widget>[
                      FlatButton(
                        child: Text("Add Image"),
                        onPressed: _showSelectImageDialog,
                        color: primaryColor,
                        textColor: Colors.white,
                      ),
                      Text(
                        errorMsg,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
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
                        valueColor:
                            new AlwaysStoppedAnimation<Color>(primaryColor),
                      )
                    : Container(
                        child: filledButton("Add", Colors.white, primaryColor,
                            primaryColor, Colors.white, _validateAddInput),
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
    );
  }

  _showSelectImageDialog() {
    return Platform.isIOS ? _iosBottomSheet() : _androidDialog();
  }

  _iosBottomSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text('Add Photo'),
          actions: <Widget>[
            CupertinoActionSheetAction(
              child: Text('Take Photo'),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            CupertinoActionSheetAction(
              child: Text('Choose From Gallery'),
              onPressed: () => _handleImage(ImageSource.gallery),
            )
          ],
          cancelButton: CupertinoActionSheetAction(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  _androidDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Add Photo/Video'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Take Photo'),
              onPressed: () => _handleImage(ImageSource.camera),
            ),
            SimpleDialogOption(
              child: Text('Choose From Gallery'),
              onPressed: () => _handleImage(ImageSource.gallery),
            ),
            SimpleDialogOption(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.redAccent,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  _handleImage(ImageSource source) async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(source: source);
    if (imageFile != null) {
      setState(() {
        _image = imageFile;
        errorMsg = "";
      });
    }
  }

  void _validateAddInput() async {
    final FormState form = _formKey.currentState;
    if (_formKey.currentState.validate()) {
      if (_image == null) {
        setState(() {
          errorMsg = "Image is Required";
        });
        return;
      }
      form.save();
      setState(() {
        _loading = true;
      });
      String url = await uploadImage(_image);
      var artical = Article();
      artical.city = _city;
      artical.river = _river;
      artical.level = _level;
      artical.urlToImage = url;
      createNews(artical);
      setState(() {
        _loading = false;
        _image = null;
      });
      _formKey.currentState.reset();
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  Widget filledButton(String text, Color splashColor, Color highlightColor,
      Color fillColor, Color textColor, void function()) {
    return RaisedButton(
      splashColor: splashColor,
      highlightColor: highlightColor,
      elevation: 0.0,
      color: fillColor,
      shape:
          RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
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

  Future<String> uploadImage(File imageFile) async {
    final storageRef = FirebaseStorage.instance.ref();
    String name = path.basename(imageFile.path);
    StorageUploadTask uploadTask =
        storageRef.child('images/news/news_$name.jpg').putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  void createNews(Article news) {
    FirebaseDatabase.instance.reference().child('articles').push().set({
      'city': news.city,
      'date': format.format(_date),
      'river': news.river,
      'level': news.level,
      'urlToImage': news.urlToImage,
    });

  }
}
