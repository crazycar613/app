import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newmap2/MainPage/Index.dart';
import 'package:newmap2/Models/DbStockAndCount.dart';
import 'package:newmap2/Models/OrderLineForReorder.dart';
import 'package:newmap2/Models/TotalOrder.dart';
import '../ChangeLanguage/app_translations.dart';
import './OrderDetail.dart';
import '../Overlay/mydrawer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import './OrderInfos.dart';
import 'ColumnBuilder.dart';
import 'OrderLists.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:newmap2/ShoppingCart/InvoicePage.dart';

class NewOrder extends StatefulWidget {
  final String userID;
  NewOrder(this.userID);
  @override
  _MyNewOrderState createState() => _MyNewOrderState();
}

class Ostatus {
  String TypeOfStatus;

  Ostatus(this.TypeOfStatus);

  static List<Ostatus> getType() {
    return <Ostatus>[
      Ostatus("All"),
      Ostatus("In Progress"),
      Ostatus("Cancelled"),
      Ostatus("Completed"),
      Ostatus("Returned"),
    ];
  }
}

class _MyNewOrderState extends State<NewOrder> {
  List<Ostatus> _oTypes = Ostatus.getType();

  List<DropdownMenuItem<Ostatus>> _dropdownMenuItem;

  Ostatus _selectedType;
  List<OrderInfos> orderInfos = [];
  List<TotalOrder> totalOrder =[];

