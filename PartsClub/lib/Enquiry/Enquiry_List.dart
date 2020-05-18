import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_formatter/time_formatter.dart';

class EnquiryList extends StatefulWidget{
  EnquiryListState createState() => EnquiryListState();
}

class EnquiryListState extends State<EnquiryList>{
  List<ListOfEnquiry> _enquiryList = [];
  final DatabaseReference ref = FirebaseDatabase.instance.reference().child("enquiry");
  SharedPreferences prefs;
  String userID;

  Future<Null> getEnquiryData() async{
    ref.once().then((DataSnapshot snapshot){
      Map<dynamic,dynamic> values = snapshot.value;
      setState(() {
        values.forEach((key,values)async{
          ListOfEnquiry LE = new ListOfEnquiry(
              values["Inquiry"],
              values["PartsID"],
              values["PartsName"],
              values["Status"],
              values["brand"],
              values["chassisNum"],
              values["timestamp"]
          );
          if(userID == values['userID']){
            _enquiryList.add(LE);
          }
        });
      });
    });
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('id');
    setState(() {});
  }

  void initState(){
    super.initState();
    readLocal();
    getEnquiryData();
  }


  formatTheTime(String timestamp){
    var times = int.parse(timestamp);
    var processingTime =  formatTime(times);
    return processingTime;
  }

  Widget _buildPanel(){
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded){
        setState(() {
          _enquiryList[index].isExpanded = !isExpanded;
        });
      },

      children: _enquiryList.map<ExpansionPanel>((ListOfEnquiry item){
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded){
            return ListTile(
                title: Text("Enquiry ID: "+item.timestamp,style: TextStyle(fontWeight: FontWeight.bold),),
                subtitle: (item.Status == "response")
                    ? Text(item.Status,style: TextStyle(color: Colors.green))
                    : Text(item.Status,style: TextStyle(color: Colors.red))
            );
          },

          body: ListTile(
              title: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text("Parts ID: ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.grey)),
                        (item.PartsID == "")
                            ? Text("You are no input in parts ID.")
                            : Text(item.PartsID),
                      ],
                    ),

                    Row(
                      children: <Widget>[
                        Text("Parts Name: ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.grey)),
                        (item.PartsName == "")
                            ? Text("You are no input in parts name.")
                            : Text(item.PartsName)
                      ],
                    ),

                    Row(
                      children: <Widget>[
                        Text("Chassis Number: ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.grey)),
                        (item.chassisNum == "")
                            ? Text("You are no input in chassis number")
                            : Text(item.chassisNum),
                      ],
                    ),

                    Row(
                      children: <Widget>[
                        Text("Brand:",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.grey)),
                        Text(item.Brand)
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text("Inquiry: ",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.grey)),
                      ],
                    ),
                    Text(item.Inquiry),
                  ],
                ),
              ),
              subtitle: Container(
                alignment: FractionalOffset(1.0,0.0),
                child: Text(
                  formatTheTime(item.timestamp).toString(),
                  overflow: TextOverflow.ellipsis,
                  style: (TextStyle(fontSize: 17)),
                ),
              )
            //trailing:
          ),
          isExpanded: item.isExpanded,
          canTapOnHeader: true,
        );
      }).toList(),
    );
  }

  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Enquiry History"),
          backgroundColor: Colors.red,
        ),

        body: SingleChildScrollView(
          child: Container(
            child: _buildPanel(),
          ),
        )
    );
  }
}

class ListOfEnquiry{
  String Inquiry;
  String PartsID;
  String PartsName;
  String Status;
  String Brand;
  String chassisNum;
  String timestamp;
  bool isExpanded;
  ListOfEnquiry(Inquiry,PartsID,PartsName,Status,Brand,chassisNum,timestamp) {
    this.Inquiry = Inquiry;
    this.PartsID = PartsID;
    this.PartsName = PartsName;
    this.Status = Status;
    this.Brand = Brand;
    this.chassisNum = chassisNum;
    this.timestamp = timestamp;
    this.isExpanded = false;
  }
}

