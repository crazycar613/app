import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'ImageScreen.dart';

class promotionSlider2 extends StatefulWidget {
  @override
  _promotionSlider2State createState() => _promotionSlider2State();

}

class _promotionSlider2State extends State<promotionSlider2> {

  var sliderList;
  Timer timer;
  List<Slider> _SlideList = [];
  DatabaseReference db = FirebaseDatabase.instance.reference().child("Slider");
  Slider s ;
  static var  slider1 = { 'slider' :"images/poster2.png", 'leaflet' : "images/PromotionLeaflet1.jpg"};
  static var  slider2 = { 'slider' :"images/poster2.png", 'leaflet' : "images/PromotionLeaflet2.jpg"};
  static var  slider3 = { 'slider' :"images/poster3.png", 'leaflet' : "images/PromotionLeaflet3.jpg"};
  static var  slider4 = { 'slider' :"images/poster4.png", 'leaflet' : "images/PromotionLeaflet4.jpg"};

  CarouselSlider carouselSlider;

  var imgList = [
    slider1['slider'],
    slider2['slider'],
    slider3['slider'],
    slider4['slider'],
  ];
  int _current = 0;

  var sliderType,leaflet;



  Future<Null> getSlides() async {

    db = FirebaseDatabase.instance.reference().child("Slider");

    db.once().then((DataSnapshot snapshot){

      Map<dynamic, dynamic> values = snapshot.value;

      setState(() {
        values.forEach((key,values) async{
          s = Slider (values['slideURL'],values['detailURL']);
          _SlideList.add(s);

        });
      });

    });
  }


  @override
  void initState() {
    super.initState();
  getSlides();
    timer = new Timer.periodic(new Duration(seconds: 2), (Timer timer) {
    setState(() {
      slider1 = { 'slider' :_SlideList[0].slideURL, 'leaflet' : _SlideList[0].detailURL};
      slider2 = { 'slider' :_SlideList[1].slideURL, 'leaflet' : _SlideList[1].detailURL};
      slider3 = { 'slider' :_SlideList[2].slideURL, 'leaflet' : _SlideList[2].detailURL};
      slider4 = { 'slider' :_SlideList[3].slideURL, 'leaflet' : _SlideList[3].detailURL};
      imgList =  [
        slider1['slider'],
        slider2['slider'],
        slider3['slider'],
        slider4['slider'],
      ];
    });
    });
  }


  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
////
////    print(slider1);
////    print(slider2);
////    print(slider3);
////    print(slider4);
//    print(imgList);
    return Container(
      child: Column(
        children: <Widget>[
          carouselSlider = CarouselSlider(
            height: 210.0,
            autoPlay: true,
            viewportFraction: 1.0,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) {
              setState(() {
                _current = index;
              });
            },
            items: imgList.map((i) {
              return Builder(
                  builder: (BuildContext context) {
                    return Container(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        decoration: BoxDecoration(
                          color: Colors.green,
                        ),
                        child: GestureDetector(
                            child: Image.network(
                                i, fit: BoxFit.fill, width: 1000.0),
                            onTap: () {
                              sliderType = i ;
                              if (sliderType == slider1['slider']){
                                leaflet = slider1['leaflet'];
                              }
                              else if (sliderType == slider2['slider']){
                                leaflet = slider2['leaflet'];
                              }
                              else if (sliderType == slider3['slider']){
                                leaflet = slider3['leaflet'];
                              }
                              else if (sliderType == slider4['slider']){
                                leaflet = slider4['leaflet'];
                              }
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => ImageScreen(leaflet),
                                  fullscreenDialog: false),
                              );
                            }));
                  });
            }).toList(),

          ),
          Container(
//            height: 28.0, width: 1500.0, color: Colors.black.withOpacity(0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: map<Widget>(imgList, (index, url) {
                return Container(
                  width: 10.0,
                  height: 10.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),

                  decoration: BoxDecoration(

                    border: new Border.all(color: Colors.black, width: 0.5),
                    shape: BoxShape.circle,
                    color: _current == index ? Colors.white : Colors.black,
                  ),

                );
              }),
            ),
          )




        ],
      ),
    );
  }



  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }
}

class Slider {
  String slideURL;
  String detailURL;
  Slider(this.slideURL, this.detailURL);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'slideURL': slideURL,
      'detailURL': detailURL,
    };
    return map;
  }

  Slider.fromMap(Map<String, dynamic> map) {
    slideURL = map['slideURL'];
    detailURL = map['detailURL'];

  }

}
