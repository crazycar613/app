import 'package:flutter/material.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:intl/intl.dart';
import 'package:newmap2/Models/DbStockAndCount.dart';
import 'package:newmap2/Models/OrderLineForReorder.dart';
import 'package:newmap2/Models/TotalOrder.dart';
import 'package:newmap2/OrderList/newOrderList.dart';
import '../ChangeLanguage/app_translations.dart';
import 'package:flip_card/flip_card.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'OrderLines.dart';
import 'TempOrderLines.dart';
import 'ColumnBuilder.dart';

var forPadding = EdgeInsets.only(top:8.0, bottom: 8.0);
var forTextFont = TextStyle(fontSize: 15);

class OrderDetail extends StatefulWidget {
  String orderNo;
  String orderDate;
  String orderStatus;
  String deliveryDate;
  String deliveryAddress;
  String paymentMethod, userID;
  double totalAmount;

  OrderDetail(this.orderNo, this.orderDate, this.orderStatus, this.deliveryDate, this.deliveryAddress, this.paymentMethod, this.totalAmount, this.userID);

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  //var deliverydate;
  String takeOutTheOpen = "";
  String takeOutTheClose = "";
  String withoutAnything = "";
  String theOrderLineKey = "";
  List<OrderLines> orderLines = [];
  List<TempOrderLines> tempOrderLines = [];

  double purchase = 0;
  double coupon = 0;
  double total = 0;



