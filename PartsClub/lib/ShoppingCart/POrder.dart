import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newmap2/Models/Coupon.dart';
import 'package:newmap2/Models/DbStockAndCount.dart';
import 'package:newmap2/Models/ItemInCart.dart';
import 'package:newmap2/Models/TotalOrder.dart';
import 'package:newmap2/Product/ProductList.dart';

import 'InvoicePage.dart';

class POrder {
  bool isPaymentCheck, isShipmentCheck, isCouponCheck;
  String userID, deliveryAddress, myController;
  List<ItemInCart> items;
  List<Coupon> userCoupons = [];
  BuildContext context;
  double totalAmt;
  int orderLength, couponIndex;

  POrder(this.isPaymentCheck,
      this.isShipmentCheck,
      this.userID,
      this.deliveryAddress,
      this.myController,
      this.items,
      this.context,
      this.totalAmt,
      this.orderLength,
      this.userCoupons,
      this.couponIndex,
      this.isCouponCheck);


  @override
  void initState(){
    checkTotalOrder();
  }
  bool dbEnoughStock = true;
  List<DbStockAndCount> dbStock = [];
  List<TotalOrder> totalOrder =[];
  int newDbStock, newDbBuyCount;
  int userPoint;
  String createOrderNo;
  DatabaseReference reference = FirebaseDatabase.instance.reference();
  var formatdate = DateFormat('yyyy-MM-dd').format(DateTime.now());


  void checkOutMethod(){

    reference.child("Parts").once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic>data = snapshot.value;
      dbStock.clear();
      for(var indkey in data.keys){
        for(var i = 0; i < items.length; i++){
          if(data[indkey]["partNo"] == items[i].partNo){
            if( data[indkey]["stockQty"] < items[i].buyQty){
              dbEnoughStock = false;
            }else{
              DbStockAndCount db = DbStockAndCount(data[indkey]["buyCount"],data[indkey]["stockQty"]);
              dbStock.add(db);
            }
          }
        }
      }
      if(dbEnoughStock == true){
        checkTotalOrder();
        createOrderNo = (totalOrder.length + 1).toString();

        reference.child("user").once().then((DataSnapshot s){
          Map<dynamic, dynamic>dt = s.value;
          for(var ind in dt.keys){
            if(userID == dt[ind]["userID"]){


              userPoint = int.parse(dt[ind]["points"]);
              userPoint += (totalAmt/100).round();
              final userUpdate = reference.child("user").child(userID);
              userUpdate.update({
                "points" : userPoint.toString()
              });

              var currentDate = DateTime.now();
              String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
              String recordID = DateTime.now().millisecondsSinceEpoch.toString();

              reference.child("user/"+userID+"/pointRecord/"+recordID).update({
                "date": formattedDate,
                "point":"+"+(totalAmt/100).round().toString(),
                "description":"Place Order:"+createOrderNo.toString()
              });
            }
          }
        });




        print(createOrderNo + "+++++++++++++++++++++++++++++++++++++++++++");
        createOrderNo = createOrderNoMethod((orderLength + 1).toString(), (orderLength + 1).toString().length);
        if(isPaymentCheck){
          if(isShipmentCheck){
            createOrder("Credit Card", createOrderNo, userID, myController);
          }else{
            createOrder("Credit Card", createOrderNo, userID, deliveryAddress);
          }
        }else{
          if(isShipmentCheck){
            createOrder("Cash on Delivery", createOrderNo, userID, myController);
          }else{
            createOrder("Cash on Delivery", createOrderNo, userID, deliveryAddress);
          }
        }

        if(isCouponCheck){
          final updateUserCoupon = reference.child("user").child(userID).child("coupon").child(userCoupons[couponIndex].couponNo);
          updateUserCoupon.update({
            "isUse" : "true"
          });
        }

        for(var i = 0; i < items.length; i++){
          newDbStock = dbStock[i].stockQty - items[i].buyQty;
          newDbBuyCount = dbStock[i].buyCount + items[i].buyQty;
          print(newDbStock.toString());
          print(newDbBuyCount.toString() + " buyCount");
          print(totalOrder.length.toString() + " total order length");

          final updatePart = reference.child("Parts").child(items[i].partNo);
          updatePart.update({
            "buyCount" : newDbBuyCount,
            "stockQty" : newDbStock
          });
          final  removeShoppingCart = reference.child("user").child(userID).child("shoppingCart");
          removeShoppingCart.remove();
          final updateOrderLine = reference.child("OrderLine").child(createOrderNo+"-"+items[i].partNo);
          updateOrderLine.update({
            "deliveryOrder" : "n/a",
            "orderNo" : createOrderNo,
            "partNo" : items[i].partNo,
            "partStatus" : "In Progress",
            "qty" : items[i].buyQty
          });
        }
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Successful",style: TextStyle(fontSize: 16),),
              content: Text('The order ' + createOrderNo + ' has been placed!',style: TextStyle(fontSize: 16),),
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

  void createOrder(String paymentMethod, String orderNo, String userID, String deliveryAddress){
    final createOrder = reference.child("Order").child(createOrderNo);
    createOrder.update({
      "paymentMethod" : paymentMethod,
      "orderNo" : orderNo,
      "orderStatus" : "In Progress",
      "orderDate" : formatdate,
      "deliveryDate" : "n/a",
      "user" : userID,
      "deliveryAddress" : deliveryAddress,
      "totalAmount" : double.parse(totalAmt.toStringAsFixed(1))
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
}