  void initState() {
    _dropdownMenuItem = buildDropdownMenuItems(_oTypes);
    _selectedType = _dropdownMenuItem[0].value;
    super.initState();
    checkTotalOrder();

    DatabaseReference db = FirebaseDatabase.instance.reference().child("Order");
    db.once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> data = snapshot.value;
      orderInfos.clear();
      for (var indKey in data.keys) {
        if (widget.userID == data[indKey]["user"]) {
          //print(data[indKey]["orderNo"]);
          //print(data[indKey]["orderStatus"]);
          OrderInfos orderInfoLists = new OrderInfos(
              data[indKey]["deliveryAddress"],
              data[indKey]["orderDate"],
              data[indKey]["orderNo"],
              data[indKey]["orderStatus"],
              data[indKey]["paymentMethod"],
              data[indKey]["deliveryDate"],
              double.parse(data[indKey]["totalAmount"].toString()));
          print("Length: " + data[indKey]["totalAmount"].toString());
          orderInfos.add(orderInfoLists);
        }
      }

      setState(() {
        //print("Length: " + orderInfos.length.toString());
      });
    });
  }

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

  onChangeDropDownItem(Ostatus selectType) {
    setState(() {
      _selectedType = selectType;
    });
  }

  List<DropdownMenuItem<Ostatus>> buildDropdownMenuItems(List oTypes) {
    List<DropdownMenuItem<Ostatus>> items = List();
    for (Ostatus ct in oTypes) {
      items.add(
        DropdownMenuItem(
          value: ct,
          child: Text(ct.TypeOfStatus),
        ),
      );
    }
    return items;
  }

  _try() {}

  @override
  Widget build(BuildContext context) {
    List<String> _status = [
      AppTranslations.of(context).text("all"),
      AppTranslations.of(context).text("inprocess"),
      AppTranslations.of(context).text("cancelled"),
      AppTranslations.of(context).text("completed")
    ];
    String _selectedStatus = null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          AppTranslations.of(context).text("myOrder"),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: new Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0, left: 15.0, right: 15.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    child: Text(
                      AppTranslations.of(context).text("status") + ":  ",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  DropdownButton(
                    items: _dropdownMenuItem,
                    value: _selectedType,
                    onChanged: onChangeDropDownItem,
                  )
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width,
                    child: orderInfos.length == 0
                        ? Center(child: CircularProgressIndicator())
                        : ListView.builder(
                      itemCount: orderInfos.length,
                      itemBuilder: (_, index) {
                        if (orderInfos[index].orderStatus ==
                            "In Progress") {
                          //print(orderInfos[index].orderStatus + "progress" + orderInfos[index].orderNo);
                          if (_selectedType.TypeOfStatus.toString() ==
                              "All" ||
                              _selectedType.TypeOfStatus.toString() ==
                                  "In Progress")
                            return inProgressOrder(
                                orderInfos[index].orderDate,
                                orderInfos[index].orderStatus,
                                orderInfos[index].orderNo,
                                orderInfos[index].deliveryDate,
                                orderInfos[index].deliveryAddress,
                                orderInfos[index].paymentMethod,
                                orderInfos[index].totalAmount
                            );
                        } else if (orderInfos[index].orderStatus ==
                            "Delivered") {
                          if (_selectedType.TypeOfStatus.toString() ==
                              "All" ||
                              _selectedType.TypeOfStatus.toString() ==
                                  "Completed") {
                            if (7 >=
                                countDays(
                                    orderInfos[index].deliveryDate)) {
                              //print(orderInfos[index].orderStatus + "after 7" + orderInfos[index].orderNo);

                              return deliveredOrder(
                                  orderInfos[index].orderDate,
                                  orderInfos[index].orderStatus,
                                  orderInfos[index].orderNo,
                                  orderInfos[index].deliveryDate,
                                  orderInfos[index].deliveryAddress,
                                  orderInfos[index].paymentMethod,
                                  orderInfos[index].totalAmount);
                            } else {
                              //print(orderInfos[index].orderStatus + "before 7" + orderInfos[index].orderNo);

                              return deliveredWithin7DaysOrder(
                                  orderInfos[index].orderDate,
                                  orderInfos[index].orderStatus,
                                  orderInfos[index].orderNo,
                                  orderInfos[index].deliveryDate,
                                  orderInfos[index].deliveryAddress,
                                  orderInfos[index].paymentMethod,
                                  orderInfos[index].totalAmount);
                            }
                          }
                        } else if (orderInfos[index].orderStatus ==
                            "Cancelled") {
                          //print(orderInfos[index].orderStatus + "cancelled" + orderInfos[index].orderNo);
                          if (_selectedType.TypeOfStatus.toString() ==
                              "All" ||
                              _selectedType.TypeOfStatus.toString() ==
                                  "Cancelled")
                            return cancelledOrder(
                                orderInfos[index].orderDate,
                                orderInfos[index].orderStatus,
                                orderInfos[index].orderNo,
                                orderInfos[index].deliveryDate,
                                orderInfos[index].deliveryAddress,
                                orderInfos[index].paymentMethod,
                                orderInfos[index].totalAmount);
                        } else if (orderInfos[index].orderStatus ==
                            "Returned") {
                          //print(orderInfos[index].orderStatus + "cancelled" + orderInfos[index].orderNo);
                          if (_selectedType.TypeOfStatus.toString() ==
                              "All" ||
                              _selectedType.TypeOfStatus.toString() ==
                                  "Returned")
                            return returnedOrder(
                                orderInfos[index].orderDate,
                                orderInfos[index].orderStatus,
                                orderInfos[index].orderNo,
                                orderInfos[index].deliveryDate,
                                orderInfos[index].deliveryAddress,
                                orderInfos[index].paymentMethod,
                                orderInfos[index].totalAmount);
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  createAlerDialog(BuildContext context, orderNum) {
    return showDialog(
        context: context,
        builder: (context) => _orderQRCorde(context, orderNum));
  }

  _orderQRCorde(BuildContext context, orderNum) {
    return Container(
      height: 250.0,
      width: 150.0,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.black38, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: Offset(5, 5),
            )
          ]),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          QrImage(
            data: orderNum,
            size: 250,
          ),
          Container(
            alignment: Alignment.topRight,
            child: RaisedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                label: Text('Close')),
          ),
        ],
      ),
    );
  }

  Widget deliveredOrder(String orderDate, String orderStatus, String orderNum,
      String deliveryDate, String deliveryAddress, String paymentMethod, double totalAmount) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(
              Icons.done,
              color: Colors.white,
            ),
          ),
          title: Row(
            children: <Widget>[
              Text("#" + orderNum),
              Text(
                " [Delivered]",
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
          subtitle: Text(orderDate),
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
            caption: 'QR Code',
            color: Colors.grey,
            icon: Icons.memory,
            onTap: () {
              createAlerDialog(context, orderNum);
            }),
        IconSlideAction(
            caption: 'Invoice',
            color: Colors.grey,
            icon: Icons.receipt,
            onTap: () {
              Route route = MaterialPageRoute(
                  builder: (context) => InvoicePage(orderNum));
              //Navigator.of(context).pop();
              Navigator.push(context, route);

            }),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: 'View',
            color: Colors.black45,
            icon: Icons.list,
            onTap: () {
              Route route = MaterialPageRoute(
                  builder: (context) => OrderDetail(
                      orderNum,
                      orderDate,
                      orderStatus,
                      deliveryDate,
                      deliveryAddress,
                      paymentMethod,
                      totalAmount,
                  widget.userID));
              //Navigator.of(context).pop();
              Navigator.push(context, route);
            }),

      ],
    );
  }

  Widget returnedOrder(String orderDate, String orderStatus, String orderNum,
      String deliveryDate, String deliveryAddress, String paymentMethod, double totalAmount) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(
              Icons.done,
              color: Colors.white,
            ),
          ),
          title: Row(
            children: <Widget>[
              Text("#" + orderNum),
              Text(
                " [Returned]",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          subtitle: Text(orderDate),
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
            caption: 'QR Code',
            color: Colors.grey,
            icon: Icons.memory,
            onTap: () {
              createAlerDialog(context, orderNum);
            }),


      ],
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: 'View',
            color: Colors.black45,
            icon: Icons.list,
            onTap: () {
              Route route = MaterialPageRoute(
                  builder: (context) => OrderDetail(
                      orderNum,
                      orderDate,
                      orderStatus,
                      deliveryDate,
                      deliveryAddress,
                      paymentMethod,
                      totalAmount,
                  widget.userID));
              //Navigator.of(context).pop();
              Navigator.push(context, route);
            }),

      ],
    );
  }

  Widget inProgressOrder(String orderDate, String orderStatus, String orderNum,
      String deliveryDate, String deliveryAddress, String paymentMethod, double totalAmount) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: ListTile(
//          leading: CircleAvatar(
//            backgroundColor: Colors.indigoAccent,
//            child: Text(orderStatus),
//            foregroundColor: Colors.white,
//          ),

          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.receipt,
              color: Colors.white,
            ),
          ),
          title: Row(
            children: <Widget>[
              Text("#" + orderNum),
              Text(
                " [In Progress]",
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
          subtitle: Text(orderDate),
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
            caption: 'QR Code',
            color: Colors.grey,
            icon: Icons.memory,
            onTap: () {
              createAlerDialog(context, orderNum);
            }),
        IconSlideAction(
            caption: 'Invoice',
            color: Colors.grey,
            icon: Icons.receipt,
            onTap: () {
              Route route = MaterialPageRoute(
                  builder: (context) => InvoicePage(orderNum));
              //Navigator.of(context).pop();
              Navigator.push(context, route);

            }),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: 'View',
            color: Colors.black45,
            icon: Icons.list,
            onTap: () {
              Route route = MaterialPageRoute(
                  builder: (context) => OrderDetail(
                      orderNum,
                      orderDate,
                      orderStatus,
                      deliveryDate,
                      deliveryAddress,
                      paymentMethod,
                      totalAmount,
                  widget.userID));
              //Navigator.of(context).pop();
              Navigator.push(context, route);
            }),

        IconSlideAction(
            caption: 'Cancel',
            color: Colors.red,
            icon: Icons.cancel,
            onTap: () {
              //cancelFun(orderNum);

              cancelFunc(orderNum);
            }),
      ],
    );
  }
  List<OrderLineForReorder>  reorderOrderLines = [];
  List<DbStockAndCount> dbStock = [];
  bool dbEnoughStock = true;
  String createOrderNo;
  double totalAmt;
  int userPoint, newDbStock, newDbBuyCount;

  List<OrderLists> orderLines = [];
  String takeOutTheOpen = "";
  String takeOutTheClose = "";
  String withoutAnything = "";
  String theOrderLineKey = "";
  int stockNum = 0;
  String storeStock = "";

  var formatdate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  void cancelFunc(String orderNum) {
    bool orderDelivery = false;
    final dba = FirebaseDatabase.instance.reference().child("OrderLine");
    dba.once().then((DataSnapshot snap) {
      Map<dynamic, dynamic> data = snap.value;
      for (var indKey in data.keys) {
        if (data[indKey]["orderNo"] == orderNum) {
          if (data[indKey]["partStatus"] == "Delivered" ||
              data[indKey]["deliveryOrder"] != "n/a") {
            OrderLists orderLists = new OrderLists(
                orderNum,
                data[indKey]["partNo"],
                data[indKey]["partStatus"],
                data[indKey]["qty"]);
            orderLines.add(orderLists);
            orderDelivery = true;
          } else {
            OrderLists orderLists = new OrderLists(
                orderNum,
                data[indKey]["partNo"],
                data[indKey]["partStatus"],
                data[indKey]["qty"]);
            orderLines.add(orderLists);
          }
        }
      }
      if (orderDelivery == true) {
        unableToCancelDia(
            context,
            "The Order #" +
                orderNum +
                " cannot be cancelled since the item(s) has/have been delivered or shipped.");
      } else {
        cancelOrderAndItems(orderNum, "Cancelled");
      }
    });
    setState(() {});
  }

  void cancelOrderAndItems(String orderNum, String orderStatus) {
    takeOutTheOpen = "";
    takeOutTheClose = "";
    final checkAllOrderLines =
    FirebaseDatabase.instance.reference().child("OrderLine");
    final findOrderLineKey =
    FirebaseDatabase.instance.reference().child("OrderLine");
    checkAllOrderLines.once().then((DataSnapshot snap) {
      Map<dynamic, dynamic> data = snap.value;
      for (var indKey in data.keys) {
        for (var i = 0; i < orderLines.length; i++) {
          if (data[indKey]["orderNo"] == orderNum &&
              data[indKey]["partNo"] == orderLines[i].partNo) {
            //print(indKey.toString());
            findOrderLineKey
                .orderByChild("partNo")
                .equalTo(orderLines[i].partNo)
                .once()
                .then((DataSnapshot s) {
              Map<dynamic, dynamic> getOrderLineKey = s.value;
              theOrderLineKey = getOrderLineKey.keys.toString();
              takeOutTheOpen = theOrderLineKey.split("(")[1];
              takeOutTheClose = takeOutTheOpen.split(")")[0];
              final updateOLStat = FirebaseDatabase.instance
                  .reference()
                  .child("OrderLine")
                  .child(indKey.toString());
              updateOLStat.update({"partStatus": "Cancelled"});
              final updateOrderState = FirebaseDatabase.instance
                  .reference()
                  .child("Order")
                  .child(orderNum);
              updateOrderState.update({"orderStatus": orderStatus});
              final dbParts =
              FirebaseDatabase.instance.reference().child("Parts");
              dbParts.once().then((DataSnapshot sh) {
                Map<dynamic, dynamic> data2 = sh.value;
                for (var ind in data2.keys) {
                  if (orderLines[i].partNo == data2[ind]["partNo"] &&
                      orderLines[i].partStatus != "Cancelled" &&
                      orderLines[i].partStatus != "Delivered") {
                    storeStock = data2[ind]["stockQty"].toString();
                    stockNum = int.parse(storeStock);
                    stockNum = stockNum + orderLines[i].qty;
                    final updateStock = FirebaseDatabase.instance
                        .reference()
                        .child("Parts")
                        .child(orderLines[i].partNo);
                    updateStock.update({"stockQty": stockNum});
                  }
                }
              });
            });
          }
        }
      }
    });
    cancelDialog(context, orderNum);
    setState(() {});
  }

  void returnOrderAndItems(String orderNum, String orderStatus) {
    takeOutTheOpen = "";
    takeOutTheClose = "";
    final checkAllOrderLines =
    FirebaseDatabase.instance.reference().child("OrderLine");
    final findOrderLineKey =
    FirebaseDatabase.instance.reference().child("OrderLine");
    checkAllOrderLines.once().then((DataSnapshot snap) {
      Map<dynamic, dynamic> data = snap.value;
      for (var indKey in data.keys) {
        for (var i = 0; i < orderLines.length; i++) {
          if (data[indKey]["orderNo"] == orderNum &&
              data[indKey]["partNo"] == orderLines[i].partNo) {
            //print(indKey.toString());
            findOrderLineKey
                .orderByChild("partNo")
                .equalTo(orderLines[i].partNo)
                .once()
                .then((DataSnapshot s) {
              Map<dynamic, dynamic> getOrderLineKey = s.value;
              theOrderLineKey = getOrderLineKey.keys.toString();
              takeOutTheOpen = theOrderLineKey.split("(")[1];
              takeOutTheClose = takeOutTheOpen.split(")")[0];
              final updateOLStat = FirebaseDatabase.instance
                  .reference()
                  .child("OrderLine")
                  .child(indKey.toString());
              updateOLStat.update({"partStatus": "Returned"});
              final updateOrderState = FirebaseDatabase.instance
                  .reference()
                  .child("Order")
                  .child(orderNum);
              updateOrderState.update({"orderStatus": orderStatus});

              final dbParts =
              FirebaseDatabase.instance.reference().child("Parts");
              dbParts.once().then((DataSnapshot sh) {
                Map<dynamic, dynamic> data2 = sh.value;
                for (var ind in data2.keys) {
                  if (orderLines[i].partNo == data2[ind]["partNo"] &&
                      orderLines[i].partStatus != "Cancelled") {
                    storeStock = data2[ind]["stockQty"].toString();
                    stockNum = int.parse(storeStock);
                    stockNum = stockNum + orderLines[i].qty;
                    final updateStock = FirebaseDatabase.instance
                        .reference()
                        .child("Parts")
                        .child(orderLines[i].partNo);
                    updateStock.update({"stockQty": stockNum});
                  }
                }
              });
            });
          }
        }
      }
    });
    cancelDialog(context, orderNum);
    setState(() {});
  }

  void returnFun(String orderNum) {
    final dba = FirebaseDatabase.instance.reference().child("OrderLine");
    dba.once().then((DataSnapshot snap) {
      Map<dynamic, dynamic> data = snap.value;
      for (var indKey in data.keys) {
        if (data[indKey]["orderNo"] == orderNum) {
          if (data[indKey]["partStatus"] == "Delivered") {
            OrderLists orderLists = new OrderLists(
                orderNum,
                data[indKey]["partNo"],
                data[indKey]["partStatus"],
                data[indKey]["qty"]);
            orderLines.add(orderLists);
          } else {
            OrderLists orderLists = new OrderLists(
                orderNum,
                data[indKey]["partNo"],
                data[indKey]["partStatus"],
                data[indKey]["qty"]);
            orderLines.add(orderLists);
          }
        }
      }
      returnOrderAndItems(orderNum, "Returned");
    });
    setState(() {});
  }

  Widget cancelledOrder(String orderDate, String orderStatus, String orderNum,
      String deliveryDate, String deliveryAddress, String paymentMethod, double totalAmount) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: ListTile(
//          leading: CircleAvatar(
//            backgroundColor: Colors.indigoAccent,
//            child: Text(orderStatus),
//            foregroundColor: Colors.white,
//          ),

          leading: CircleAvatar(
            backgroundColor: Colors.red,
            child: Icon(
              Icons.close,
              color: Colors.white,
            ),
          ),
          title: Row(
            children: <Widget>[
              Text("#" + orderNum),
              Text(
                " [Cancelled]",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
          subtitle: Text(orderDate),
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
            caption: 'QR Code',
            color: Colors.grey,
            icon: Icons.memory,
            onTap: () {
              createAlerDialog(context, orderNum);
            }),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: 'View',
            color: Colors.black45,
            icon: Icons.list,
            onTap: () {
              Route route = MaterialPageRoute(
                  builder: (context) => OrderDetail(
                      orderNum,
                      orderDate,
                      orderStatus,
                      deliveryDate,
                      deliveryAddress,
                      paymentMethod,
                      totalAmount,
                  widget.userID));
              //Navigator.of(context).pop();
              Navigator.push(context, route);
            }),
      ],
    );
  }

  Widget deliveredWithin7DaysOrder(
      String orderDate,
      String orderStatus,
      String orderNum,
      String deliveryDate,
      String deliveryAddress,
      String paymentMethod,
      double totalAmount) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Container(
        color: Colors.white,
        child: ListTile(
//          leading: CircleAvatar(
//            backgroundColor: Colors.indigoAccent,
//            child: Text(orderStatus),
//            foregroundColor: Colors.white,
//          ),

          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(
              Icons.done,
              color: Colors.white,
            ),
          ),
          title: Row(
            children: <Widget>[
              Text("#" + orderNum),
              Text(
                " [Delivered]",
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
          subtitle: Text(orderDate),
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
            caption: 'QR Code',
            color: Colors.grey,
            icon: Icons.memory,
            onTap: () {
              createAlerDialog(context, orderNum);
            }),
        IconSlideAction(
            caption: 'Invoice',
            color: Colors.grey,
            icon: Icons.receipt,
            onTap: () {
              Route route = MaterialPageRoute(
                  builder: (context) => InvoicePage(orderNum));
              //Navigator.of(context).pop();
              Navigator.push(context, route);

            }),
      ],
      secondaryActions: <Widget>[
        IconSlideAction(
            caption: 'View',
            color: Colors.black45,
            icon: Icons.list,
            onTap: () {
              Route route = MaterialPageRoute(
                  builder: (context) => OrderDetail(
                      orderNum,
                      orderDate,
                      orderStatus,
                      deliveryDate,
                      deliveryAddress,
                      paymentMethod,
                      totalAmount,
                  widget.userID));
              //Navigator.of(context).pop();
              Navigator.push(context, route);
            }),

        IconSlideAction(
            caption: 'Return',
            color: Colors.black26,
            icon: Icons.keyboard_return,
            onTap: () {
              returnFun(orderNum);
            }),
      ],
    );
  }

  int countDays(String deliveryDate) {
    DateTime op = DateTime.parse(deliveryDate);
    Duration dur = DateTime.now().difference(op);
    int differeIndays = (dur.inDays).floor();
    return differeIndays;
  }

  YYDialog cancelDialog(BuildContext context, String orderNum) {
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
        text: "The order " + orderNum + " has been updated",
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

  YYDialog unableToCancelDia(BuildContext context, String Msg) {
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
        onTap2: () {},
      )
      ..show();
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
