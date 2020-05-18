
import 'package:flutter/material.dart';
import 'package:newmap2/Models/Part.dart';
import 'package:newmap2/Product/ProductDetail.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:newmap2/ShoppingCart/CartList.dart';
import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

class SearchProduct extends StatefulWidget {

  String category, searchType;
  SearchProduct(this.searchType,this.category);

  @override
  _SearchProductState createState() => _SearchProductState();
}

class _SearchProductState extends State<SearchProduct> {
  List<Part> parts = [];
  final DatabaseReference ref =
  FirebaseDatabase.instance.reference().child("Parts");

  String category;
  String searchCate;

  TextEditingController controller = new TextEditingController();
  List<Part> _searchResult = [];
  List<Part> _partsDetails = [];
  List _outputs;
  File _image;
  bool _loading = false;
  Icon actionIcon = new Icon(Icons.search);
  Widget appBarTitle = new Text("Product List");



  Future<Null> getUserDetails() async {
    ref.orderByChild(widget.searchType).equalTo(widget.category).once().then((DataSnapshot snapshot) {
      Map<dynamic, dynamic> values = snapshot.value;
      setState(() {
        values.forEach((key, values) async {
          Part p = new Part(
              values["partNo"],
              values["price"],
              values["img"],
              values["stockQty"],
              values["buyCount"],
              values["type"],
              values["model"]);
          _partsDetails.add(p);
        });
      });
    });
  }



  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _loading = true;
    getUserDetails();

    loadModel().then((value) {
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: appBarTitle,
          actions: <Widget>[
            IconButton(
                icon: actionIcon,
                color: Colors.white,
                onPressed: () {
                  setState(() {
                    if (this.actionIcon.icon == Icons.search) {
                      this.actionIcon = new Icon(Icons.close);
                      this.appBarTitle = new TextField(
                        controller: controller,
                        cursorColor: Colors.black,
                        autofocus: true,
                        style: TextStyle(color: Colors.white),
                        decoration: new InputDecoration(
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                                icon: Icon(
                                  Icons.image,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  controller.clear();
                                  pickImage();
                                })),
                        onChanged: onSearchTextChanged,
                      );
                    } else {
                      this.actionIcon = new Icon(Icons.search);
                      this.appBarTitle = new Text("Product List");
                    }
                  });
                }),
            IconButton(
              icon: Icon(Icons.shopping_cart),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => CartList()));
              },
            )
          ],
        ),
        body: new Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder(
                  future: ref.orderByChild(widget.searchType).equalTo(widget.category).once(),
                  builder: (context, AsyncSnapshot<DataSnapshot> snapshot) {
                    if (snapshot.hasData) {
                      parts.clear();
                      Map<dynamic, dynamic> values = snapshot.data.value;
                      values.forEach((key, values) {
                        Part p = new Part(
                            values["partNo"],
                            double.parse(values["price"].toString()),
                            values["img"],
                            int.parse(values["stockQty"].toString()),
                            int.parse(values["buyCount"].toString()),
                            values["type"],
                            values["model"]);
                        parts.add(p);
                      });
                      if (_searchResult.length != 0 ||
                          controller.text.isNotEmpty) {
                        return ListView.builder(
                            itemCount: _searchResult.length,
                            itemBuilder: (context, index) {
                              return UI(_searchResult[index]);
                            });
                      } else {
                        return ListView.builder(
                          itemBuilder: (context, index) {
                            return UI(parts[index]);
                          },
                          itemCount: parts.length,
                        );
                      }
                    }
                    if (null == snapshot.data) {
                      return Center(child: SpinKitFadingCircle(
                        itemBuilder: (BuildContext context, int index) {
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: index.isEven ? Colors.red : Colors.blue,
                            ),
                          );
                        },
                      ));
                    }
                    return CircularProgressIndicator();
                  }),
            ),
          ],
        ));
  }

  // AI Module
  pickImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _loading = true;
      _image = image;
    });
    classifyImage(image);
  }

  classifyImage(File image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _loading = false;
      _outputs = output;
      controller.text = _outputs[0]["label"].toString().split(" ")[1];
    });
    onSearchTextChanged(_outputs[0]["label"].toString().split(" ")[1]);
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
    print("====================LOADED MODEL!!!!=======================");

  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  // end of ai

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _partsDetails.forEach((part) {
      if (part.partNo.toString().contains(text) ||
          part.type.contains(text) ||
          part.model.contains(text)) _searchResult.add(part);
    });

    setState(() {});
  }
  Widget UI(Part p) {
    return new GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => new ProductDetail(
                p: p,
                isInCart: true,
              ))),
      child: Card(
        elevation: 5,
        child: Container(
          height: 100.0,
          child: Row(
            children: <Widget>[
              Container(
                height: 100.0,
                width: 70.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(5), topLeft: Radius.circular(5)),
                    image:
                    DecorationImage(fit: BoxFit.contain, image: NetworkImage(p.img))),
              ),
              Container(
                height: 100,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 2, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        p.partNo,
                        style: TextStyle(fontSize: 20),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.teal),
                              borderRadius:
                              BorderRadius.all(Radius.circular(10))),
                          child: Text(
                            p.type,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 5, 0, 2),
                        child: Container(
                          width: 160,
                          child: Text(
                            "\$" + p.price.toString(),
                            style: TextStyle(
                                fontSize: 20, color: Colors.redAccent),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
