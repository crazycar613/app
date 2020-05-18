import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:newmap2/Login/reveal_progress_button.dart';

import 'dart:async';
import 'loginAnimation.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {


  @override
  Widget build(BuildContext context) {
    return (new WillPopScope(
      onWillPop: () async {
        Future.value(
            false); //return a `Future` with false value so this route cant be popped or closed.
      },
      child: new Scaffold(

          body:  new Container(
              height: MediaQuery.of(context).size.height,
              decoration: new BoxDecoration(
                color: Colors.redAccent,

              ),
              child: new ListView(
                padding: const EdgeInsets.all(0.0),
                children: <Widget>[
                  new Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: <Widget>[
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          new Logo(),
                          Visibility(

                            child: Container(

                                margin:  const EdgeInsets.only(
                                    bottom: 25.0,),
                              decoration: new BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Colors.black,

                                ),
                              ),
                              child: new Container(
                                width: 330,
                                height: 60,
                                child: new Padding(padding:  const EdgeInsets.only(
                                    top: 5.0, right: 5.0, bottom: 2.0, left: 5.0),

                                  child: Row(
                                      children: <Widget>[

                                        Icon(Icons.error_outline, color: Colors.black,),
                                        Text('  User ID / Password incorrent ! ', style: TextStyle(color: Colors.black,fontSize: 18),),

                                      ]),

                                ),



                              ),
                            ),
                            maintainSize: true,
                            maintainAnimation: true,
                            maintainState: true,
                            visible: false,
                          ),
                          new FormContainerx(),

                        ],
                      ),

                    ],
                  ),
                ],
              ))),
    ));
  }
}


class Logo extends StatelessWidget {
  @override

  DecorationImage companyLogo = new DecorationImage(
    image: new ExactAssetImage('assets/crown-logo.png'),

  );

  Widget build(BuildContext context) {
    return (new Container(
      width: 260.0,
      height: 200.0,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top:20.0),
      decoration: new BoxDecoration(
        image: companyLogo,
      ),
    ));
  }
}

class FormContainerx extends StatefulWidget {
  @override
  _FormContainerxState createState() => _FormContainerxState();
}

class _FormContainerxState extends State<FormContainerx> with TickerProviderStateMixin {
  @override
  String userID, pwd;
  final  userIDController = new TextEditingController();
  final  pwdController = new TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  bool _visible = false;
  DatabaseReference user;
  final FirebaseDatabase db = FirebaseDatabase.instance;
  bool idIsEmpty = true;
  bool pwdIsEmpty = true;
  bool _btnEnabled = false;


  @override void dispose() {
    // Clean up the controller when the widget is disposed.

    userIDController.dispose();
    pwdController.dispose();
    super.dispose();
  }


  Widget build(BuildContext context) {

    return new Container(
      width: 400,
      height:320,
      margin: new EdgeInsets.symmetric(horizontal: 40.0),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(18.0),
        ),
        color:  Colors.white,
      ),

      child: new Column(

        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[

          new Form(
              child: new Column(

                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[



                  new Container(

                    decoration: new BoxDecoration(
                      border: new Border(
                        bottom: new BorderSide(
                          width: 0.5,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    child: new TextFormField(

                      controller: userIDController,
                      obscureText: false,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                      decoration: new InputDecoration(
                        icon: new Icon(
                          Icons.person_outline,
                          color: Colors.red,
                        ),
                        border: InputBorder.none,
                        hintText: "User ID",
                        hintStyle: const TextStyle(color: Colors.red, fontSize: 20.0),
                        contentPadding: const EdgeInsets.only(
                            top: 30.0, right: 30.0, bottom: 30.0, left: 5.0),
                      ),
                    ),
                  ),

                  new Container(
                    margin: EdgeInsets.only(bottom:25),
                    decoration: new BoxDecoration(
                      border: new Border(
                        bottom: new BorderSide(
                          width: 0.5,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    child: new TextFormField(
                      controller: pwdController,
                      obscureText: true,
                      style: const TextStyle(
                        color: Colors.redAccent,
                      ),
                      decoration: new InputDecoration(
                        icon: new Icon(
                          Icons.lock_outline,
                          color: Colors.red,
                        ),
                        border: InputBorder.none,
                        hintText: "Password",
                        hintStyle: const TextStyle(color: Colors.red, fontSize: 20.0),
                        contentPadding: const EdgeInsets.only(
                            top: 30.0, right: 30.0, bottom: 30.0, left: 5.0),
                      ),
                    ),
                  ),
                  new RevealProgressButton(userID: userIDController.text,pwd: pwdController.text,),
                ],
              )
          ),
        ],
      ),
    );
  }
}

