import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:newmap2/Coupon/page/Detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ChangeLanguage/app_translations.dart';
import '../../Overlay/mydrawer.dart';
import 'Coupons.dart';

class PageOne extends StatefulWidget{
  PageOneState createState() => PageOneState();
}

class PageOneState extends State<PageOne>{
  int currentPage = 0;
  PageController _pageController;
  List<Coupons> couponsInfo = [];
  SharedPreferences prefs;
  String userID = "";
  String points = "";
  List<UserCoupon> _userCouponList = [];
  UserPoint up;

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = prefs.getString('id');
      points = prefs.getString('points');
      getUserCoupon(userID);
      getUserDetail(userID);
      print("This is readLocal() : "+userID);
    });
  }

  void initState(){
    super.initState();
    _pageController = PageController(
        initialPage: currentPage,
        keepPage: false,
        viewportFraction: 0.8
    );
    getAllCoupon();
    readLocal();
  }

  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }

  Future<Null> getUserCoupon(id) async{
    _userCouponList.clear();
    DatabaseReference ref = FirebaseDatabase.instance.reference().child("user/"+userID+"/coupon");
    ref.once().then((DataSnapshot snapshot){
      Map<dynamic,dynamic> values = snapshot.value;
      setState(() {
        values.forEach((key,values)async{
          UserCoupon uc = new UserCoupon(
              values['ExpiryDate'],
              values['couponNo'],
              values['isUse']
          );
          _userCouponList.add(uc);
        });
        print(_userCouponList);
      });
    });
  }

  Future<Null> getUserDetail(id) async{
    DatabaseReference ref = FirebaseDatabase.instance.reference().child("user/"+userID);
    ref.once().then((DataSnapshot snapshot){
      Map<dynamic,dynamic> values = snapshot.value;
      setState(() {
        up = new UserPoint(
            values['userID'],
            values['points']
        );
      });
    });
  }

  Future<Null> getAllCoupon() async{
    DatabaseReference ref = FirebaseDatabase.instance.reference().child("Coupon");
    ref.once().then((DataSnapshot snapshot){
      Map<dynamic,dynamic> values = snapshot.value;
      setState(() {
        for(var indKey in values.keys){
          Coupons cps = new Coupons(
              values[indKey]["couponNo"],
              values[indKey]["couponName"],
              values[indKey]["description"],
              values[indKey]["url"],
              values[indKey]["type"],
              values[indKey]["expirydays"],
              values[indKey]["value"],
              values[indKey]["reqAmount"]
          );
          couponsInfo.add(cps);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            color: Colors.white, //color: colorList[currentPage],
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                height: 220,
                child: couponsInfo.length == 0? Center(child: CircularProgressIndicator()):PageView.builder(
                  itemBuilder: (context, index){
                    return itemBuilder(index);
                  },
                  controller: _pageController,
                  pageSnapping: false,
                  onPageChanged: _onPageChanged,
                  itemCount: couponsInfo.length,
                  physics: ClampingScrollPhysics(),
                ),
              ),
              couponsInfo.length == 0? Center(child: CircularProgressIndicator()):Text((currentPage + 1).toString() + " / " + couponsInfo.length.toString()),

              couponsInfo.length == 0? Center(child: CircularProgressIndicator()):_detailsBuilder(currentPage),
            ],
          ),
        ],

      ),
    );
  }

  Widget _detailsBuilder(index){
    final detailsList = [
      {
        "title": AppTranslations.of(context).text("title1"),
        "description" : AppTranslations.of(context).text("description1")
      },
      {
        "title" : AppTranslations.of(context).text("title2"),
        "description" : AppTranslations.of(context).text("description2")
      },
    ];

    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child){

        double value =1;
        if(_pageController.position.haveDimensions) {
          value = _pageController.page - index;
          value = (1 - value.abs() * 0.5).clamp(0.0, 1.0);
        }

        return Expanded(
          child: Transform.translate(
            offset: Offset(0, 500 + (-value * 500)),
            child: Opacity(
              opacity: value,
              child: Container(
                padding: EdgeInsets.only(left: 25.0, right: 25.0, top: 20.0),
                child: Column(
                  children: <Widget>[
                    Text(couponsInfo[index].couponName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700) ,  ),
                    SizedBox(height: 18,),
                    Container(
                      width: 270,
                      height: 5,
                      color: Colors.black,
                    ),

                    Container(
                      width: 270,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Available Period : ",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 15)),
                          Text(couponsInfo[index].expiryDays+" days",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                        ],
                      ),
                    ),

                    Container(

                      width: 270,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Redeem Points : ",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 15)),
                          Text(couponsInfo[index].value+" point(s)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                        ],
                      ),
                    ),

                    Container(

                      width: 270,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text("Required Amount : ",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 15)),
                          Text("\$ "+couponsInfo[index].reqAmount, style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                        ],
                      ),
                    ),


                    SizedBox(height: 20,),
                    Container(
                      width: 270,
                      height: 5,
                      color: Colors.black,
                    ),
                    SizedBox(height: 5,),
                    (checkIsExists(couponsInfo[index].couponNo) == true)
                        ? RaisedButton(
                      onPressed: (){
                        int userPoint = int.parse(up.points);
                        int coupointPoint = int.parse(couponsInfo[index].value);
                        if(userPoint < coupointPoint){
                          _notEnougthDialog();
                        }else{
                          _confirmDialog(
                              couponsInfo[index].value,
                              couponsInfo[index].couponNo,
                              couponsInfo[index].expiryDays,
                              userID,
                              up.points
                          );
                        }
                      },
                      child: Text(
                          "Redeem"
                      ),
                    )
                        : RaisedButton(
                      onPressed: null,
                      child: Text(
                        "Already Redeem",
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool checkIsExists(couponID){
    bool isExists = false;
    var currentDate = DateTime.now();
    for(int i=0; i< _userCouponList.length;i++){
      if(_userCouponList[i].couponNo == couponID){
        //Check Is use
        DateTime dateTime = DateTime.parse(_userCouponList[i].expiryDate);
        if(_userCouponList[i].isUse == "true" || currentDate.isAfter(dateTime)){
          isExists = true;
        }
      }
    }
    return isExists;
  }

  Future<void> _notEnougthDialog() async{
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("No enougth point to redeem"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("Please check again your points!!!")
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('No'),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
    );
  }

  Future<void> _confirmDialog(couponPoints,couponID,days,userID,point) async{
    int validDate = int.parse(days);
    var ExpiryDay = (new DateTime.now()).add(new Duration(days: validDate));
    String formattedDate = DateFormat('yyyy-MM-dd').format(ExpiryDay);

    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Are you sure this transaction"),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text("The coupon will cannot be used in "+ formattedDate),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Yes'),
                onPressed: (){
                  redeemCouponsToFirebase(couponPoints,couponID,formattedDate,userID,point);
                  setState(() {
                    getUserCoupon(userID);
                  });
                  Navigator.of(context).pop();
                },
              ),

              FlatButton(
                child: Text('No'),
                onPressed: (){
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        }
    );
  }

  void redeemCouponsToFirebase(couponPoints,couponID,couponDate,userID,userPoints){
    final databaseReference = FirebaseDatabase.instance.reference();
    //Add to user table
    databaseReference.child("user/"+userID+"/coupon/"+couponID).set({
      "ExpiryDate":couponDate,
      "couponNo":couponID,
      "isUse":"false"
    });

    //transaction record
    var currentDate = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
    String recordID = DateTime.now().millisecondsSinceEpoch.toString();

    databaseReference.child("user/"+userID+"/pointRecord/"+recordID).update({
      "date": formattedDate,
      "point":"-"+couponPoints,
      "description":"Buy coupon:"+couponID
    });

    //Update user points
    int pointsOfUser = int.parse(userPoints);
    int pointsOfCoupon = int.parse(couponPoints);
    int resultPoints = pointsOfUser - pointsOfCoupon;
    databaseReference.child("user/"+userID).update({
      "points":resultPoints.toString()
    });
    setState(() {
      prefs.setString('points', resultPoints.toString());
      getUserDetail(userID);
    });

  }


  Widget itemBuilder(index){
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child){
        double value =1;
        if(_pageController.position.haveDimensions){
          value = _pageController.page - index;
          value = (1 - value.abs() * 0.5).clamp(0.0, 1.0);

          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(left: 30.0, right: 20, bottom: 10.0, top: 20),
              height: Curves.easeIn.transform(value) * 200, //change my height
              child: child,
            ),
          );
        }else{
          return Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(left: 23.0, right: 20, bottom: 10.0, top: 20),
              height: Curves.easeIn.transform(index == 0 ? value : value*0.8) * 200, //change my height
              child: child,
            ),
          );
        }

      },


      child: Material(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0, top: 10),

          child: Image.network(
            couponsInfo[index].url,
            fit: BoxFit.fill,
          ),
        ),
      ),

    );
  }

  _onPageChanged(int index){
    setState(() {
      currentPage = index;
    });
  }
}

class UserCoupon{
  String expiryDate, couponNo,isUse;
  UserCoupon(expiryDate, couponNo,isUse){
    this.expiryDate = expiryDate;
    this.couponNo = couponNo;
    this.isUse = isUse;
  }
}

class UserPoint{
  String ID, points;
  UserPoint(ID,points){
    this.ID = ID;
    this.points = points;
  }
}