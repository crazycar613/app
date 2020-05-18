import 'package:flutter/material.dart';
import 'package:flutter_pdf_viewer/flutter_pdf_viewer.dart';
import 'package:newmap2/ChangeLanguage/app_translations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

import 'News.dart';
import 'PartsAccVideo.dart';


class PartsAccessories extends StatefulWidget {
  @override
  _PartsAccessoriesState createState() => _PartsAccessoriesState();
}

class _PartsAccessoriesState extends State<PartsAccessories> {

  @override

  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: () {Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PartsAccPage(),fullscreenDialog: false),
        );},
        child: Container(
          width: 30.0,
          height: 51.0,
          padding: const EdgeInsets.only(left: 40.0,top: 20.0,right: 40.0,bottom: 30.0),
          decoration: new BoxDecoration(
            color: const Color(0xff7c94b6),
            image: new DecorationImage(
              image: new AssetImage('images/partsAccessories.jpg'),
              fit: BoxFit.cover,
            ),
            borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
            border: new Border.all(
              color: Colors.black,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}


class PartsAccPage extends StatefulWidget {
  @override
  PartsAccPage_State createState() => PartsAccPage_State();
}

class PartsAccPage_State extends State<PartsAccPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.red,
          //`true` if you want Flutter to automatically add Back Button when needed,
          //or `false` if you want to force your own back button every where
          title: Text(AppTranslations.of(context).text("genuinePartIntro"), style: TextStyle(fontSize: 18.0),textAlign: TextAlign.center ),
          leading: IconButton(icon:Icon(Icons.arrow_back),
            onPressed:() => Navigator.pop(context, false),
          )
      ),
      body: new ListView(
          padding:  const EdgeInsets.all(0),

          children: <Widget>[
            PartsAccPDF("images/partsAccPDF2.jpg",AppTranslations.of(context).text("PATit1"),context),
            PartsAccNews("images/PartsAccNews1.jpg",AppTranslations.of(context).text("PATit2"),"https://hk.on.cc/cn/bkn/cnt/news/20160530/bkncn-20160530141841603-0530_05011_001.html",context),
            PartsAccNews("images/PartsAccNews3.jpg",AppTranslations.of(context).text("PATit3"),"https://www.chinatimes.com/realtimenews/20170119003644-260402?chdtv",context),

            new Padding(padding: const EdgeInsets.only(left: 23.0,top: 10.0,right: 23.0,bottom: 10.0),
              child: new Text(AppTranslations.of(context).text("videoTit1"), style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
            ),
            Video(
              videoPlayerController: VideoPlayerController.asset(
                'images/partsAccVideo1.mp4',
              ),
              looping: true,
            ),
            new Padding(padding: const EdgeInsets.only(left: 23.0,top: 10.0,right: 23.0,bottom: 10.0),
              child: new Text(AppTranslations.of(context).text("videoTit2"), style: TextStyle(fontSize: 16.0,fontWeight: FontWeight.bold),),
            ),
            Video(
              videoPlayerController: VideoPlayerController.asset(
                'images/partsAccVideo2.mp4',
              ),
              looping: true,
            ),
          ]
      ),
    );
  }
}

Container PartsAccPDF (String image, String title, BuildContext context){
  return Container(
    height: 295,
    padding: EdgeInsets.only(left: 23.0,top: 10.0,right: 23.0,bottom: 10.0),
    child: new InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PDFScreen("https://firebasestorage.googleapis.com/v0/b/inchcape-f3895.appspot.com/o/GeniuePart.pdf?alt=media&token=98567b9f-5183-4da9-aae6-df9a3d156fba")),
        );
      }
      ,child:Card(
        child: Wrap(
          children: <Widget>[
            new Container(
              width: 1000,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(image, ),),
              ),
            ),
            ListTile(
              title: Text(title),
            )
          ],
        ),
      ),
    ),
  );
}

Container PartsAccNews (String image, String title, String link, BuildContext context){
  return Container(
    height: 295,
    padding: EdgeInsets.only(left: 23.0,top: 10.0,right: 23.0,bottom: 10.0),
    child: new InkWell(
      onTap: () => launch(link),
      child:Card(
        child: Wrap(
          children: <Widget>[
            new Container(
              width: 1000,
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(image)),
              ),
            ),
            ListTile(
              title: Text(title),
              subtitle: Text(AppTranslations.of(context).text("clickViewMore"),textAlign: TextAlign.right,),
            ),
          ],
        ),
      ),
    ),
  );
}