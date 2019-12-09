import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_ios_app/styles.dart';
import 'package:path/path.dart' as path;

class EditProfileScreen extends StatefulWidget {
  final FirebaseUser user;

  EditProfileScreen({this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  File _profileImage;
  String _name = '';
  String _email = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.user.displayName;
    _email = widget.user.email;
  }

  _handleImageFromGallery() async {
    File imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      setState(() {
        _profileImage = imageFile;
      });
    }
  }

  _displayProfileImage() {
    if (_profileImage == null) {
      if (widget.user.photoUrl == null) {
        return AssetImage('assets/account.png');
      } else {
        return NetworkImage(widget.user.photoUrl);
      }
    } else {
      return FileImage(_profileImage);
    }
  }

  _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() {
        _isLoading = true;
      });
      String _profileImageUrl = '';
      if (_profileImage != null) {
        _profileImageUrl = await uploadImage(_profileImage);
      }

      UserUpdateInfo userUpdateInfo = new UserUpdateInfo();
      userUpdateInfo.displayName = _name;
      if (_profileImageUrl.isNotEmpty)
        userUpdateInfo.photoUrl = _profileImageUrl;
      else
        _profileImageUrl = widget.user.photoUrl;
      widget.user.updateProfile(userUpdateInfo).then((onValue) {
        Firestore.instance.collection('users').document().setData({
          'email': _email,
          'displayName': _name,
          'photoUrl': _profileImageUrl
        }).then((onValue) {
          setState(() {
            _isLoading = false;
          });
        });
        Navigator.pop(context, false);
      });

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var colorPrimary = Theme.of(context).primaryColor;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: colorPrimary,
          title: Text(
            'Edit Profile',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () => Navigator.pop(context, false),
          )),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 60.0,
                      backgroundColor: Colors.grey,
                      backgroundImage: _displayProfileImage(),
                    ),
                    FlatButton(
                      onPressed: _handleImageFromGallery,
                      child: Text(
                        'Change Profile Image',
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 16.0),
                      ),
                    ),
                    Padding(
                      padding: Styles.inputFormPadding,
                      child: TextFormField(
                        initialValue: _name,
                        style: TextStyle(fontSize: 18.0),
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.person,
                            size: 30.0,
                          ),
                          labelText: 'Name',
                        ),
                        validator: (input) => input.trim().length < 1
                            ? 'Please enter a valid name'
                            : null,
                        onSaved: (input) => _name = input,
                      ),
                    ),
                    Padding(
                        padding: Styles.inputFormPadding,
                        child: TextFormField(
                          initialValue: _email,
                          maxLines: 1,
                          autofocus: false,
                          decoration: new InputDecoration(
                              hintText: "Email",
                              icon: new Icon(
                                Icons.email,
                                size: 30.0,
                              )),
                          validator: (value) => value.isEmpty
                              ? 'Please enter a valid name'
                              : null,
                          onSaved: (input) => _email = input,
                        )),
                    SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 20,
                          right: 20,
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: _isLoading
                          ? CircularProgressIndicator(
                              valueColor: new AlwaysStoppedAnimation<Color>(
                                  colorPrimary),
                            )
                          : Container(
                              child: FlatButton(
                                onPressed: _submit,
                                color: Theme.of(context).primaryColor,
                                textColor: Colors.white,
                                child: Text(
                                  'Save Profile',
                                  style: TextStyle(fontSize: 18.0),
                                ),
                              ),
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> uploadImage(File imageFile) async {
    final storageRef = FirebaseStorage.instance.ref();
    String name = path.basename(imageFile.path);
    StorageUploadTask uploadTask =
        storageRef.child('images/users/user_$name.jpg').putFile(imageFile);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }
}
