import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageScreen extends StatelessWidget {

  final String slider;
  ImageScreen(this.slider);
  @override

  Widget build(BuildContext context) {


    return Scaffold(
            appBar: AppBar(
                automaticallyImplyLeading: true,
                backgroundColor: Colors.black,
                //`true` if you want Flutter to automatically add Back Button when needed,
                //or `false` if you want to force your own back button every where
                title: Text('  '),
                leading: IconButton(icon:Icon(Icons.arrow_back),
                  onPressed:() => Navigator.pop(context, false),
                )
            ),
          body:
        Container(
          child: PhotoView(
                imageProvider:NetworkImage(slider),
          )
        )
    );
  }
}