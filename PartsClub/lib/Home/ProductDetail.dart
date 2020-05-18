import 'package:flutter/material.dart';
import 'package:newmap2/ChangeLanguage/app_translations.dart';

class Detail extends StatelessWidget {
  Detail({this.name, this.gambar,this.type,this.desc,this.price});

  final String name;
  final String gambar;
  final String type;
  final String desc;
  final int price;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
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
      body: new ListView(
        children: <Widget>[
          new Container(
            width: 650,
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/$gambar", ),),
            ),
          ),
          new ProductBox(
              name: name,
              type: type,
              desc: desc,
              price : price
          ),

        ],
      ),
    );
  }
}

class ProductBox extends StatelessWidget {
  ProductBox({this.name,this.type,this.desc,this.price});
  final String name;
  final String type;
  final String desc;
  final int price;
  final int _itemCount = 0;
  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: new EdgeInsets.all(10.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[

                new Padding(padding: const EdgeInsets.only(left: 20.0,top: 10.0,right: 0.0,bottom: 0.0),
                  child: new Text(name, style: TextStyle(fontSize: 18.0),),
                ),
                new Padding(padding: const EdgeInsets.only(left: 20.0,top: 5.0,right: 0.0,bottom: 10.0),
                  child: new Text(AppTranslations.of(context).text("priceTit") + " \$ $price" , style: TextStyle(fontSize: 18.0),),
                ),
                new Padding(padding: const EdgeInsets.only(left: 20.0,top: 5.0,right: 0.0,bottom: 10.0),
                  child: new Text(AppTranslations.of(context).text("typeTit") + "$type" , style: TextStyle(fontSize: 18.0),),
                ),
                new Padding(padding: const EdgeInsets.only(left: 20.0,top: 5.0,right: 0.0,bottom: 10.0),
                  child: new Text(AppTranslations.of(context).text("descTit") , style: TextStyle(fontSize: 18.0),),
                ),
                new Padding(padding: const EdgeInsets.only(left: 20.0,top: 0.0,right: 0.0,bottom: 10.0),
                  child: new Text("$desc" , style: TextStyle(fontSize: 18.0),),
                ),
                productQty(),
              ],
            ),
          ),
        ],
      )
      ,
    );
  }
}

class productQty extends StatefulWidget {
  @override
  _productQtyState createState() => _productQtyState();
}

class _productQtyState extends State<productQty> {
  @override
  int _itemCount = 0;
  final _controller = TextEditingController();


  @override
  void initState() {
    _controller.text = "$_itemCount";
    super.initState();
  }

  Widget build(BuildContext context) {

    return Container(

      child : new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Padding(padding: const EdgeInsets.only(left: 20.0,top: 10.0,right: 0.0,bottom: 10.0),
            child: new Text(AppTranslations.of(context).text("qty") , style: TextStyle(fontSize: 18.0),),
          ),
          new  IconButton(icon: new Icon(Icons.remove),onPressed: ()=>setState(()=>_itemCount--),),


          new Container(
            width: 80,

            child:   TextField(
              textAlign: TextAlign.center,
              controller:  new TextEditingController.fromValue(new TextEditingValue(text: "$_itemCount",selection: new TextSelection.collapsed(offset: "$_itemCount".length))),
              keyboardType: TextInputType.number,
              onChanged: (text) {
                _itemCount = int.parse(text);
              },
              decoration: new InputDecoration(


              ),

            ),
          ),
          new IconButton(icon: new Icon(Icons.add),onPressed: ()=>setState(()=>_itemCount++)),

          new RaisedButton(child: Text(AppTranslations.of(context).text("addToBasket")),
            onPressed: () {
              String msg = "";
              String title = "";
              if(_itemCount == 0){
                msg = AppTranslations.of(context).text("failContent");
                title = AppTranslations.of(context).text("failTitle");
              }
              else {
                msg = AppTranslations.of(context).text("successContent");
                title = AppTranslations.of(context).text("successTitle");
              }
              showDialog(
                context: context,
                builder: (BuildContext context) => CustomDialog(
                  title: title,
                  description:  msg,
                  buttonText: "確定",
                ),
              );
            },
            color: Colors.red,
            textColor: Colors.white,
            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
            splashColor: Colors.grey,
          ),
        ],
      ),
    );
  }
}





class CustomDialog extends StatelessWidget {
  final String title, description, buttonText;
  final Image image;

  CustomDialog({
    @required this.title,
    @required this.description,
    @required this.buttonText,
    this.image,
  });

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 20,
            left: 10,
            right: 10,
          ),
          margin: EdgeInsets.only(top: Consts.avatarRadius),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(Consts.padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 24.0),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }
}

class Consts {
  Consts._();
  static const double padding = 16.0;
  static const double avatarRadius = 66.0;
}