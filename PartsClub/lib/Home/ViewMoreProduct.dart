import 'package:flutter/material.dart';
import 'package:newmap2/ChangeLanguage/app_translations.dart';
import 'package:newmap2/Home/ProductDetail.dart';

class View extends StatelessWidget {
  @override

  Widget build(BuildContext context) {



    Container product(String name, String img, String type,String desc,int price){

      return Container(

          padding: new EdgeInsets.all(10.0),
          child: new Card(
              child: new Column(
                children: <Widget>[
                  new Hero(
                    tag: name,
                    child: new Material(
                      child: new InkWell(
                        onTap: () =>
                            Navigator.of(context).push(new MaterialPageRoute(
                              builder: (BuildContext context) => new Detail(
                                  name: name,
                                  gambar: img,
                                  type :  type,
                                  desc : desc,
                                  price : price
                              ),
                            )),
                        child: Container(
                          width: 1200,
                          height: 90,
                          decoration: BoxDecoration(image: DecorationImage(image: AssetImage("images/$img", ),),
                          ),
                        ),
                      ),
                    ),
                  ),
                  new Padding (padding: const EdgeInsets.all(2.0)),
                  new Text(
                    name,
                    style: new TextStyle(fontSize: 12.0),
                  )
                ],
              )));
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Promotion',
        home:Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: true,
                backgroundColor: Colors.black,
                //`true` if you want Flutter to automatically add Back Button when needed,
                //or `false` if you want to force your own back button every where
                title: Text(AppTranslations.of(context).text("highlightProduct"), style: TextStyle(fontSize: 18.0)),
                leading: IconButton(icon:Icon(Icons.arrow_back),
                  onPressed:() => Navigator.pop(context, false),
                )
            ),
            body:  new Container(
            child: new GridView.count(
            crossAxisCount: 2,
            shrinkWrap:true,
            primary: false,
            children: <Container>[
              product(AppTranslations.of(context).text("Product5"),"Diesel_injector.jpg","SN 5W-30",AppTranslations.of(context).text("desc1"),200),
             // product(AppTranslations.of(context).text("Product6"),"TF_TypeT-IV.jpg"," ",AppTranslations.of(context).text("desc1"),300),
             //product(AppTranslations.of(context).text("Product14"),"SNOW-20_motor_oil.jpg"," ",AppTranslations.of(context).text("desc1"),300),
              product(AppTranslations.of(context).text("Product7"),"Coolant.jpg"," ",AppTranslations.of(context).text("desc1"),500),
              product(AppTranslations.of(context).text("Product8"),"Fan_BladeA.jpg"," ",AppTranslations.of(context).text("desc1"),300),
              product(AppTranslations.of(context).text("Product9"),"ThermostatB.jpg"," ",AppTranslations.of(context).text("desc1"),300),
              product(AppTranslations.of(context).text("Product10"),"ThermostatA.jpg"," ",AppTranslations.of(context).text("desc1"),300),
              product(AppTranslations.of(context).text("Product11"),"Fan_BladeB.jpg"," ",AppTranslations.of(context).text("desc1"),500),
              product(AppTranslations.of(context).text("Product12"),"Carburetor_FlangeA.jpg"," ",AppTranslations.of(context).text("desc1"),500),
              product(AppTranslations.of(context).text("Product13"),"Carburetor_FlangeB.jpg"," ",AppTranslations.of(context).text("desc1"),500),
          ],
          childAspectRatio:1.2,
        ),
    )
            )
        )
    ;
  }
}









