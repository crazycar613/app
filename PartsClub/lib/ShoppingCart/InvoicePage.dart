import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/rendering.dart';
import 'package:newmap2/MainPage/Index.dart';
import 'package:newmap2/Models/Order.dart';
import 'package:newmap2/Models/OrderLine.dart';
import 'package:newmap2/OrderList/newOrderList.dart';
import 'package:newmap2/Product/ProductList.dart';


import 'CartList.dart';

class InvoicePage extends StatefulWidget {
  String orderNo;

  InvoicePage(this.orderNo);

  @override
  _InvoicePageState createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  Order o;
  DatabaseReference reference =
      FirebaseDatabase.instance.reference().child('Order');
  DatabaseReference orderLineRef =
      FirebaseDatabase.instance.reference().child('OrderLine');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return new Scaffold(
      appBar: AppBar(
        title: Text("Invoice"),
      ),
      body: Container(
        child: FutureBuilder(
          future: reference.child(widget.orderNo).once(),
          builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
            if (snapshot.hasData) {
              Map<dynamic, dynamic> values = snapshot.data.value;
              values.forEach((key, value) {
                o = new Order(
                    values['orderNo'],
                    values['userID'],
                    values['orderDate'],
                    values['orderStatus'],
                    values['deliveryAddress'],
                    values['deliveryDate'],
                    values['paymentMethod'],
                    values['totalAmount']);
              });
              return Center(
                child: Container(
                  margin: EdgeInsets.only(right: 20, left: 20),
                  height: screenHeight * 0.85,
                  width: screenWidth * 0.9,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            spreadRadius: 4),
                      ]),
                  child: new Container(
                      child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: screenHeight * 0.05,
                      ),
                      Image.asset(
                        "assets/Inchcape.png",
                        width: screenWidth * 0.4,
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      Text(
                        "INVOICE",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Divider(
                        indent: 5,
                        endIndent: 5,
                        height: screenHeight * 0.03,
                        color: Colors.grey,
                        thickness: screenHeight * 0.002,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            " Order Number:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            o.orderNo + " ",
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            " Order Date:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            o.orderDate + " ",
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            " Order Status:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            o.orderStatus + " ",
                          )
                        ],
                      ),
                      Divider(
                        indent: 5,
                        endIndent: 5,
                        height: screenHeight * 0.03,
                        color: Colors.grey,
                        thickness: screenHeight * 0.002,
                      ),
                      Center(
                        child: Text("Order Line", style: TextStyle(fontWeight: FontWeight.bold),),
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            " Part Number:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Qty ",
                          )
                        ],
                      ),
                      FutureBuilder(
                        future: orderLineRef.once(),
                        builder:
                            (context, AsyncSnapshot<DataSnapshot> snapshot) {
                          List<OrderLine> lines = [];
                          if (snapshot.hasData) {
                            lines.clear();
                            Map<dynamic, dynamic> values = snapshot.data.value;
                            values.forEach((key, value) {
                              if (value['orderNo'] == o.orderNo) {
                                OrderLine ol = new OrderLine(value['orderNo'],
                                    value['partNo'], value['qty']);
                                lines.add(ol);
                              }
                            });
                            return Container(
                              height: screenHeight*0.3,
                              child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: lines.length,
                                  itemBuilder:(BuildContext context, int index) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(" "+lines[index].partNo),
                                        Text(
                                          lines[index].qty.toString() + " ",
                                        )
                                      ],
                                    );
                                  }),
                            );
                          }
                          return CircularProgressIndicator();
                        },
                      ),
                      Divider(
                        indent: 5,
                        endIndent: 5,
                        height: screenHeight * 0.03,
                        color: Colors.grey,
                        thickness: screenHeight * 0.002,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            " Total Amount:",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text("\$"+o.totalAmount.toString()+" ", style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)
                            ,
                          )
                        ],
                      ),
                    ],
                  )),
                ),
              );
            }
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
