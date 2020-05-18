import 'package:badges/badges.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:newmap2/Models/Part.dart';

import 'package:flutter/material.dart';
import 'package:newmap2/ShoppingCart/CartList.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetail extends StatefulWidget {
  final Part p;
  final bool isInCart;

  ProductDetail({this.p, this.isInCart});

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  int _itemCount = 0;
  final _controller = TextEditingController();
  var dbHelper;
  String userID;
  bool isNew = false;
  bool isExist = false;
  SharedPreferences prefs;
  DatabaseReference ref = FirebaseDatabase.instance.reference();



  @override
  void initState() {
    super.initState();
    _controller.text = "$_itemCount";
    getUserID();
  }

  getUserID() async{
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('id');
    });

  }
  void saveToFireBase(userID, Part p){
    ref.child("user").child(userID).child("shoppingCart").child(p.partNo).set({
      "partNo" : p.partNo,
      "buyQty" : _itemCount,
      "unitPrice" : p.price,
      "totalPrice" : p.price*_itemCount,
      "type" : p.type,
      "img" : p.img
    });
  }

  checkExistInFireBase(userID,Part p){
    ref.child("user").child(userID).child("shoppingCart").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> values = snapshot.value;
      setState(() {
        values.forEach((key, values) async {
          if(key == p.partNo){
            isExist = true;

          }
          else{
            isExist = false;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.p.partNo, style: TextStyle(fontSize: 20.0)),
        actions: <Widget>[
          Badge(
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              color: Colors.white,
              onPressed: () {
                setState(() {
                  isNew = false;
                });
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => CartList()));
              },
            ),
            badgeContent: Text("",style: TextStyle(fontSize: 10),),
            badgeColor: Colors.blueAccent,
            showBadge: isNew,
            position: BadgePosition.topRight(top: 0, right: 3),
          )
        ],
      ),
      body: new ListView(
        children: <Widget>[
          Card(
            child: Container(
              width: width,
              height: height / 100 * 40,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(widget.p.img), fit: BoxFit.contain),
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.only(left: 4, right: 4, top: 0, bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, top: 10.0, right: 0.0, bottom: 10.0),
                  child: new Text(
                    "Quantity",
                    style:
                    TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  ),
                ),
                new IconButton(
                  icon: new Icon(Icons.remove),
                  onPressed: () {
                    setState(() {
                      if (_itemCount > 0) {
                        _itemCount--;
                      }
                    });
                  },
                ),
                new Container(
                  width: 20,
                  child: TextField(
                    textAlign: TextAlign.center,
                    controller: new TextEditingController.fromValue(
                        new TextEditingValue(
                            text: "$_itemCount",
                            selection: new TextSelection.collapsed(
                                offset: "$_itemCount".length))),
                    keyboardType: TextInputType.number,
                    onChanged: (text) {
                      _itemCount = int.parse(text);
                    },
                    decoration: new InputDecoration(border: InputBorder.none),
                  ),
                ),
                new IconButton(
                    icon: new Icon(Icons.add),
                    onPressed: () => setState(() => _itemCount++)),
                new ButtonTheme(
                  minWidth: 10,
                  height: 49,
                  child: FlatButton(
                    child: Text("Add"),
                    color: Colors.red,
                    textColor: Colors.white,
                    onPressed: () {
                      checkExistInFireBase(userID, widget.p);
                      if (_itemCount <= 0) {
                        showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Warning!!"),
                                content: Text(
                                  "Invalid Amout!",
                                  style: TextStyle(fontSize: 19),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            });
                      } else if (isExist) {
                        showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Warning!!"),
                                content: Text(
                                  "You have already add this item in cart",
                                  style: TextStyle(fontSize: 19),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              );
                            });
                      } else {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Add ' +
                                    _itemCount.toString() +
                                    " into cart"),
                                content: Text(
                                  "Are you sure?",
                                  style: TextStyle(fontSize: 19),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text('No'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  FlatButton(
                                      child: Text('Yes'),
                                      onPressed: () {

                                        saveToFireBase(userID,  widget.p);
                                        Navigator.pop(context);
                                      }),
                                ],
                              );
                            });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          new ProductBox(
            p: widget.p,
          ),
        ],
      ),
    );
  }
}

class ProductBox extends StatelessWidget {
  final Part p;

  ProductBox({this.p});

  final int _itemCount = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return new Container(
      padding: new EdgeInsets.all(10.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(left: 0, top: 3, bottom: 10),
                  child: new Text(
                    p.partNo.toString(),
                    style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.red,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(
                  color: Colors.black,
                  thickness: 2,
                ),
                Container(
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Price: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15)),
                      Text(p.price.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                Container(
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Type: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15)),
                      Text(p.type.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                Container(
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("Model: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 15)),
                      SizedBox(
                        child: AutoSizeText(
                          p.model.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                          minFontSize: 0,
                          stepGranularity: 0.1,
                          maxLines: 2,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
