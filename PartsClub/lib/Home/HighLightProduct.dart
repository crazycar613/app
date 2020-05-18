import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newmap2/ChangeLanguage/app_translations.dart';

import '../Models/Part.dart';
import '../Models/Product.dart';
import '../Product/ProductDetail.dart';
import 'ProductDetail.dart';

class HighlightProduct extends StatefulWidget {

  _HighlightProductState createState() => _HighlightProductState();

}

class _HighlightProductState extends State<HighlightProduct> {
  DatabaseReference reference = FirebaseDatabase.instance.reference();

  List<Part> _partsDetails = [];
  Part p;
  Future<void> getAllParts() async {

    reference.child("Parts").once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> map = snapshot.value;
      List<dynamic> list = map.values.toList()..sort((a, b) => b['buyCount'].compareTo(a['buyCount']));

      setState(() {
        for(int i =0; i < list.length ; i ++){
          p = Part (list[i]['partNo'],list[i]['price'],list[i]['img'],list[i]['stockQty'],list[i]['buyCount'],list[i]['type'],list[i]['model']);
          _partsDetails.add(p);
          print(_partsDetails[i].buyCount);
        }

      });
    });
  }

  void initState() {
    super.initState();
//    getAllParts();

  }

  Widget build(BuildContext context) {


    double fontSize =  MediaQuery.of(context).size.height * 0.0155;
    double h =  MediaQuery.of(context).size.height;
//    for(int i = 0; i < _partsDetails.length ; i ++){
//      print(_partsDetails[i].buyCount);
//    }
    Container product(Part p){
      return Container(

          padding: new EdgeInsets.all(10.0),
          child: new Card(
              color: Color.fromRGBO(224, 224, 224, 1),
              child: new Column(

                children: <Widget>[

                  new Material(
                    child: new InkWell(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => new ProductDetail(
                                p: p,
                                isInCart: true,
                              ))),
                      child: Container(
                        width: 1200,
                        height: h*0.158,
                        decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(p.img, ),),
                        ),
                      ),
                    ),
                  ),
                  new Container(

                    child:  Padding (padding: const EdgeInsets.all(8.0),
                      child: new Text(
                        p.partNo,
                        style: new TextStyle(fontSize: fontSize,fontWeight: FontWeight.w900),
                      ) ,),
                  )


                ],
              )));
    }

    return new Container(
        child:  StreamBuilder(
            stream: FirebaseDatabase.instance
                .reference()
                .child("Parts")
                .onValue,
            builder: (BuildContext context, AsyncSnapshot<Event> snapshot) {
              if (snapshot.hasData) {
                Map<dynamic, dynamic> map = snapshot.data.snapshot.value;
                List<dynamic> list = map.values.toList()..sort((a, b) => b['buyCount'].compareTo(a['buyCount']));
                double price = 0;
                for(int i =0; i < list.length ; i ++){

                  p = Part (list[i]['partNo'],double.parse(list[i]['price'].toString()),list[i]['img'],int.parse(list[i]['stockQty'].toString()),int.parse(list[i]['buyCount'].toString()),list[i]['type'],list[i]['model']);
                  _partsDetails.add(p);

                }
                return GridView.builder(

                  shrinkWrap:true,
                  primary: false,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: 4,
                  padding: EdgeInsets.all(5.0),
                  itemBuilder: (BuildContext context, int index) {
                    return product(_partsDetails[index]);
                  },
                );
              } else {
                return CircularProgressIndicator();
              }
            }));
  }
}