  @override
  void initState(){
    super.initState();
    checkTotalOrder();

    final findOrderKey = FirebaseDatabase.instance.reference().child("Order").orderByChild("orderNo").equalTo(widget.orderNo);
    findOrderKey.once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic>getOrderKey = snapshot.value;
      String theOrderKey = getOrderKey.keys.toString();
      takeOutTheOpen = theOrderKey.split("(")[1];
      takeOutTheClose = takeOutTheOpen.split(")")[0];
      withoutAnything = takeOutTheClose;
      findOrderLineKey(withoutAnything);
    });
    setState(() {

    });
  }

  List<TotalOrder> totalOrder =[];
  DatabaseReference reference = FirebaseDatabase.instance.reference();
  Future<Null> checkTotalOrder() async{
    reference.child("Order").once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      totalOrder.clear();
      setState(() {
        values.forEach((key, values) async {
          TotalOrder to = TotalOrder(values["orderNo"]);
          totalOrder.add(to);
        });
      });

    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void findOrderLineKey(String myKey){
    takeOutTheOpen = "";
    takeOutTheClose = "";

    final findOrderLineKey = FirebaseDatabase.instance.reference().child("OrderLine");
    final dbPart = FirebaseDatabase.instance.reference().child("Parts");
    findOrderLineKey.once().then((DataSnapshot snap){
      Map<dynamic, dynamic>data = snap.value;
      tempOrderLines.clear();
      for(var indKey in data.keys){
        if(widget.orderNo == data[indKey]["orderNo"]){
          TempOrderLines tol = new TempOrderLines(data[indKey]["partNo"], data[indKey]["partStatus"], data[indKey]["qty"]);
          tempOrderLines.add(tol);
        }


      }
      purchase = widget.totalAmount;
      print(purchase.toString() + "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      dbPart.once().then((DataSnapshot shot){
        Map<dynamic, dynamic> getPartType = shot.value;
        orderLines.clear();
        for( var inKey in getPartType.keys){
          for(var i = 0; i < tempOrderLines.length; i++){
            if (getPartType[inKey]["partNo"] == tempOrderLines[i].partNo) {
              OrderLines ol = new OrderLines(getPartType[inKey]["partNo"],
                  getPartType[inKey]["type"],
                  tempOrderLines[i].partStatus,
                  getPartType[inKey]["img"],
                  getPartType[inKey]["price"],
                  tempOrderLines[i].qty);
              orderLines.add(ol);
              if(tempOrderLines[i].partStatus == "Cancelled"){
                purchase -= countPurchase(getPartType[inKey]["price"], tempOrderLines[i].qty);
              }
            }
          }
        }


        setState(() {
          //print("Length1: " + orderLines.length.toString());
        });
      });

    });


  }


  @override
  Widget build(BuildContext context) {


    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red,
        title: Text(AppTranslations.of(context).text("back"),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Re-Order",style: TextStyle(fontSize: 16),),
                    content:  Text("The information remains unchanged",style: TextStyle(fontSize: 16),),
                    actions: <Widget>[
                      FlatButton(
                        child: Text('No, I do not want to'),
                        onPressed: () {

                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text('Yes'),
                        onPressed: () {
                          reorder(widget.orderNo);
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          )
        ],
      ),

      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        //padding: const EdgeInsets.only(top: 18.0, left: 15.0, right: 15.0),
        child: ListView(
          children: <Widget>[
            Center(child: Text(AppTranslations.of(context).text("orderId") + "： #" + widget.orderNo, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,) ,)),
            Container(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Order Information", style: TextStyle( fontSize: 18),),
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
            ),
            Container(
                padding: const EdgeInsets.only(top: 5.0, left: 15.0, right: 15.0, bottom: 7.0),
                child: orderInfo(widget.orderDate, widget.deliveryAddress, widget.orderStatus, widget.deliveryDate, widget.paymentMethod)),
            Container(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Order Summary", style: TextStyle( fontSize: 18),),
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
            ),

            Container(
              child: orderLines.length == 0 ? Center(child: CircularProgressIndicator()): ColumnBuilder(
                itemCount: orderLines.length,
                itemBuilder: (_, index){
                  return orderList(orderLines[index].img,orderLines[index].type, orderLines[index].partNo, orderLines[index].partStatus, orderLines[index].price, orderLines[index].qty);

                },
              ),
            ),
//            orderList("https://thumbs.dreamstime.com/z/new-product-item-store-25048588.jpg", "READFADSADSDSADASDSADSADSADSADAS", "1234-56789", "Delivered", 50, 60),
//            orderList("https://thumbs.dreamstime.com/z/new-product-item-store-25048588.jpg", "READFADSADSDSADASDSADSADSADSADAS", "1234-56789", "Delivered", 50, 60),
//            orderList("https://thumbs.dreamstime.com/z/new-product-item-store-25048588.jpg", "READFADSADSDSADASDSADSADSADSADAS", "1234-56789", "Delivered", 50, 60),
            Container(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("Amount", style: TextStyle( fontSize: 18),),
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Column(
                children: <Widget>[

//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.end,
//                    children: <Widget>[
//                      Text("PURCHASE: HKD\$" + widget.totalAmount.toStringAsFixed(1).toString()),
//                    ],
//                  ),
//                  Row(
//                    mainAxisAlignment: MainAxisAlignment.end,
//                    children: <Widget>[
//                      Text("COUPON: -HKD\$" + coupon.toStringAsFixed(1).toString()),
//                    ],
//                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("TOTAL: HKD\$" + (widget.orderStatus == "Cancelled" ?
                      widget.totalAmount.toStringAsFixed(1).toString()
                          : (purchase < 0 ? 0.toString() : widget.totalAmount.toStringAsFixed(1).toString()) ),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    ],
                  ),
                ],
              ),
            ),
            //Container(decoration: BoxDecoration(boxShadow: [BoxShadow(blurRadius: 3, offset: Offset(3, 3),),], color: Colors.yellow[50], border: Border.all(width: 2.0, color: Colors.black)), width: width*0.9, height: height*0.5, child: ItemList(widget.orderStatus),),
          ],
        ),
      ),
    );
  }



  double countPurchase(double price, int qty){

    return price * qty;
  }

  double countTotal(double purchase){
    return total = (purchase - coupon);
  }

  Widget orderList(String imgLink, String itemName, String itemNo, String itemStatus, double price, int qty){
    return Container(

      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(bottom: 5, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Image.network(imgLink,
                  width: 100,
                  height: 50,),
                Column(
                  //mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(itemName),
                    Text("Item No: "+itemNo, style: TextStyle(color: Colors.black),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(

                          child: Text("Status:" ),
                        ),
                        Container(
                          child: Text(itemStatus, style: TextStyle(color: getTheOrderColor(itemStatus)),),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          child: Text("HKD\$" + price.toString(), style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          child: Text("Qty:" + qty.toString(), style: TextStyle(color: Colors.black),),
                        ),
                      ],
                    ),
                    Divider(color: Colors.black,),
                  ],
                ),
              ],
            ),
          ),
          Divider(color: Colors.black,),
        ],
      ),
    );
  }

  Widget orderInfo (String orderDate, String deliveryAddress, String orderStatus, String deliveryDate, String paymentMethod){
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return FlipCard(

      direction: FlipDirection.HORIZONTAL,
      front: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.0),
              color: Colors.white,
              border: Border.all(
                  width: 2.0, color: Colors.black
              )
          ),
          width: width*0.9,
          height: height*0.42,
          child:Column(
            children: <Widget>[ Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(AppTranslations.of(context).text("orderDate") +': ' + orderDate, style: forTextFont,),
                Container(padding: const EdgeInsets.all(5),

                  child: Row(
                    children: <Widget>[
                      //Text(AppTranslations.of(context).text("qr"), style: TextStyle(color: Colors.redAccent),),
                      Icon(
                        Icons.arrow_forward,size: 22,
                      )
                    ],
                  ),
                ),
              ],
            ),
              Padding(
                padding: forPadding,
                child: Row(
                  children: <Widget>[
                    Text(AppTranslations.of(context).text("deliveryAddress") +': \n' +deliveryAddress, style: forTextFont,),
                  ],
                ),
              ),
              Padding(
                padding: forPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(AppTranslations.of(context).text("status") +': ' , style: forTextFont,),
                    Text(orderStatus, style: TextStyle(
                        color: getTheOrderColor(orderStatus),
                        fontSize: 15
                    ), ),
                  ],
                ),
              ),
              //Padding(padding: forPadding, child: Row(children: <Widget>[Text(AppTranslations.of(context).text("dOD") +': ' , style: forTextFont,),],),),
              Padding(
                padding: forPadding,
                child: Row(
                  children: <Widget>[
                    Text(AppTranslations.of(context).text("deDay")+ ": " + deliveryDate  , style: forTextFont,),
                  ],
                ),
              ),
              Padding(
                padding: forPadding,
                child: Row(
                  children: <Widget>[
                    Text(AppTranslations.of(context).text("paymentMethod") + ": "+ paymentMethod , style: forTextFont,),
                  ],
                ),
              ),

            ],
          )
      ),
      back: Container(
        height: height*0.38,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            color: Colors.white,
            border: Border.all(
                width: 2.0, color: Colors.black
            )
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(5),
              //decoration: BoxDecoration(boxShadow: [BoxShadow(blurRadius: 3, offset: Offset(3, 3),),], color: Colors.yellow[50], border: Border.all(width: 2.0, color: Colors.grey)),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.arrow_back,size: 22,
                  ),
                ],
              ),
            ),
            Container(

                width: width*0.9,
                height: height*0.30,
                color: Colors.white,
                // child: Image.asset('images/qrcode.jpg')),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    QrImage(
                      data: widget.orderNo,

                    ),
                  ],
                )
            ),
          ],
        ),
      ),
    );

  }
  Color theOrderColor;
  Color getTheOrderColor( String orderStatus){
    if(orderStatus.toString() == "In Progress"){
      return theOrderColor = Colors.blue;
    }else if (orderStatus.toString() == "Cancelled"){
      return theOrderColor = Colors.red;
    }else if (orderStatus.toString() == "Delivered"){
      return theOrderColor = Colors.green;
    }else {
      return theOrderColor = Colors.grey;
    }
  }


  List<OrderLineForReorder>  reorderOrderLines = [];
  List<DbStockAndCount> dbStock = [];
  bool dbEnoughStock = true;
  String createOrderNo;
  double totalAmt ;
  int userPoint, newDbStock, newDbBuyCount;

  void reorder(String orderNo) async{
    totalAmt = 0;
    for(var i = 0; i < orderLines.length; i++){

      totalAmt +=  (double.parse(orderLines[i].qty.toString()) * orderLines[i].price);
    }


    reference.child("Parts").once().then((DataSnapshot ss){
      Map<dynamic, dynamic>d = ss.value;
      dbStock.clear();

      for(var ind in d.keys){
        for(var i = 0; i < orderLines.length; i++){
          if(d[ind]["partNo"] == orderLines[i].partNo){
            if(d[ind]["stockQty"] < orderLines[i].qty){
              dbEnoughStock = false;
            }else{
              print(d[ind]["partNo"] + " <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< DB");
              DbStockAndCount db = DbStockAndCount(d[ind]["buyCount"],d[ind]["stockQty"]);
              dbStock.add(db);
            }
          }
        }
      }


      if(dbEnoughStock == true){

        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Total",style: TextStyle(fontSize: 16),),
              content:  Text('The total amount of the order is ' + totalAmt.toStringAsFixed(1).toString() +
                  "\n Do you still want to place the order?",style: TextStyle(fontSize: 16),),
              actions: <Widget>[
                FlatButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text('Yes, please'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    placeOrder(orderNo);

                  },
                ),
              ],
            );
          },
        );


      }else{
        showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Out of stock",style: TextStyle(fontSize: 16),),
              content: const Text('Sorry, we do not have enough stock for item(s)!',style: TextStyle(fontSize: 16),),
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
    });


  }
  var formatdate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  void placeOrder( String orderNo){

    reference.child("user").once().then((DataSnapshot s){
      Map<dynamic, dynamic>dt = s.value;
      for(var ind in dt.keys){
        if(widget.userID == dt[ind]["userID"]){


          userPoint = int.parse(dt[ind]["points"]);
          userPoint += (totalAmt/100).round();
          print(userPoint.toString() + "<<<<<<<<< user point");
          final userUpdate = reference.child("user").child(widget.userID);
          userUpdate.update({
            "points" : userPoint.toString()
          });

          var currentDate = DateTime.now();
          String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
          String recordID = DateTime.now().millisecondsSinceEpoch.toString();

          reference.child("user/"+widget.userID+"/pointRecord/"+recordID).update({
            "date": formattedDate,
            "point":"+"+(totalAmt/100).round().toString(),
            "description":"Place Order:"+createOrderNo.toString()
          });
        }
      }
    });

    checkTotalOrder();
    createOrderNo = (totalOrder.length + 1).toString();
    createOrderNo = createOrderNoMethod((totalOrder.length + 1).toString(), (totalOrder.length + 1).toString().length);
    print(createOrderNo + "<<<<<<<<<<<");

    reference.child("Order").once().then((DataSnapshot s){
      Map<dynamic, dynamic>dt = s.value;
      for(var ind in dt.keys){
        if(dt[ind]["orderNo"] == orderNo){
          print(dt[ind]["paymentMethod"] + " <payment deliveryAddress>" + dt[ind]["deliveryAddress"]);
          createOrder(dt[ind]["paymentMethod"], createOrderNo, widget.userID, dt[ind]["deliveryAddress"]);
        }
      }
    });

    for(var i = 0; i < orderLines.length; i++){
      newDbStock = dbStock[i].stockQty - orderLines[i].qty;
      newDbBuyCount = dbStock[i].buyCount + orderLines[i].qty;
      print(newDbStock.toString());
      print(newDbBuyCount.toString() + " buyCount");
      print(totalOrder.length.toString() + " total order length");

      final updatePart = reference.child("Parts").child(orderLines[i].partNo);
      updatePart.update({
        "buyCount" : newDbBuyCount,
        "stockQty" : newDbStock
      });

      final updateOrderLine = reference.child("OrderLine").child(createOrderNo+"-"+orderLines[i].partNo);
      updateOrderLine.update({
        "deliveryOrder" : "n/a",
        "orderNo" : createOrderNo,
        "partNo" : orderLines[i].partNo,
        "partStatus" : "In Progress",
        "qty" : orderLines[i].qty
      });
    }

    YYAlertDialogWithDivider(context, "The order " + createOrderNo + " has been placed!");

  }

  void createOrder(String paymentMethod, String orderNo, String userID, String deliveryAddress){
    final createOrder = reference.child("Order").child(createOrderNo);
    createOrder.update({
      "paymentMethod" : paymentMethod,
      "orderNo" : orderNo,
      "orderStatus" : "In Progress",
      "orderDate" : formatdate,
      "deliveryDate" : "n/a",
      "user" : widget.userID,
      "deliveryAddress" : deliveryAddress,
      "totalAmount" : double.parse(totalAmt.toStringAsFixed(1))
    });
  }

  String createOrderNoMethod(String orderNo, int orderLength){
    if(orderLength == 1 ){
      return "0000" + orderNo;
    }else if(orderLength == 2 ){
      return "000" + orderNo;
    }else if(orderLength == 3 ){
      return "00" + orderNo;
    }else if(orderLength == 4 ){
      return "0" +orderNo;
    }else{
      return orderNo;
    }
  }

  YYDialog YYAlertDialogWithDivider(BuildContext context, String Msg) {
    return YYDialog().build(context)
      ..width = 220
      ..borderRadius = 4.0
      ..animatedFunc = (child, animation) {
        return ScaleTransition(
          child: child,
          scale: Tween(begin: 0.0, end: 1.0).animate(animation),
        );
      }
      ..text(
        padding: EdgeInsets.all(25.0),
        alignment: Alignment.center,
        text: Msg,
        color: Colors.black,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      )
      ..divider()
      ..doubleButton(
        padding: EdgeInsets.only(top: 10.0),
        gravity: Gravity.center,
        withDivider: false,
        text1: "",
        color1: Colors.redAccent,
        fontSize1: 14.0,
        fontWeight1: FontWeight.bold,
        onTap1: () {},
        text2: "Okay",
        color2: Colors.redAccent,
        fontSize2: 14.0,
        fontWeight2: FontWeight.bold,
        onTap2: () {
          Route route = MaterialPageRoute(builder: (context) => NewOrder(widget.userID));
          Navigator.of(context).pop();
          Navigator.push(context, route);
        },
      )
      ..show();
  }

}