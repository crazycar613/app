import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:newmap2/MainPage/Index.dart';
import 'package:newmap2/Models/User.dart';
import 'package:newmap2/Models/ItemInCart.dart';
import 'package:newmap2/Models/DbStockAndCount.dart';
import 'package:newmap2/Models/TotalOrder.dart';
import 'package:newmap2/Models/Coupon.dart';
import 'package:newmap2/ShoppingCart/payment.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:newmap2/ShoppingCart/POrder.dart';
import '../ChangeLanguage/app_translations.dart';



class Checkout extends StatefulWidget {
  String userID;
  double totalAmt;

  Checkout(this.userID, this.totalAmt);

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  // Declare this variable
  DatabaseReference reference = FirebaseDatabase.instance.reference();
  bool isShipmentCheck;
  bool isPaymentCheck;
  bool isusePoint = false;
  User user;
  String btnWord = "Check out";
  String deliveryAddress = "";
  List<ItemInCart> items = [];
  List<Coupon> coupons = [];
  List<Coupon> userCoupons = [];
  List<TotalOrder> totalOrder =[];
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isPaymentCheck = false;
    isShipmentCheck = false;
    isusePoint = false;

    checkTotalOrder();

    getUser();
    getAllCoupons();
    getCartItem();
    getDataFromSps();
    getUerCoupon();

  }

  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  getDataFromSps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {

      deliveryAddress = (prefs.getString('deliveryAddress'));


    });
  }

  //get user information
  getUser() async {
    reference
        .child("user")
        .child(widget.userID)
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
        print((totalOrder.length + 1).toString() + " hasdas");
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
          //print(cp.toString());
          coupons.add(cp);
        });
      });
    });
  }



  //get all items in cart
  getCartItem() async {
    reference
        .child("user")
        .child(widget.userID)
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
          .child(widget.userID)
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
                    widget.totalAmt > double.parse(c.reqAmount)) {
                  userCoupons.add(c);

                  print(userCoupons.length.toString() +
                      "=======Current LENGTH===========");
                }
              }
            }
          });
        });

      });
    });


  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData;
    queryData = MediaQuery.of(context);
    double phoneWidth = queryData.size.width;
    double phoneHeight = queryData.size.height;
    Color backgroundC = Color(0xFFf7f7f7);
    Color boldTitle = Color(0xFF828181);
