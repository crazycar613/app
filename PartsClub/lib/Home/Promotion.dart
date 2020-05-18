import 'package:flutter/material.dart';
import 'package:newmap2/Product/ProductList.dart';


import 'HighLightProduct.dart';
import 'PartsAccessories.dart';
import 'ViewMoreProduct.dart';
import 'News.dart';
import '../Models/Part.dart';
import 'package:firebase_database/firebase_database.dart';
import '../ChangeLanguage/app_translations.dart';
import 'PromotionSlider2.dart';

void Promotion() => runApp(MyPromotion());

class MyPromotion extends StatefulWidget {

  _MyPromotionState createState() => _MyPromotionState();

}

class _MyPromotionState extends State<MyPromotion> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: new ListView(
          padding:  const EdgeInsets.all(0),

          children: <Widget>[
            promotionSlider2(),

            new Padding(padding: const EdgeInsets.only(left: 20.0,top: 0.0,right: 0.0,bottom: 10.0),
              child: new Text(AppTranslations.of(context).text("news"), style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
            ),
            News(),
            new Padding(padding: const EdgeInsets.only(left: 20.0,top: 20.0,right: 20.0,bottom: 0.0),
                child: Row (
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(AppTranslations.of(context).text("highlightProduct"), style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold)),
                      SizedBox(width: 100.0,),
                      InkWell(
                        child : Text(AppTranslations.of(context).text("viewMore"), style: TextStyle(color: Colors.blueAccent)),
                        onTap: () {Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProductList()),
                        );},
                      )])),
            HighlightProduct(),
            new Padding(padding: const EdgeInsets.only(left: 20.0,top: 10.0,right: 0.0,bottom: 10.0),
              child: new Text(AppTranslations.of(context).text("genuinePartIntro"), style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
            ),

            new Padding(padding: EdgeInsets.only(left: 20.0,top: 8.0,right: 20.0,bottom: 8.0),

            //  child: InkWell( //**
                child: PartsAccessories(),
//                onTap: () {Navigator.push(
//                  context,
//                  MaterialPageRoute(builder: (context) => HomeVideo(),fullscreenDialog: false),
//                );},
            //  ),
            ),





          ],
        ),
    );
  }
}