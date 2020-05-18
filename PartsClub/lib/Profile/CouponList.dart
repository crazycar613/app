import 'package:flutter/material.dart';
import 'package:newmap2/ChangeLanguage/app_translations.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:newmap2/Models/Coupon.dart';
import 'package:newmap2/Models/UserCoupon.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AvailableCoupon extends StatefulWidget {
  String userid;

  AvailableCoupon(this.userid);

  @override
  State<StatefulWidget> createState() {
    return ListItemWidget();
  }
}

class ListItemWidget extends State<AvailableCoupon> {
  List<UserCoupon> userCoupons = [];
  List<Coupon> coupons = [];
  List<Coupon> filteredCp = [];

  // db object
  DatabaseReference userCouponRef;
  DatabaseReference couponRef =
      FirebaseDatabase.instance.reference().child("Coupon");

  Future<Null> getAllCoupons() async {
    couponRef.once().then((DataSnapshot snapshot) {
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

  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      userCouponRef = FirebaseDatabase.instance
          .reference()
          .child("user")
          .child(widget.userid)
          .child("coupon");
      getAllCoupons();
      print(coupons.length.toString() + "============ coupoon length");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "我的優惠券",
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
      ),
      body: Container(
          child: FutureBuilder(
              future: userCouponRef.once(),
              builder: ((context, AsyncSnapshot<DataSnapshot> snapshot) {
                if (snapshot.hasData) {
                  Map<dynamic, dynamic> values = snapshot.data.value;
                  userCoupons.clear();
                  filteredCp.clear();
                  values.forEach((key, values) {
                    UserCoupon uc = new UserCoupon(
                        values['couponNo'],
                        values['isUse'],
                        values['ExpiryDate']
                    );
                    userCoupons.add(uc);
                    for (Coupon c in coupons) {
                      if (values['couponNo'] == c.couponNo) {
                        filteredCp.add(c);
                      }
                    }
                  });
                  return ListView.builder(
                    itemCount: filteredCp.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        child: Container(

                          height: 100.0,
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: 100.0,
                                width: MediaQuery.of(context).size.width*0.2,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(5),
                                        topLeft: Radius.circular(5)),
                                    image: DecorationImage(
                                      colorFilter:  (userCoupons[index].isUse =='true')? ColorFilter.mode(Colors.grey, BlendMode.saturation):null,
                                        fit: BoxFit.scaleDown,
                                        image: NetworkImage(filteredCp[index].url))),
                              ),
                              Container(
                                height: 100,
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(10, 2, 0, 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      //display coupon name
                                      Text(
                                        filteredCp[index].couponName.toString(),
                                        style: TextStyle(fontWeight: FontWeight.bold,  color: (userCoupons[index].isUse =='true')? Colors.grey: Colors.black,),
                                      ),

                                      //display coupon expiry date
                                      Text((userCoupons[index].isUse =='true')?"Used":userCoupons[index].expiryDate.toString(), style: TextStyle(fontSize: 12,  color: (userCoupons[index].isUse =='true')? Colors.grey: Colors.redAccent, fontWeight: FontWeight.bold),),

                                      //display coupon desc
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(0, 5, 0, 2),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width*0.7,
                                          child: Text(
                                            filteredCp[index].description.toString(),
                                            style: TextStyle(
                                                fontSize: 13,
                                              color: (userCoupons[index].isUse =='true')? Colors.grey: Colors.black,),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                else{
                  return Center(child:  CircularProgressIndicator(),);
                }
              }))),
    );
  }
}
