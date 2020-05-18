import 'package:flutter/material.dart';
import 'package:newmap2/Enquiry/FQA.dart';
import '../ChangeLanguage/app_translations.dart';
import '../ChangeLanguage/application.dart';
import '../Overlay/mydrawer.dart';

class Change extends StatefulWidget{
  ChangeState createState() => ChangeState();
}

class ChangeState extends State<Change> {
  bool Chinese;
  bool English;
  bool notification = true;
  static final List<String> languagesList = application.supportedLanguages;
  static final List<String> languageCodesList =
      application.supportedLanguagesCodes;

  final Map<dynamic, dynamic> languagesMap = {
    languagesList[0]: languageCodesList[0],
    languagesList[1]: languageCodesList[1],
  };

  void initState() {
    super.initState();
    Chinese = false;
    English = false;
  }

  void _onChange(bool value){
    setState(() {
      notification = value;
    });
  }

  void setLan(BuildContext context){
    if(AppTranslations.of(context).text("Chinese")== "中文")
      English = true;
    else
      English = false;
  }

  void setLanC(BuildContext context){
    if(AppTranslations.of(context).text("Chinese")== "Chinese")
      Chinese = true;
    else
      Chinese = false;
  }

  Widget build(BuildContext context) {
    setLan(context);
    setLanC(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.of(context).text("setting")),
        backgroundColor: Colors.red,
      ),
      drawer: MyDrawer(),
      body: ListView(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 10.0,left: 10.0, bottom: 20.0),
            child: Text(
              "語言:",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 40,right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("中文",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                Container(
                  child: Checkbox(
                    activeColor: Colors.redAccent,
                    value: Chinese,
                    onChanged: (bool value){
                      setState(() {
                        Chinese = value;
                        English = false;
                        application.onLocaleChanged(Locale(languagesMap[languagesList[0]]));
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.only(left: 40,right: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text("English",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                Checkbox(
                  activeColor: Colors.redAccent,
                  value: English,
                  onChanged: (bool value){
                    setState(() {
                      English = value;
                      Chinese = false;
                      application.onLocaleChanged(Locale(languagesMap[languagesList[1]]));
                    });
                  },
                ),
              ],
            ),
          ),

          Container(
            margin: EdgeInsets.all(40),
            child: RaisedButton(
              onPressed: (){
                Navigator.push(context,MaterialPageRoute(builder: (context)=> FQA()));
              },
              padding: EdgeInsets.all(0),
              textColor: Colors.white,
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Colors.redAccent,
                      Colors.red,
                    ],
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "常見問題",
                      style: TextStyle(fontSize: 20,color: Colors.white),
                    ),
                  ],
                ),
              ),

            ),
          ),

        ],
      ),
    );
  }
}