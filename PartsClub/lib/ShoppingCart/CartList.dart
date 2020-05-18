import 'package:flutter/material.dart';
import 'package:newmap2/Enquiry/Enquiry.dart';
import 'package:newmap2/Models/ItemInCart.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:newmap2/ShoppingCart/checkout.dart';
import '../ChangeLanguage/app_translations.dart';


class CartList extends StatefulWidget {


  @override
  _CartListState createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  DatabaseReference reference = FirebaseDatabase.instance.reference();
  List<ItemInCart> cartItems = [];
  SharedPreferences preferences;
  String userID = "";
  double totalAmt = 0;
  TextEditingController c;
  int itemCount =0;
  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }


  getUserID() async {
    preferences = await SharedPreferences.getInstance();
    setState(() {
      userID = preferences.getString('id');
    });
    print(userID + "===================THIS IS USERID=====================");
  }

  getCartItemAmount() async{
    preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id');

    reference
        .child("user")
        .child(id)
        .child("shoppingCart")
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;

      setState(() {
        itemCount = values.length;
      });

    });
  }

  updateCartItem(String partNo, int amt, double unitPrice) async{
    preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id');
    double totalPrice;

    totalPrice = amt * unitPrice;
    reference
        .child("user")
        .child(id)
        .child("shoppingCart").child(partNo).child("buyQty").set(amt);
    reference
        .child("user")
        .child(id)
        .child("shoppingCart").child(partNo).child("totalPrice").set(totalPrice);

  }

  calculateTotal() async {
    preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id');
    reference
        .child("user")
        .child(id)
        .child("shoppingCart")
        .once()
        .then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      totalAmt = 0;
      setState(() {
        values.forEach((key, data) async {
          totalAmt += data['totalPrice'];
        });
      });
      print("=====================================================length === " +
          totalAmt.toString());
    });
  }

  deleteItem(String partNo) async{
    preferences = await SharedPreferences.getInstance();
    String id = preferences.getString('id');
    reference
        .child("user")
        .child(id)
        .child("shoppingCart").child(partNo).remove();

  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserID();
    calculateTotal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        elevation: 0.1,
        backgroundColor: Colors.red,
        title: Text(AppTranslations.of(context).text("shoppingBasket")),
        centerTitle: true,
      ),
      body: Container(
        child: FutureBuilder(
          future: reference
              .child("user")
              .child(userID)
              .child("shoppingCart")
              .once(),
          builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
            if (snapshot.hasData) {
              cartItems.clear();
              Map<dynamic, dynamic> values = snapshot.data.value;
              if(values != null){
                values.forEach((key, value) {
                  ItemInCart item = new ItemInCart(
                      value['partNo'],
                      value['buyQty'],
                      value['img'],
                      value['unitPrice'],
                      value['totalPrice'],
                      value['type']);
                  cartItems.add(item);
                  print(cartItems.length.toString() +
                      "=============CURRERN LENGHTH IS===========");
                });
              }
              else{
                return Center(child: Text("The Cart is Empty"),);
              }

              return ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  return Slidable(
                    actionPane: SlidableDrawerActionPane(),
                    child: Card(
                      elevation: 5,
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        height: 100.0,
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 100.0,
                              width: 70.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(5),
                                      topLeft: Radius.circular(5)),
                                  image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: NetworkImage(
                                          cartItems[index].img))),
                            ),
                            Container(
                              height: 100,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 2, 0, 0),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          cartItems[index].partNo,
                                          style: TextStyle(fontSize: 20),
                                        ),
                                        Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(0, 3, 0, 3),
                                          child: Container(
                                            width: 100,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.teal),
                                                borderRadius:
                                                BorderRadius.all(
                                                    Radius.circular(10))),
                                            child: Text(
                                              cartItems[index].type,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                          EdgeInsets.fromLTRB(0, 5, 0, 2),
                                          child: Container(
                                            width: 160,
                                            child: Text(
                                              "\$" +
                                                  cartItems[index]
                                                      .unitPrice
                                                      .toString(),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.redAccent),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "Qty: " +
                                              cartItems[index]
                                                  .buyQty
                                                  .toString(),
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: 'Edit',
                        color: Colors.black45,
                        icon: Icons.more_horiz,
                        onTap: (){
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Edit Buy Quantity'),
                                  content: TextField(
                                    controller: myController,
                                    keyboardType: TextInputType.number,
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
                                          updateCartItem(cartItems[index].partNo, int.parse(myController.text),cartItems[index].unitPrice );
                                          Navigator.pop(context);
                                          calculateTotal();
                                          initState();

                                        }),
                                  ],
                                );
                              });
                        },
                      ),
                      IconSlideAction(
                        caption: 'Delete',
                        color: Colors.blue,
                        icon: Icons.delete,
                        onTap: (){
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete this item'),
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
                                          getCartItemAmount();

                                          deleteItem(cartItems[index].partNo);
                                          Navigator.pop(context);
                                          calculateTotal();
                                          initState();
                                        }),
                                  ],
                                );
                              });
                        },
                      ),
                    ],
                  );
                },
              );
            }
            return Center(child: CircularProgressIndicator(),);
          },
        ),
      ),
      bottomNavigationBar: new Container(
        color: Colors.white,
        child: Row(
          children: <Widget>[
            Expanded(
              child: ListTile(
                title: new Text("Total"),
                subtitle: Text(
                  totalAmt.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
                child: new FlatButton(
              onPressed: () {
                if(totalAmt == 0 ){
                  showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Erorr!'),
                          content: Text(
                            "The Cart is Empty",
                            style: TextStyle(fontSize: 19),
                          ),
                          actions: <Widget>[

                            FlatButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ],
                        );
                      });
                }

                else
                  Navigator.push(context,  MaterialPageRoute(builder: (context) => Checkout(userID, totalAmt)));

                },
              child: new Text(
                "Check Out",
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.redAccent,
            ))
          ],
        ),
      ),
    );
  }
}
