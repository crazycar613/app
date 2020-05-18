import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:newmap2/MainPage/Index.dart';
import 'package:newmap2/Models/TotalOrder.dart';
import 'package:newmap2/Models/User.dart';
import 'package:newmap2/Models/ItemInCart.dart';
import 'package:newmap2/Models/Coupon.dart';

import 'POrder.dart';

class PaymentPage extends StatefulWidget {
  User u;
  List<ItemInCart> items = [];
  List<Coupon> coupons = [];
  List<Coupon> userCoupons = [];
  double totalAmt,finalTotalAmount;
  bool isPaymentCheck, isShipmentCheck;
  String deliveryAddress, myController;

  PaymentPage(this.u,
      this.items,
      this.coupons,
      this.userCoupons,
      this.totalAmt,
      this.finalTotalAmount,
      this.isPaymentCheck,
      this.isShipmentCheck,
      this.deliveryAddress,
      this.myController);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int currentPage = 0;
  PageController _pageController;
  DatabaseReference reference = FirebaseDatabase.instance.reference();
  User user;
  List<ItemInCart> items = [];
  List<Coupon> coupons = [];
  List<Coupon> userCoupons = [];
  List<TotalOrder> totalOrder =[];


  @override
  void initState() {
    super.initState();

    _pageController = PageController(
        initialPage: currentPage,
        keepPage: false,
        viewportFraction: 0.8
    );

    checkTotalOrder();
    getUser();
    getAllCoupons();
    getCartItem();
    getUerCoupon();

    user = widget.u;

  }

  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }

  _onPageChanged(int index){
    setState(() {
      currentPage = index;
    });
  }
  //get user information
  getUser() async {
    reference
        .child("user")
        .child(widget.u.userID)
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      setState(() {
        user = new User(
          values['userID'],
          values['password'],
          values['name'],
          values['companyName'],
          values['companyAddress'],
          values['deliveryAddress'],
        );
      });
    });
  }

  void checkTotalOrder(){
    reference.child("Order").once().then((DataSnapshot ss){
      Map<dynamic, dynamic>d = ss.value;
      totalOrder.clear();
      for(var indkey in d.keys){
        TotalOrder to = TotalOrder(d[indkey]["orderNo"]);
        totalOrder.add(to);
      }
      setState(() {
        //print((totalOrder.length + 1).toString() + " hasdas");
      });
    });
  }

  // get all coupons information
  Future<Null> getAllCoupons() async {
    reference.child("Coupon").once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      setState(() {
        values.forEach((key, values) async {
          Coupon cp = new Coupon(
              values["couponNo"],
              values["couponName"],
              values["description"],
              values["disAmount"],
              values["expirydays"],
              values["reqAmount"],
              values["type"],
              values["url"],
              values["value"]);
          print(cp.toString());
          coupons.add(cp);
        });
      });
    });
  }


  //get all items in cart
  Future<Null> getCartItem() async {
    reference
        .child("user")
        .child(widget.u.userID)
        .child("shoppingCart")
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      items.clear();
      setState(() {
        values.forEach((key, value) {
          ItemInCart ci = new ItemInCart(
            value['partNo'],
            value['buyQty'],
            value['img'],
            value['unitPrice'],
            value['totalPrice'],
            value['type'],
          );
          items.add(ci);
        });
      });
    });
  }


  //get full information of the coupon that user can be user
  Future<Null> getUerCoupon() async {
    List<Coupon> localcoupons = [];

    reference.child("Coupon").once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      localcoupons.clear();
      values.forEach((key, values) async {
        Coupon cp = new Coupon(
            values["couponNo"],
            values["couponName"],
            values["description"],
            values["disAmount"],
            values["expirydays"],
            values["reqAmount"],
            values["type"],
            values["url"],
            values["value"]);

        localcoupons.add(cp);
        print(localcoupons.length);
      });
      reference
          .child("user")
          .child(widget.u.userID)
          .child("coupon")
          .once()
          .then((DataSnapshot snapshot) {
        Map<dynamic, dynamic> values = snapshot.value;
        var currentDate = DateTime.now();
        var newFormat = DateFormat("yyyy-MM-dd");
        String updatedDt = newFormat.format(currentDate);

        setState(() {
          values.forEach((key, value) {
            DateTime dateTime =  DateTime.parse(value['ExpiryDate']);
            if(value['isUse'] == "false") {
              for (Coupon c in localcoupons) {
                if (value['couponNo'] == c.couponNo &&
                    currentDate.isAfter(dateTime) == false &&
                    widget.finalTotalAmount > double.parse(c.reqAmount)) {
                  userCoupons.add(c);

                  print(userCoupons.length.toString() +
                      "=======Current LENGTH===========");
                }
              }
            }
          });


            if(userCoupons[0].type == "actualAmount"){
              widget.totalAmt = widget.finalTotalAmount - double.parse(userCoupons[0].disAmount);
            }
            else{
              double dis=   double.parse(userCoupons[0].disAmount);
              widget.totalAmt =  widget.finalTotalAmount * dis ;

            }


        });

      });
    });


  }



  @override
  Widget build(BuildContext context) {
    double wid = MediaQuery.of(context).size.width;
    double hei = MediaQuery.of(context).size.height;


    Widget checkType(String type,String disAmount, BuildContext context) {
        if(type == "actualAmount"){
            return Container(
              child: Padding(padding: const EdgeInsets.only(left: 30.0,top: 20.0,right: 0.0,bottom: 0.0),
                  child: new Text("Required Amount :  \$ " + disAmount + " OFF",textAlign: TextAlign.left, style: TextStyle(fontSize: 16.0))),
            );
        }
        else{
          double dis =  1 - double.parse(disAmount);
          dis *= 100;
          return Container(
            child: Padding(padding: const EdgeInsets.only(left: 30.0,top: 20.0,right: 0.0,bottom: 0.0),
                child: new Text("Required Amount :  " + dis.toStringAsPrecision(2)+ " % OFF",textAlign: TextAlign.left, style: TextStyle(fontSize: 16.0))),
          );
        }
    }

    print(userCoupons.length.toString()+"----------------------LEngth check-----------------------------");
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red, title: Text("Select Coupon")),
      body: Column(
        children: [

          Center(
            child: Text("Avaliable Coupon：",style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold)),
          ),

          Divider(
            height: 10,
            color: Colors.black,
            thickness: 2,
            indent: 15,
            endIndent: 15,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 0.0),
            height: hei*0.6,

            child: PageView.builder(
              itemCount: userCoupons.length,
              controller: _pageController,

              onPageChanged: (num){
                setState(() {
                  currentPage = num;
                  widget.totalAmt = widget.finalTotalAmount;
                  if(userCoupons[num].type == "actualAmount"){
                    widget.totalAmt = widget.finalTotalAmount - double.parse(userCoupons[num].disAmount);
                  }
                  else{
                    double dis =  double.parse(userCoupons[num].disAmount);
                    widget.totalAmt =  widget.finalTotalAmount * dis ;
                  }
//                  print("widget.totalAmt : " + widget.totalAmt.toString());
//                  print("widget.finalTotalAmount : " + widget.finalTotalAmount.toString());
                });
              },
              itemBuilder: (context, index){
                return ListView(
                    children: <Widget>[
                        new Container(
                          margin: EdgeInsets.only(right: 20, left: 30),
                          padding: EdgeInsets.all(10),
                          height: hei*0.3,
                          width: 350,

                          decoration: BoxDecoration(

                            image: new DecorationImage(
                                image: new NetworkImage(userCoupons[index].url)
                            ),

                            borderRadius: BorderRadius.all(Radius.circular(5)),

                          ),

                ),
                      Divider(
                        height: 10,
                        color: Colors.black,
                        thickness: 2,
                        indent: 1,
                        endIndent: 1,
                      ),
                      new Container(
                        child: Padding(padding: const EdgeInsets.only(left: 30.0,top: 20.0,right: 0.0,bottom: 0.0),
                            child: new Text("Coupon Name : " + userCoupons[index].couponName,textAlign: TextAlign.left, style: TextStyle(fontSize: 16.0))),
                      ),
                      checkType(userCoupons[index].type,userCoupons[index].disAmount,context),

                      new Container(
                        child: Padding(padding: const EdgeInsets.only(left: 30.0,top: 20.0,right: 0.0,bottom: 0.0),
                            child: new Text("Required Amount :  \$ " + userCoupons[index].reqAmount,textAlign: TextAlign.left, style: TextStyle(fontSize: 16.0))),
                      ),

             ]);


              },
            ),

          ),

        ],
      ),
      bottomNavigationBar:  Row(
        children: <Widget>[
          Expanded(
            child: ListTile(
              title: new Text("Total"),
              subtitle: new Text(
                widget.totalAmt.toStringAsPrecision(4),
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
            ),
          ),
          Expanded(
              child: new MaterialButton(
                onPressed: () {
                  //print(userCoupons[index].disAmount);
                  print((userCoupons[currentPage].couponNo ).toString());
                  print(widget.totalAmt.toString());
                  print(user.userID);
                  final pOrder = POrder(widget.isPaymentCheck,
                      widget.isShipmentCheck,
                      user.userID,
                      widget.deliveryAddress,
                      widget.myController,
                      items,
                      context,
                      widget.totalAmt,
                      totalOrder.length,
                      userCoupons,
                      currentPage,
                      true
                  );
                  pOrder.checkOutMethod();

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) =>Index()
                  ));
                },
                child: new Text(
                  "Place Order",
                  style: TextStyle(color: Colors.white),
                ),
                color: Colors.red,
              )),
        ],
      ),
    );
  }
}
