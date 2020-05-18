
import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:simple_pdf_viewer/simple_pdf_viewer.dart';


class News extends StatefulWidget {
  @override
  _NewsState createState() => _NewsState();
}



class _NewsState extends State<News> {

  List<New> _NewsList = [];
  DatabaseReference db = FirebaseDatabase.instance.reference();
  New n ;
  String pathPDF = "";
  Future<Null> getNews() async {

    db = FirebaseDatabase.instance.reference().child("News");
    db.once().then((DataSnapshot snapshot){

      Map<dynamic, dynamic> values = snapshot.value;
      setState(() {
        values.forEach((key,values) async{
          n = new New(values['title'],values['imgURL'],values['pdfURL']);
          _NewsList.add(n);
//          print(values['title']);
//          print(values['imgURL']);
//          print(values['pdfURL']);
        });
      });
    });
  }



  @override
  void initState() {
    super.initState();
    getNews();

  }
  @override
  Widget build(BuildContext context) {

    Container MyNews (String image, String title, String pdf){
      return Container(
        width:240.0 ,
        child: new InkWell(
          onTap: ()  => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PDFScreen(pdf)),
          ),
          child:Card(
            child: Wrap(
              children: <Widget>[

                Image.network(image,height: 143,),

                ListTile(
                  title: Text(title,style: TextStyle(fontSize: 14.0)),
                  contentPadding: EdgeInsets.only(left: 5.0,top: 0.0,right: 5.0,bottom: 0.0),
                )

              ],
            ),
          ),
        ),
      );
    }

    Widget getNewsListWidgets(List<New> _NewsList)
    {
      List<Widget> list = new List<Widget>();
      for(var i = 0; i < _NewsList.length; i++){
        list.add( MyNews(_NewsList[i].imgURL,_NewsList[i].title,_NewsList[i].pdfURL));
      }
      return new Row(children: list);
    }

    return Container(
      padding:EdgeInsets.only(left: 20.0,top: 0.0,right: 20.0,bottom: 0.0),

      height:220,
      child:ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[

          getNewsListWidgets(_NewsList)
        ],
      ),
    );
  }
}



class New {
  String title;
  String imgURL;
  String pdfURL;
  New(this.title, this.imgURL,this.pdfURL);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'imgURL': imgURL,
      'pdfURL':pdfURL,
    };
    return map;
  }

  New.fromMap(Map<String, dynamic> map) {
    title = map['title'];
    imgURL = map['imgURL'];
    pdfURL = map['pdfURL'];
  }

}

class PDFScreen extends StatelessWidget {
  String pathPDF = "";
  PDFScreen(this.pathPDF);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: Colors.red,
            //`true` if you want Flutter to automatically add Back Button when needed,
            //or `false` if you want to force your own back button every where
            title: Text("Document", style: TextStyle(fontSize: 18.0)),
            leading: IconButton(icon:Icon(Icons.arrow_back),
              onPressed:() => Navigator.pop(context, false),
            )
        ),
        body: SimplePdfViewerWidget(
          completeCallback: (bool result){
            print("completeCallback,result:${result}");
          },
          initialUrl: pathPDF,
        ),
      ),
    );
  }
}