import 'dart:ui';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:newmap2/Coupon/page/PageOne.dart';
import 'package:newmap2/Enquiry/ChatRoom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home/SpecialNews.dart';
import 'package:newmap2/Map/newBranchList.dart';
import 'package:newmap2/Home/Promotion.dart';
import '../Overlay/mydrawer.dart';
import '../SearchPage/SearchPage.dart';
import 'dart:async';
import '../ChangeLanguage/app_translations.dart';

class Index extends StatefulWidget {
  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  var homePage = Icons.home;
  var searchPage = Icons.search;
  var notiPage = Icons.notifications;
  //var cam = Icons.camera_alt;
  var cart = Icons.shopping_basket;
  var storeLocationPage = Icons.location_on;
  var iconStyle = Icons.receipt;
  var PrimaryColor = Colors.red;
  var SecondaryColor = Colors.grey;
  var newStyleColor = Colors.red[100];
  String userID = "" , companyAddress="" , companyName ="", username="",position="",contactNumber = "" ,points = "", deliveryAddress="",icon="";
  int unreadedMsg = 0;

  final List<Widget> _page = [
    MyPromotion(),
    SearchPage(),
    PageOne(),
    newBranchList(),
  ];

  final StreamController<int> _countController = StreamController<int>.broadcast();

  DatabaseReference db = FirebaseDatabase.instance.reference().child("CommonMessage");
  DatabaseReference dbx = FirebaseDatabase.instance.reference().child("UnreadedMsg");
  CommonMessage cm ;
  int _currentIndex = 0;
  int _tabBarCount = 3;
  int _specialNewsCount = 0;
  List<CommonMessage> _CommonMessageList = [];

  Future<Null> getCommonMessage() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();


    db.once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> map = snapshot.value;
      List<dynamic> list = map.values.toList()..sort((a, b) => b['id'].compareTo(a['id']));



    });

    dbx.once().then((DataSnapshot snapshot){

      Map<dynamic, dynamic> values = snapshot.value;
      int i = 0 ;
      setState(() {
        values.forEach((key,values) async{
          i = int.parse(values);
          _specialNewsCount = i ;
          prefs.setInt('unreadMessage', _specialNewsCount);
        });
      });

    });
  }

  void updateUnreadedMessage () async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    dbx.update({"num":"0"});
    setState(() {
      prefs.setInt('unreadMessage', 0);
      _specialNewsCount = 0;
    });

  }

  void _selectPage(int index) {
    setState(() {

      _currentIndex = index;
      if(_currentIndex == 3){
        _tabBarCount = 0;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getCommonMessage();
    getDataFromSps();

  }

  getDataFromSps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userID = (prefs.getString('id'));
      companyAddress = (prefs.getString('companyAddress'));
      companyName = (prefs.getString('companyName'));
      username = (prefs.getString('username'));
      position = (prefs.getString('position') );
      contactNumber = (prefs.getString('contactNumber'));
      points = (prefs.getString('points'));
      deliveryAddress = (prefs.getString('deliveryAddress'));
      icon = (prefs.getString('icon'));
      unreadedMsg = (prefs.getInt('unreadMessage'));

    });
  }


  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return WillPopScope(
        onWillPop: () {
          return new Future(() => false);
        },
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.chat),
              backgroundColor: Colors.red,
              onPressed: () {Navigator.push(context,MaterialPageRoute(builder: (context) => Chat(enquiryID:"001",peerAvatar:"https://firebasestorage.googleapis.com/v0/b/inchcape-f3895.appspot.com/o/AdminIcon%2Finchcapesmalllogo.png?alt=media&token=4e76ae2b-25cb-4bfd-b182-fcd505ed69e0")));},
          ),
            appBar: AppBar(
              backgroundColor: Colors.red,
              title: Image.asset(AppTranslations.of(context).text("logo"), height:60,),
              centerTitle: true,
              actions: <Widget>[


                IconButton(
                  icon: new Stack(
                    children: <Widget>[
                      new IconButton(icon: Icon(Icons.notifications),color: Colors.white,padding: const EdgeInsets.only(left: 0.0,top: 0.0,right: 20.0,bottom: 0.0),
                          onPressed: () {
                            setState(() {
                              updateUnreadedMessage();

                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SpecialNews(),fullscreenDialog: false),
                            );
                          }),
                      _specialNewsCount != 0 ? new Positioned(
                        right: 5,
                        top: 5,
                        child: new Container(
                          decoration: new BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$_specialNewsCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ) : new Container()
                    ],
                  ),
                  onPressed: (){

                  },
                ),
              ],
            ),
            drawer: MyDrawer(),
            body:

            SafeArea(
              child: _page[_currentIndex],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _selectPage,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  activeIcon: Icon(
                    homePage,
                    color: PrimaryColor,
                  ),
                  icon: Icon(
                    homePage,
                    color: SecondaryColor,
                  ),
                  title: Text(
                    AppTranslations.of(context).text("home"),
                    style: TextStyle(color: PrimaryColor),
                  ),
                ),
                //, backgroundColor: Colors.black38
                BottomNavigationBarItem(
                  activeIcon: Icon(
                    searchPage,
                    color: PrimaryColor,
                  ),
                  icon: Icon(
                    searchPage,
                    color: SecondaryColor,
                  ),
                  title: Text(
                    AppTranslations.of(context).text("Search"),
                    style: TextStyle(color: PrimaryColor),
                  ),
                ),
                BottomNavigationBarItem(
                  activeIcon: Icon(
                    iconStyle,
                    color: PrimaryColor,
                  ),
                  icon: Icon(
                    iconStyle,
                    color: SecondaryColor,
                  ),
                  title: Text(
                    AppTranslations.of(context).text("Coupon"),
                    style: TextStyle(color: PrimaryColor),
                  ),
                ),
                BottomNavigationBarItem(
                  activeIcon: Icon(
                    storeLocationPage,
                    color: PrimaryColor,
                  ),
                  icon: Icon(
                    storeLocationPage,
                    color: SecondaryColor,
                  ),
                  title: Text(
                    AppTranslations.of(context).text("Find us"),
                    style: TextStyle(color: PrimaryColor),
                  ),
                ),
              ],
              type: BottomNavigationBarType.shifting,
            ))
    );
  }
}