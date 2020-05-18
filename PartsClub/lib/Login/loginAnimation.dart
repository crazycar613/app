import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:newmap2/MainPage/Index.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'CancelAnimation.dart';
import 'LoignWithError.dart';



class ProgressButton extends StatefulWidget {

  final Function callback;
  final String userID;
  final String pwd;

  ProgressButton({Key key,@required this.callback, this.userID, this.pwd});

  @override
  State<StatefulWidget> createState() => _ProgressButtonState();
}

class _ProgressButtonState extends State<ProgressButton>
    with TickerProviderStateMixin {
  bool _isPressed = false,
      _animatingReveal = false;
  int _state = 0;
  double _width = double.infinity;
  Animation _animation;
  GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  DatabaseReference db = FirebaseDatabase.instance.reference();
  DatabaseReference dbx = FirebaseDatabase.instance.reference();


  @override
  void deactivate() {
    reset();
    super.deactivate();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(

        color: Colors.blue,
        elevation: calculateElevation(),
        borderRadius: BorderRadius.circular(25.0),
        child: Container(

          key: _globalKey,
          height: 48.0,
          width: _width,
          child: RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(25.0),

            ),
            padding: EdgeInsets.all(0.0),
            color: _state == 2 ? Colors.green : Colors.redAccent,
            child: buildButtonChild(),
            onPressed: () {},
            onHighlightChanged: (isPressed) {
              setState(() {
                _isPressed = isPressed;
                if (_state == 0) {
                  animateButton();

                }
              });
            },
          ),
        ));
  }

  bool getError(){
    return true;
  }

  void animateButton() {
    double initialWidth = _globalKey.currentContext.size.width;

    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - 48.0) * _animation.value);
        });
      });
    _controller.forward();

    setState(() {
      _state = 1;
    });

    Timer(Duration(milliseconds: 3300), () {
      setState(() {

        db = FirebaseDatabase.instance.reference().child("user");

        dbx = FirebaseDatabase.instance.reference().child("product").child("Brake Disc");



        db.once().then((DataSnapshot snapshot){
          Map<dynamic, dynamic> values = snapshot.value;
          values.forEach((key,values) async{
//            print(values["userID"]);
//            print(widget.userID);
//            print(values["password"]);
//            print(widget.pwd);
            if (widget.userID == values["userID"] && widget.pwd == values["password"]) {
//              Navigator.push(
//                context,
//                MaterialPageRoute(builder: (context) => SecondRoute()),
//              );
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('id', widget.userID );
              prefs.setString('companyAddress', values["companyAddress"] );
              prefs.setString('companyName', values["companyName"] );
              prefs.setString('contactNumber', values["contactNumber"] );
              prefs.setString('points', values["points"] );
              prefs.setString('username', values["name"] );
              prefs.setString('position', values["position"] );
              prefs.setString('deliveryAddress', values["deliveryAddress"] );
              prefs.setString('icon', values["icon"] );


              Navigator.push(context, MaterialPageRoute(builder: (context)=>Index()));
            } else {
              reset();
              Navigator.push(context,
                  NoAnimationMaterialPageRoute(builder: (context) => LoginPageWithError()));

            }

          });

        });

      });
    });

    Timer(Duration(milliseconds: 3600), () {
      _animatingReveal = true;
      widget.callback();
    });
  }

  Widget buildButtonChild() {
    if (_state == 0) {
      return Text(
        'Login',
        style: TextStyle(color: Colors.white, fontSize: 16.0),
      );
    } else if (_state == 1) {
      return SizedBox(
        height: 36.0,
        width: 36.0,
        child: CircularProgressIndicator(
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else {
      return Icon(Icons.check, color: Colors.white);
    }
  }

  double calculateElevation() {
    if (_animatingReveal) {
      return 0.0;
    } else {
      return _isPressed ? 6.0 : 4.0;
    }
  }

  void reset() {
    _width = double.infinity;
    _animatingReveal = false;
    _state = 0;
  }
}