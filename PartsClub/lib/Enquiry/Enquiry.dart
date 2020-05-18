import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import '../Overlay/mydrawer.dart';
import '../ChangeLanguage/app_translations.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspaths;
import 'FQA.dart';
import 'Private.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Enquriy extends StatefulWidget{
  EnquriyState createState() => EnquriyState();
}

class EnquriyState extends State<Enquriy> {
  final _formKey = GlobalKey<FormState>();
  String problem;

  List<CarType> _carTypes = CarType.getType();
  List<DropdownMenuItem<CarType>>_dropdownMenuItem;
  CarType _selectedType;

  //Select mulite images
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';
  //Get SharePreferences value
  SharedPreferences prefs;
  String userID;

  void initState() {
    super.initState();
    _dropdownMenuItem = buildDropdownMenuItems(_carTypes);
    _selectedType = _dropdownMenuItem[0].value;
    readLocal();
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('id');
    setState(() {});
  }


  File _storedImage;
  var txt = TextEditingController();
  var ModelTxt = TextEditingController();
  var PartsNameTxt = TextEditingController();
  var PartsIDTxt = TextEditingController();
  var InquiryTxt = TextEditingController();

  //Select Mulite Image
  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = List<Asset>();
    String error = 'No Error Dectected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 6,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );

      for (var r in resultList) {
        var t = await r.identifier;
        print(t);
      }
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  //Read the carPlate
  Future<void>_takePicture() async{
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
    );
    setState(() {
      _storedImage = imageFile;
    });
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final fileName = path.basename(imageFile.path);
    final savedImage = await imageFile.copy('${appDir.path}/$fileName');