print(userCoupons.length);
    return Scaffold(
        backgroundColor: backgroundC,
        appBar: AppBar(backgroundColor: Colors.red, title: Text(AppTranslations.of(context).text("checkOut"))),
        body: SingleChildScrollView(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: phoneHeight / 50,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Shippment",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: boldTitle),
                    ),
                  ],
                ),
                SizedBox(
                  height: phoneHeight / 50,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  height: setContainerHeight(isShipmentCheck, context),
                  width: phoneWidth,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Shipping Address",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RadioListTile(
                        value: false,
                        groupValue: isShipmentCheck,
                        title: Text("Default Address"),
                        onChanged: (bool value) {
                          setState(() {
                            isShipmentCheck = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile(
                        value: true,
                        groupValue: isShipmentCheck,
                        title: Text("Custom Address"),
                        onChanged: (bool value) {
                          print("Radio Tile pressed $value");
                          setState(() {
                            isShipmentCheck = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      Container(
                        width: phoneWidth * 0.9,
                        child: InputAddress(isShipmentCheck, context),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: phoneHeight / 50,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Payment",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: boldTitle),
                    ),
                  ],
                ),
                SizedBox(
                  height: phoneHeight / 50,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  height: setPaymentHeight(isPaymentCheck, context),
                  width: phoneWidth,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Payment",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RadioListTile(
                        value: false,
                        groupValue: isPaymentCheck,
                        title: Text("Cash On Delivery"),
                        onChanged: (bool value) {
                          setState(() {
                            isPaymentCheck = value;
                          });
                        },
                        activeColor: Colors.red,
                      ),
                      RadioListTile(
                        value: true,
                        groupValue: isPaymentCheck,
                        title: Text("Credit Card"),
                        onChanged: (bool value) {
                          print("Radio Tile pressed $value");
                          setState(() {
                            isPaymentCheck = value;

                          });
                        },
                        activeColor: Colors.red,
                      ),
                      Container(
                        width: phoneWidth * 0.9,
                        child: inputPayment(isPaymentCheck, context),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: phoneHeight / 50,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Cart Details",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: boldTitle),
                    ),
                  ],
                ),
                SizedBox(
                  height: phoneHeight / 50,
                ),
                Container(
                  padding: const EdgeInsets.only(left: 10),
                  height: phoneHeight / 2.11,
                  width: phoneWidth,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Cart Items",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        height: 250,
                        child: ListView.builder(
                          itemCount: items.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return cartItem(items[index].partNo,
                                items[index].unitPrice, items[index].img);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: phoneHeight / 50,
                ),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 10,
                    ),
                    Checkbox(
                      value: isusePoint,
                      onChanged: (bool value) {
                        setState(() {
                          isusePoint = value;
                          if(isusePoint){
                            btnWord = "Next Step";
                          }else{
                            btnWord = "Check out";
                          }
                        });
                      },
                      activeColor: Colors.red,
                    ),
                    Text("Use Coupon"),


                  ],
                ),
                SizedBox(
                  height: phoneHeight / 50,
                ),

                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  height: setPointHeight(isusePoint, context),
                  width: phoneWidth,
                  color: Colors.white,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: ListTile(
                              title: new Text("Total"),
                              subtitle: new Text(widget.totalAmt.toStringAsPrecision(4), style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20),),
                            ),
                          ),
                          Expanded(
                              child: new MaterialButton(
                            onPressed: () {
                              if(isusePoint == true){
                                if(userCoupons.length > 0){
                                  Navigator.of(context).push(new MaterialPageRoute(
                                      builder: (BuildContext context) => PaymentPage(user,
                                          items,
                                          coupons,
                                          userCoupons,
                                          widget.totalAmt,
                                          widget.totalAmt,
                                          isPaymentCheck,
                                          isShipmentCheck,
                                          deliveryAddress,
                                          myController.text
                                      )));
                                }
                                else{
                                  showDialog<void>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("You don't have avalible coupon ! ",style: TextStyle(fontSize: 16),),
                                        content: const Text('Please try again ',style: TextStyle(fontSize: 16),),
                                        actions: <Widget>[
                                          FlatButton(
                                            child: Text('Ok'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              } else{
                                  // leave it to you
                                //checkOutMethod();
                                //PlaceOrder(isPaymentCheck, isShipmentCheck, widget.userID, deliveryAddress, myController.text, items, context, widget.totalAmt);
                                final pOrder = POrder(isPaymentCheck,
                                    isShipmentCheck,
                                    widget.userID,
                                    deliveryAddress,
                                    myController.text,
                                    items,
                                    context,
                                    widget.totalAmt,
                                    totalOrder.length,
                                    userCoupons,
                                    0,
                                    false
                                );
                                pOrder.checkOutMethod();


                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (BuildContext context) =>Index()
                                ));
                              }

                            },
                            child: new Text(
                              btnWord,
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.red,
                          )),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget InputAddress(bool ischeck, BuildContext context) {
    double widthBox = MediaQuery.of(context).size.width;
    if (ischeck) {
      return Container(
        margin: const EdgeInsets.only(left: 10),
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(color: Colors.red, width: 1.0),
        ),
        padding: const EdgeInsets.only(left: 10),
        child: TextField(
          controller: myController,
          keyboardType: TextInputType.multiline,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "輸入地址",
            border: InputBorder.none,
          ),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.only(left: 10),
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(color: Colors.red, width: 1.0),
        ),
        padding: const EdgeInsets.all(10),
        child: Text(deliveryAddress),
      );
    }
  }

  Widget inputPayment(bool ischeck, BuildContext context) {
    double widthBox = MediaQuery.of(context).size.width;
    if (ischeck) {
      return Container(
        margin: const EdgeInsets.only(left: 10),
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(color: Colors.red, width: 1.0),
        ),
        padding: const EdgeInsets.only(left: 10),
        child: TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter.digitsOnly
            ],
            decoration: InputDecoration(
              hintText: "信用卡號碼",
              icon: Icon(Icons.credit_card),
              border: InputBorder.none,
            )),
      );
    } else {
      return Container();
    }
  }

  double setContainerHeight(bool isCheck, BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    if (isCheck)
      return height / 2;
    else
      return height / 3;
  }

  double setPaymentHeight(bool isCheck, BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    if (isCheck)
      return height / 3;
    else
      return height / 4.05;
  }

  double setPointHeight(bool isCheck, BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    if (isCheck)
      return height / 3.2;
    else
      return height / 4.3;
  }

  Container cartItem(String title, double price, String img) {
    return Container(
      width: 140.0,
      child: new InkWell(
        child: Card(
          color: Color(0xFFe7e7e7),
          child: Wrap(

            children: <Widget>[
              Image.network(img),
              ListTile(
                title: Text("\$"+price.toString(),
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.red,
                      fontWeight: FontWeight.bold
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField PointInput(bool isCheck, BuildContext context) {
    double widthBox = MediaQuery.of(context).size.width;
    if (isCheck) {
      return TextFormField(
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            WhitelistingTextInputFormatter.digitsOnly
          ],
          decoration: InputDecoration(
              hintText: "輸入零用錢", icon: Icon(Icons.monetization_on)));
    } else
      return null;
  }

  Container CouponInput(bool isCheck, BuildContext context, items) {
    if(isCheck){
      return Container(
        child: PageView.builder(

          itemCount: items.length,
          itemBuilder: (context, index){
            return Image.network(items[index].img);
          },
        ),
      );
    }
    else return null;
  }




}
