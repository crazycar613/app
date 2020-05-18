import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class Private extends StatefulWidget{
  PrivateState createState() => PrivateState();
}

class PrivateState extends State<Private> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("Private"),
      ),
      body: WebView(
        initialUrl: "https://www.crown-motors.com/eng/main/legal_t.aspx",
        onWebViewCreated: (WebViewController webViewController){
          _controller.complete(webViewController);
        },
      ),

    );
  }
}