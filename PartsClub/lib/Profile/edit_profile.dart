import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newmap2/MainPage/Index.dart';
import 'package:newmap2/Profile/Profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newmap2/ChangeLanguage/app_translations.dart';
import 'package:firebase_storage/firebase_storage.dart';





final endColor = Color(0xFFd6d3d0);
final textColor = Color(0xFFd41717);

class EditProfileScreen extends StatefulWidget {
  @override
  EditProfileScreenState createState() => new EditProfileScreenState();
  final String userID, companyAddress, companyName, username, position,
      contactNumber, points, deliveryAddress, icon;


  EditProfileScreen(
      {Key key, this.userID, this.companyAddress, this.companyName, this.contactNumber, this.points, this.position, this.username, this.deliveryAddress, this.icon})
      : super(key: key);

}

class EditProfileScreenState extends State<EditProfileScreen> {
  File avatarImageFile, backgroundImageFile;
  String sex;
  String _uploadedFileURL = "https://firebasestorage.googleapis.com/v0/b/inchcape-f3895.appspot.com/o/AdminIcon%2Fdefault-avatar.png?alt=media&token=499a4a26-c082-4bc2-89a8-0401ff055e41";
  DatabaseReference DBRef = FirebaseDatabase.instance.reference();
  FirebaseStorage _storage = FirebaseStorage.instance;
  var dAddressController = new TextEditingController();
  var contactNoController = new TextEditingController();




  Future getImage(bool isAvatar) async {
    File result = await ImagePicker.pickImage(source: ImageSource.gallery);
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
    StorageReference ref = FirebaseStorage.instance.ref().child(
        'UserIcon/' + fileName);
    StorageUploadTask uploadTask = ref.putFile(result);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      setState(() {
        print(downloadUrl);
        _uploadedFileURL = downloadUrl;
      });
    }, onError: (err) {});
    setState(() {
      if (isAvatar) {
        avatarImageFile = result;
      } else {
        backgroundImageFile = result;
      }
    });
  }

  void updateProfile(String deliveryAddress, String contactNumber,
      String _uploadedFileURL) {
    DBRef
      ..child("user").child(widget.userID).update({
        'icon': _uploadedFileURL,
        'deliveryAddress': deliveryAddress,
        'contactNumber': contactNumber
      });
  }

  @override
  void initState() {
    super.initState();
    dAddressController = TextEditingController(text: widget.deliveryAddress);
    contactNoController = TextEditingController(text: widget.contactNumber);
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    timeDilation = 1.0;
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(AppTranslations.of(context).text("back"),),
      ),
      body: new SingleChildScrollView(
        child: new Column(
          children: <Widget>[
            new Container(
              child: new Stack(
                children: <Widget>[
                  // Background
                  (backgroundImageFile == null)
                      ? new Image.asset(
                    'images/bg_uit.jpg',
                    width: double.infinity,
                    height: 150.0,
                    fit: BoxFit.cover,
                  )
                      : new Image.file(
                    backgroundImageFile,
                    width: double.infinity,
                    height: 150.0,
                    fit: BoxFit.cover,
                  ),

                  // Button change background
                  // Avatar and button
                  new Positioned(
                    child: new Stack(
                      children: <Widget>[
                        (avatarImageFile == null)
                            ? new Image.network(
                          widget.icon,
                          width: 70.0,
                          height: 70.0,
                        )
                            : new Material(
                          child: new Image.file(
                            avatarImageFile,
                            width: 70.0,
                            height: 70.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: new BorderRadius.all(
                              new Radius.circular(40.0)),
                        ),

                      ],
                    ),
                    top: 115.0,
                    left: MediaQuery
                        .of(context)
                        .size
                        .width / 2 - 70 / 2,
                  )
                ],
              ),
              width: double.infinity,
              height: 200.0,
            ),
            new Column(
              children: <Widget>[
                // Username
                new Container(
                  margin: EdgeInsets.only(left: width / 2.8),
                  child: RaisedButton(

                    color: Colors.redAccent,
                    child: Text(
                        'Change Icon',
                        style: TextStyle(fontSize: 14, color: Colors.white)
                    ),
                    onPressed: () => getImage(true),
                    padding: new EdgeInsets.all(3.0),
                    highlightColor: Colors.black,

                  ),
                ),

                new Container(

                  child: new Text(
                    AppTranslations.of(context).text("name"),
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: textColor),
                  ),
                  margin:
                  new EdgeInsets.only(left: 10.0, bottom: 5.0, top: 10.0),
                ),
                new Container(
                  child: new Text(widget.username),
                  margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                ),

                // Country
                new Container(
                  child: new Text(
                    AppTranslations.of(context).text("company"),
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: textColor),
                  ),
                  margin:
                  new EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                ),
                new Container(
                  child: new Text(widget.companyName),
                  margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                ),

                // Address
                new Container(
                  child: new Text(
                    AppTranslations.of(context).text("c_address"),
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: textColor),
                  ),
                  margin:
                  new EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                ),
                new Container(
                  child:
                  new Text(widget.companyAddress),
                  margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                ),


                new Container(
                  child: new Text(
                    AppTranslations.of(context).text("d_address"),
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: textColor),
                  ),
                  margin:
                  new EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                ),
                new Container(
                  child: new TextFormField(
                    controller: dAddressController,
                    decoration: new InputDecoration(
                        border: new UnderlineInputBorder(),
                        contentPadding: new EdgeInsets.all(5.0),
                        hintStyle: new TextStyle(color: Colors.grey)),
                  ),
                  margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                ),

                // About me
                new Container(
                  child: new Text(
                    AppTranslations.of(context).text("contact"),
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: textColor),
                  ),
                  margin:
                  new EdgeInsets.only(left: 10.0, top: 30.0, bottom: 5.0),
                ),
                new Container(
                  child: new TextFormField(
                    controller: contactNoController,

                    decoration: new InputDecoration(
                        border: new UnderlineInputBorder(),
                        contentPadding: new EdgeInsets.all(5.0),
                        hintStyle: new TextStyle(color: Colors.grey)),
                  ),
                  margin: new EdgeInsets.only(left: 30.0, right: 30.0),
                ),

                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(20),
                  child: RaisedButton(
                    color: Colors.redAccent,
                    splashColor: Colors.blue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          AppTranslations.of(context).text("submit"),
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    ),
                    onPressed: () async {
                      updateProfile(
                          dAddressController.text, contactNoController.text,
                          _uploadedFileURL);
                      SharedPreferences prefs = await SharedPreferences
                          .getInstance();
                      prefs.setString(
                          'deliveryAddress', dAddressController.text);
                      prefs.setString(
                          'contactNumber', contactNoController.text);
                      prefs.setString('icon', _uploadedFileURL);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) =>
                            CustomDialog(
                              title: "Success",
                              description: "Profile Updated !",
                              buttonText: "OK",
                            ),

                      );
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Index()));
                    },
                  ),
                ),
                // Sex
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            )
          ],
        ),
        padding: new EdgeInsets.only(bottom: 20.0),
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;


  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,

  });

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 20,
            left: 10,
            right: 10,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog

                  },
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}