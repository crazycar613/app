import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:newmap2/Enquiry/ChatRoom.dart';
import 'package:newmap2/Enquiry/Enquiry.dart';
import 'package:newmap2/Enquiry/Enquiry_List.dart';
import 'package:newmap2/OrderList/newOrderList.dart';
import 'package:newmap2/Profile/CouponList.dart';
import 'package:newmap2/Models/PointHistory.dart';
import 'package:newmap2/Profile/edit_profile.dart';
import '../ChangeLanguage/app_translations.dart';
import 'package:firebase_database/firebase_database.dart';


final startColor = Color(0xffd7c6ae);
final endColor = Color(0xFFd6d3d0);
final titleColor = Color(0xff444444);
final textColor = Color(0xFF583128);
final shadowColor = Color(0xffe9e9f4);
final cardColor = Color(0xFFbd3949);
final endCardColor = Color(0xffdedaaa);
final centerCardColor = Color(0xffdb4b5e);
final card = Color(0xFFbd3949);

final _list1 = List<String>.generate(100, (i) => "零用錢交易記錄 : ");

class MyHomePage extends StatefulWidget {

  final String userID , companyAddress , companyName, username,position,contactNumber,points,deliveryAddress,icon;
  MyHomePage({Key key,this.userID,this.companyAddress,this.companyName,this.contactNumber,this.points,this.position,this.username,this.deliveryAddress,this.icon}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<PointHistory> records= [];

  DatabaseReference reference = FirebaseDatabase.instance.reference();



  @override
  Widget build(BuildContext context) {



    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Widget fourButtonsSection = new Container(
      margin: const EdgeInsets.only(top: 5),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[

          Column(
            children: <Widget>[
              new IconButton(
                onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => AvailableCoupon(widget.userID)));},
                icon: Icon(Icons.style),
                color: Colors.black,
              ),
              new Container(
                child: new Text(
                  AppTranslations.of(context).text("myCoupon"),
                  style: new TextStyle(
                      fontSize: 10.0, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              )
            ],
          ),
          Column(
            children: <Widget>[
              new IconButton(
                onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) =>  EnquiryList()));},
                icon: Icon(Icons.question_answer),
                color: Colors.black,
              ),
              new Container(
                child: new Text(
                  AppTranslations.of(context).text("EnquiryHis"),
                  style: new TextStyle(
                      fontSize: 10.0, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              )
            ],
          ),
          Column(
            children: <Widget>[
              new IconButton(
                onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => Enquriy()));},
                icon: Icon(Icons.chat_bubble),
                color: Colors.black,
              ),
              new Container(
                child: new Text(
                  AppTranslations.of(context).text("enquiry"),
                  style: new TextStyle(
                      fontSize: 10.0, fontWeight: FontWeight.w600, color: Colors.black),
                ),
              )
            ],
          ),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(AppTranslations.of(context).text("back")),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditProfileScreen(userID: widget.userID, companyAddress:widget.companyAddress,companyName:widget.companyName,
                      contactNumber:widget.contactNumber,points:widget.points,position:widget.position,username:widget.username,deliveryAddress:widget.deliveryAddress,icon:widget.icon),));
            },
          )
        ],
      ),
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.person),
                  Text(
                    AppTranslations.of(context).text("Customer"),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              ),

              CardHolder(userID: widget.userID, companyAddress:widget.companyAddress,companyName:widget.companyName,
                  contactNumber:widget.contactNumber,points:widget.points,position:widget.position,username:widget.username,deliveryAddress:widget.deliveryAddress,icon:widget.icon),
              fourButtonsSection,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ButtonTheme(
                    minWidth: width - 30.0,
                    child: RaisedButton(
                      onPressed: () {

                      },
                      color: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          bottomLeft: Radius.circular(5.0),
                          topRight: Radius.circular(5.0),
                          bottomRight: Radius.circular(5.0),
                        ),
                      ),
                      textColor: Color(0xFFFFFFFF),
                      child: Row(
                        children: <Widget>[
                          Text(
                            AppTranslations.of(context).text("point_his"),
                            style: new TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 200,
                width: 400,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    boxShadow: [
                      BoxShadow(
                          color: titleColor.withOpacity(.1),
                          blurRadius: 20,
                          spreadRadius: 10),
                    ]),
                child: FutureBuilder(
                  future: reference.child('user').child(widget.userID).child('pointRecord').once(),
                  builder: (context, AsyncSnapshot<DataSnapshot> snapshot){
                    records.clear();
                    if(snapshot.hasData){
                      Map<dynamic, dynamic> values = snapshot.data.value;
                      values.forEach((key, value) {

                        PointHistory rec = new PointHistory(value['point'], value['date'], value['description']);
                        records.add(rec);
                      });
                      return ListView.separated(
                        separatorBuilder: (context, index) => Divider(
                          color: Colors.black,
                          height: 1,
                          thickness: 1.1,
                        ),
                        itemCount: records.length,
                        itemBuilder: (BuildContext context, int index){
                          return Container(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          children: [
                                            Icon(Icons.credit_card),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              records[index].desc,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold, color: Colors.black),
                                              textAlign: TextAlign.justify,
                                            ),
                                          ],
                                        ),
                                      ),

                                      Text(
                                        records[index].point,
                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                        textAlign: TextAlign.right,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 33,
                                      ),
                                      Text(
                                        records[index].date,
                                        style: TextStyle(
                                            color: titleColor, fontStyle: FontStyle.italic),
                                      )
                                    ],
                                  )
                                ],
                              ));
                        },

                      );
                    }
                    return CircularProgressIndicator();
                  },
                ),
                padding: EdgeInsets.only(left: 20, right: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CardHolder extends StatelessWidget {

  const CardHolder({
    Key key,@required this.userID,this.companyAddress,this.companyName,this.contactNumber,this.points,this.position,this.username,this.deliveryAddress,this.icon
  }) : super(key: key);

  final String userID , companyAddress , companyName, username ,position,contactNumber,points,deliveryAddress,icon;

  @override
  Widget build(BuildContext context) {

    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      front: Container(
          margin: EdgeInsets.only(right: 20, left: 20),
          height: 180,
          width: 400,
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.all(Radius.circular(5)),
              boxShadow: [
                BoxShadow(
                    color: titleColor.withOpacity(.3),
                    blurRadius: 20,
                    spreadRadius: 10),
              ]),
          child: new Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new CircleAvatar(
                      radius: 40.0,
                      backgroundImage: NetworkImage(
                          icon),
                    ),
                    new SizedBox(
                      width: 10,
                    ),
                    new Text(
                      username,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    )
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(
                      "Points : \$$points",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text(
                      "User ID: $userID",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          )),
      back: Container(
        margin: EdgeInsets.only(right: 20, left: 20),
        padding: EdgeInsets.all(10),
        height: 180,
        width: 400,
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: [
              BoxShadow(
                  color: titleColor.withOpacity(.3),
                  blurRadius: 20,
                  spreadRadius: 10),
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Company: $companyName", style: TextStyle(color: Colors.white)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Position: $position", style: TextStyle(color: Colors.white)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Telephone: $contactNumber", style: TextStyle(color: Colors.white)),
              ],
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: <Widget>[
                Text(
                  "Delivery Address: $deliveryAddress",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}