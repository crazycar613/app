import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class FQA extends StatefulWidget{
  FQAState createState() => FQAState();
}

class FQAState extends State<FQA> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("FAQ"),
      ),
      body: WebView(
        initialUrl: "https://www.crown-motors.com/tch/aftersales/periodic_maintenance.aspx",
        onWebViewCreated: (WebViewController webViewController){
          _controller.complete(webViewController);
        },
      ),

    );
  }
}