    readText();
  }



  Future readText() async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(_storedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);

    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          if(word.text.length==17)
            txt.text = word.text;

        }
      }
    }
  }


  List<DropdownMenuItem<CarType>> buildDropdownMenuItems(List carTypes){
    List<DropdownMenuItem<CarType>> items = List();
    for(CarType ct in carTypes){
      items.add(DropdownMenuItem(
        value: ct,
        child: Text(ct.TypeOfCar),
      ),
      );
    }
    return items;
  }


  onChangeDropDownItem(CarType selectType){
    setState(() {
      _selectedType = selectType;
      print(selectType.TypeOfCar);
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.of(context).text("enquiry")),
        backgroundColor: Colors.red,
        actions: <Widget>[
          IconButton(icon:Icon(Icons.perm_contact_calendar), onPressed: (){
            Navigator.push(context,MaterialPageRoute(builder: (context)=> Private()));
          }),
        ],
      ),
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      body: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  Image.asset("images/newBranch1.PNG",width: double.infinity,height: 150,fit: BoxFit.cover,)
                ],
              ),

              Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 15.0,left: 15.0),
                    alignment: Alignment.topLeft,
                    child: Text(AppTranslations.of(context).text("Brand"),style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold),),
                  ),
                  Container(
                    height: 60,
                    padding: const EdgeInsets.only(left: 20),
                    alignment: Alignment.bottomRight,
                    child: DropdownButton(
                      items: _dropdownMenuItem,
                      value: _selectedType,
                      onChanged: onChangeDropDownItem,
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(top: 15.0,left: 15.0),
                    alignment: Alignment.topLeft,
                    child: Text(AppTranslations.of(context).text("Model"),style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold),),
                  ),
                ],
              ),

              Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 30,right: 30),
                    width: MediaQuery.of(context).size.width-60,
                    child: TextField(
                      controller: ModelTxt,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: AppTranslations.of(context).text("modle"),
                      ),
                    ),
                  ),

                ],
              ),

              Container(
                margin: const EdgeInsets.only(top: 15.0,left: 15.0),
                alignment: Alignment.topLeft,
                child: Text(AppTranslations.of(context).text("ChassisNumber"),style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold),),
              ),

              Row(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 30,right: 30),
                    width: MediaQuery.of(context).size.width-60,
                    child: TextField(
                      controller: txt,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: AppTranslations.of(context).text("YourChassisNumber"),
                        suffixIcon: IconButton(icon: Icon(Icons.camera_alt), onPressed: (){_takePicture();},iconSize: 20,),
                      ),
                    ),
                  ),

                ],
              ),

              Container(
                margin: const EdgeInsets.only(top: 15.0,left: 15.0),
                alignment: Alignment.topLeft,
                child: Text(AppTranslations.of(context).text("PartsName"),style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold),),
              ),

              Container(
                margin: const EdgeInsets.only(left: 30,right: 30),
                width: MediaQuery.of(context).size.width-30,
                child: TextField(
                  controller: PartsNameTxt,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: AppTranslations.of(context).text("AskName"),
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 15.0,left: 15.0),
                alignment: Alignment.topLeft,
                child: Text(AppTranslations.of(context).text("PartsID"),style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold),),
              ),

              Container(
                margin: const EdgeInsets.only(left: 30,right: 30),
                width: MediaQuery.of(context).size.width-30,
                child: TextField(
                  controller: PartsIDTxt,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: AppTranslations.of(context).text("AskID"),
                  ),
                ),
              ),

              Container(
                margin: const EdgeInsets.only(top: 15.0,left: 15.0),
                alignment: Alignment.topLeft,
                child: Text(AppTranslations.of(context).text("YourInquiry"),style: TextStyle(color: Colors.red,fontSize: 20,fontWeight: FontWeight.bold),),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  border: Border.all(color: Colors.red, width: 1.0),
                ),
                padding: const EdgeInsets.only(left: 10),
                margin: const EdgeInsets.all(10),
                width: 250,
                child:TextField(
                  controller: InquiryTxt,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration:InputDecoration(
                    hintText: AppTranslations.of(context).text("YourInquiry"), border: InputBorder.none,
                  ),
                ),
              ),


              //TestingCam(),
              Container(
                height: 200,
                child: Column(
                  children: <Widget>[
                    RaisedButton(
                      child: Text(AppTranslations.of(context).text("PickImage")),
                      onPressed: loadAssets,
                    ),
                    Expanded(
                      child: buildGridView(),
                    )
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(20),
                child: RaisedButton(
                  color: Colors.redAccent,
                  textColor: Colors.white,
                  onPressed: (){
                    //ShowDialog(context,_selectedType,ModelTxt,txt,PartsNameTxt,PartsIDTxt,InquiryTxt,images);
                    CreateNewEnquiry(context,_selectedType,ModelTxt,txt,PartsNameTxt,PartsIDTxt,InquiryTxt,images,userID);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(AppTranslations.of(context).text("submit"),style: TextStyle(fontSize: 16),),
                    ],
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }



}

class CarType{
  String TypeOfCar;
  CarType(this.TypeOfCar);
  static List<CarType> getType(){
    return <CarType>[
      CarType("Toyota"),
      CarType("Lexus"),
      CarType("Daihatsu"),
      CarType("Hino"),
    ];
  }
}

void CreateNewEnquiry(context, CarType seletedType,ModelTxt,txt,PartsNameTxt,PartsIDTxt,InquiryTxt,images,userID){
  String ID = DateTime.now().millisecondsSinceEpoch.toString();
  final databaseReference = FirebaseDatabase.instance.reference();
  if(ModelTxt.text != "" && txt.text != "" && InquiryTxt.text != ""){
    //Save to Firebase
    databaseReference.child("enquiry/"+ID).set({
      "brand":seletedType.TypeOfCar,
      "model":ModelTxt.text,
      "chassisNum":txt.text,
      "PartsName":PartsNameTxt.text,
      "PartsID":PartsIDTxt.text,
      "Inquiry":InquiryTxt.text,
      "Status":"No response",
      "timestamp":ID,
      "img":"",
      "userID":userID,
      "Status":"No response",
      "ResponseAns":" ",
      "subject":" "
    });

    int i = 0;
    for(Asset a in images){
      saveImage(a,ID,userID,i);
      i++;
    }
    ShowUpDateSuccessfulDialog(context);
  }else{
    ShowDialog(context, AppTranslations.of(context).text("EnquiryHis"));
  }
}

void ShowUpDateSuccessfulDialog(BuildContext context){
  showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Update Successful'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text("Thank you for your question!"),
                Text("We will reply you as soon as possible")
              ],
            ),
          ),
          actions: [
            FlatButton(
              child: Text("OK"),
              onPressed: (){
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
  );
  Navigator.of(context).pop();
}

void ShowDialog(BuildContext context,message){
  var alertDialog = AlertDialog(

    title: Text("Submit Failed"),
    content: SingleChildScrollView(
      child: Container(
        child: Text("You should input model, chassis number and inquiry"),
      ),
    ),
  );

  showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context){
        return alertDialog;
      }
  );
}

Future saveImage(Asset asset,ID,userID,count) async{
  String filename = DateTime.now().millisecondsSinceEpoch.toString();
  StorageReference reference = FirebaseStorage.instance.ref().child("Enquiry/"+filename);
  ByteData byteData = await asset.getByteData();
  List<int> imageData = byteData.buffer.asUint8List();
  StorageUploadTask uploadTask = reference.putData(imageData);
  var imageUrl = "This is testing";
  StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
  storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl){
    imageUrl = downloadUrl;
    ImageUrlInFirebase(imageUrl,ID,userID,count);
  });
}

Future ImageUrlInFirebase(url,ID,userID,count){
  final databaseReference = FirebaseDatabase.instance.reference();
  databaseReference.child("enquiry/"+ID+"/img").update({
    count.toString():url
  });
}