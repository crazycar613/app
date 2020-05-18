import 'package:flutter/material.dart';
import 'package:newmap2/Login/LoginPage.dart';
import 'package:newmap2/MainPage/Index.dart';
import 'package:newmap2/Product/ProductList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ChangeLanguage/app_translations_delegate.dart';
import 'ChangeLanguage/application.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var id = prefs.getString('id');
  runApp(MaterialApp(debugShowCheckedModeBanner: false,home: id == null ? MyApp() : HomePage()));
}

class MyApp extends StatefulWidget {
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp>{
  AppTranslationsDelegate _newLocaleDelegate;
  final FirebaseMessaging _messaging = new FirebaseMessaging();



  void initState(){
    super.initState();
    _newLocaleDelegate = AppTranslationsDelegate(newLocale: null);
    application.onLocaleChanged = onLocaleChange;

    _messaging.getToken().then((token){
      print("\n"+token+"<---------token");
    });

    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },);

    _messaging.subscribeToTopic('Test');

  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          primaryColor: Colors.red,
        ),
        home: LoginPage(),

        localizationsDelegates: [
          _newLocaleDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale("zh",""),
          const Locale("en",""),
        ],
      ),
    );
  }
  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  AppTranslationsDelegate _newLocaleDelegate;
  final FirebaseMessaging _messaging = new FirebaseMessaging();



  void initState(){
    super.initState();
    _newLocaleDelegate = AppTranslationsDelegate(newLocale: null);
    application.onLocaleChanged = onLocaleChange;

    _messaging.getToken().then((token){
      print("\n"+token+"<---------token");
    });

    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },);

    _messaging.subscribeToTopic('Test');

  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(

      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          primaryColor: Colors.red,
        ),
        home: Index(),

        localizationsDelegates: [
          _newLocaleDelegate,
          GlobalMaterialLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale("zh",""),
          const Locale("en",""),
        ],
      ),
    );
  }
  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = AppTranslationsDelegate(newLocale: locale);
    });
  }
}

