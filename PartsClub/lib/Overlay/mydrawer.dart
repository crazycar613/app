import 'package:flutter/material.dart';
import 'package:newmap2/Enquiry/Enquiry_List.dart';

import 'package:newmap2/Login/LoginPage.dart';
import 'package:newmap2/OrderList/newOrderList.dart';
import 'package:newmap2/Product/ProductList.dart';
import 'package:newmap2/Profile/Profile.dart';
import 'package:newmap2/MainPage/Index.dart';
import 'package:newmap2/Enquiry/Enquiry.dart';
import 'package:newmap2/MainPage/Setting.dart';
import 'package:newmap2/ShoppingCart/CartList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ChangeLanguage/app_translations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../Enquiry/Feedback.dart';

import '../Coupon/page/PageOne.dart';


class MyDrawer extends StatefulWidget {
  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String userID = "" , companyAddress="" , companyName ="", username="",position="", contactNumber="", points="",deliveryAddress="",icon="";

  void initState() {
    super.initState();
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

    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.55,
      child: new Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.pink,
                    Colors.red,
                  ], //Color(0xFF99301c), Colors.red[600],],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Material(
                        borderRadius: BorderRadius.all(Radius.circular(80.0)),
                        elevation: 10,
                        child: Image.asset(
                          'images/inchcapesmalllogo.png',
                          width: 80,
                          height: 80,
                        ),
                      ),
                      AutoSizeText(
                          AppTranslations.of(context).text("cml"),
                          style: TextStyle(color: Colors.white, fontSize: 23.0),
                          minFontSize: 15,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1
                      ),
                    ],
                  ),
                ),
              ),
            ),
            CustomListTile(
                Icon(Icons.home), AppTranslations.of(context).text("home"), () {
              Route route =
              MaterialPageRoute(builder: (context) => Index());
              Navigator.of(context).pop();
              Navigator.push(context, route);
            }),
            CustomListTile(
                Icon(Icons.person), AppTranslations.of(context).text("profile"),
                    () {
                      Route route = MaterialPageRoute(builder: (context) => MyHomePage(userID: userID, companyAddress:companyAddress,companyName:companyName,
                          contactNumber:contactNumber,points:points,position:position,username:username,deliveryAddress:deliveryAddress,icon:icon));
                  Navigator.of(context).pop();
                  Navigator.push(context, route);
                }),

            CustomListTile(
                Icon(Icons.shopping_cart), AppTranslations.of(context).text("shoppingBasket"),
                    () {
                  Route route = MaterialPageRoute(builder: (context) => CartList());
                  Navigator.of(context).pop();
                  Navigator.push(context, route);
                }),

            CustomListTile(
                Icon(Icons.library_books), AppTranslations.of(context).text("order"),
                    () {
                  Route route = MaterialPageRoute(builder: (context) => NewOrder(userID));
                  Navigator.of(context).pop();
                  Navigator.push(context, route);
                }),

            CustomListTile(
                Icon(Icons.settings), AppTranslations.of(context).text("setting"),
                    () {
                  Route route = MaterialPageRoute(builder: (context) => Change());
                  Navigator.of(context).pop();
                  Navigator.push(context, route);
                }),
            CustomListTile(Icon(Icons.power_settings_new),
                AppTranslations.of(context).text("logout"), () async{
                SharedPreferences preferences;
                preferences = await SharedPreferences.getInstance();
                preferences.clear();
                Route route = MaterialPageRoute(builder: (context) => LoginPage());
                Navigator.of(context).pop();
                Navigator.push(context, route);
                }),

          ],
        ),
      ),
    );
  }
}

class CustomListTile extends StatelessWidget {
  Icon icon;
  String text;
  Function onTap;

  CustomListTile(this.icon, this.text, this.onTap);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          child: InkWell(
            splashColor: Colors.yellow[200],
            onTap: onTap,
            child: Container(
              height: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      icon,
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}