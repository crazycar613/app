
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdf_viewer/flutter_pdf_viewer.dart';
import 'package:newmap2/ChangeLanguage/app_translations.dart';

class SpecialNews extends StatefulWidget {
  @override
  _SpecialNewsState createState() => _SpecialNewsState();
}

class _SpecialNewsState extends State<SpecialNews> {
  List<CommonMessage> _CommonMessageList = [];
  DatabaseReference db = FirebaseDatabase.instance.reference().child("CommonMessage");
  CommonMessage cm ;
  Future<Null> getCommonMessage() async {



    db.once().then((DataSnapshot snapshot){
      Map<dynamic, dynamic> map = snapshot.value;
      List<dynamic> list = map.values.toList()..sort((a, b) => b['id'].compareTo(a['id']));


//      Map<dynamic, dynamic> values = snapshot.value;

      setState(() {
        for(int i =0; i < list.length ; i ++){
          cm = CommonMessage (list[i]['title'],list[i]['content'],list[i]['dateTime'],list[i]['id']);
          _CommonMessageList.add(cm);
        }
      });
    });
  }

  void initState() {
    super.initState();
    setState(() {
      getCommonMessage();
    });


  }

  @override
  Widget build(BuildContext context) {
//    Widget getNewsListWidgets(List<CommonMessage> _CommonMessageList)
//    {
//
//      List<Widget> list = new List<Widget>();
//      Container c = new Container();
//      for(var i = 0   ; i < _CommonMessageList.length; i++){
//        c = (SNews(_CommonMessageList[i].title,_CommonMessageList[i].content,_CommonMessageList[i].dateTime,_CommonMessageList[i].isReaded,context));
//        print(_CommonMessageList[i].isReaded);
//      }
//      return c;
//
//    }

    return new Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: true,
            backgroundColor: Colors.red,
            //`true` if you want Flutter to automatically add Back Button when needed,
            //or `false` if you want to force your own back button every where
            title: Text(AppTranslations.of(context).text("news"), style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center ),
            leading: IconButton(icon:Icon(Icons.arrow_back),
              onPressed:() => Navigator.pop(context, false),
            )
        ),
        body: new ListView(
            children: <Widget>[
//

              new Column(
                children: List.generate(_CommonMessageList.length,(i){
                  return SNews(_CommonMessageList[i].title,_CommonMessageList[i].content,_CommonMessageList[i].dateTime,context);
                }),
              ),
//          for(int i=0;i < _CommonMessageList.length; i ++ ) SNews(_CommonMessageList[i].title,_CommonMessageList[i].content,_CommonMessageList[i].dateTime,context)

//          SNews(AppTranslations.of(context).text("spnews1tit"),AppTranslations.of(context).text("spnews1"),context),
//          SNews(AppTranslations.of(context).text("spnews2tit"),AppTranslations.of(context).text("spnews2"),context)
            ]
        ));
  }
}


Container SNews (String title, String content,String dateTime, BuildContext context){
  return Container(
    height: 150,
    padding: EdgeInsets.only(left: 0.0,top: 10.0,right: 0.0,bottom: 0.0),
    child: new InkWell(
      onTap: ()  => {},
      child:Card(
        child: Wrap(
          children: <Widget>[
            ListTile(
              title: Text(title, style: TextStyle(fontSize: 14.0,fontWeight: FontWeight.bold),),
              subtitle: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      height:60,
                      child:new Padding(padding: const EdgeInsets.only(left: 0.0,top: 15.0,right: 0.0,bottom: 0.0),
                          child: new Text(content, style: TextStyle(fontSize: 13.0,color: Colors.black),)),
                    ),
                    new Row(
                      children: <Widget>[
                        new Container(
                          width :150,
                          child: Padding(padding: const EdgeInsets.only(left: 0.0,top: 20.0,right: 0.0,bottom: 0.0),
                              child: new Text(dateTime,textAlign: TextAlign.left,)),
                        ),

//                        new Padding(padding: const EdgeInsets.only(left: 165.0,top: 20.0,right: 0.0,bottom: 0.0),
//                            child: new Text((isReaded=="true")?"Readed":"",textAlign: TextAlign.left,)),

                      ],
                    )


                  ]),
            ),
          ],
        ),
      ),
    ),
  );
}


class CommonMessage {
  String title;
  String content;
  String dateTime;
  int id;

  CommonMessage(this.title, this.content,this.dateTime,this.id);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'content': content,
      'dateTime' : dateTime,
      'id' : id,

    };
    return map;
  }

  CommonMessage.fromMap(Map<String, dynamic> map) {
    title = map['title'];
    content = map['content'];
    dateTime = map['dateTime'];
    id = map['id'];
  }

}