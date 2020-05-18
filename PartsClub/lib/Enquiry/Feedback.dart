import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../ChangeLanguage/app_translations.dart';

class FeedBack extends StatefulWidget{
  FeedBackState createState() => FeedBackState();
}

class FeedBackState extends State<FeedBack>{
  double sliderValue = 0.0;
  String myFeedbackText=" ";
  IconData myFeedback = FontAwesomeIcons.sadTear;
  Color myFeedbackColor = Colors.red;
  double rating;

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:Text(AppTranslations.of(context).text("FeeBackTitle")),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                child: Align(
                  child: Material(
                    color: Colors.white,
                    elevation: 14.0,
                    borderRadius: BorderRadius.circular(24.0),
                    shadowColor: Color(0x802196F3),
                    child: Container(
                      width: 350.0,
                      height: 320.0,
                      child: Column(children: <Widget>[
                        Container(child:Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(child: Text(AppTranslations.of(context).text("Question1"),
                            style: TextStyle(color: Colors.black, fontSize: 22.0,fontWeight:FontWeight.bold),)),
                        ),),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(child: Text(myFeedbackText,
                            style: TextStyle(color: Colors.black, fontSize: 22.0),)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(child: Icon(
                            myFeedback, color: myFeedbackColor, size: 100.0,)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(child: Slider(
                            min: 0.0,
                            max: 10.0,
                            divisions: 5,
                            value: sliderValue,
                            activeColor: Color(0xffe05f2c),
                            inactiveColor: Colors.blueGrey,
                            onChanged: (newValue) {
                              setState(() {
                                sliderValue = newValue;
                                if (sliderValue >= 0.0 && sliderValue <= 2.0) {
                                  myFeedback = FontAwesomeIcons.sadTear;
                                  myFeedbackColor = Colors.red;
                                  myFeedbackText = AppTranslations.of(context).text("Feeback1");
                                }
                                if (sliderValue >= 2.1 && sliderValue <= 4.0) {
                                  myFeedback = FontAwesomeIcons.frown;
                                  myFeedbackColor = Colors.yellow;
                                  myFeedbackText = AppTranslations.of(context).text("Feeback2");
                                }
                                if (sliderValue >= 4.1 && sliderValue <= 6.0) {
                                  myFeedback = FontAwesomeIcons.meh;
                                  myFeedbackColor = Colors.amber;
                                  myFeedbackText = AppTranslations.of(context).text("Feeback3");
                                }
                                if (sliderValue >= 6.1 && sliderValue <= 8.0) {
                                  myFeedback = FontAwesomeIcons.smile;
                                  myFeedbackColor = Colors.green;
                                  myFeedbackText = AppTranslations.of(context).text("Feeback4");
                                }
                                if (sliderValue >= 8.1 && sliderValue <= 10.0) {
                                  myFeedback = FontAwesomeIcons.laugh;
                                  myFeedbackColor = Colors.pink;
                                  myFeedbackText = AppTranslations.of(context).text("Feeback5");
                                }
                              });
                            },
                          ),),
                        ),
                      ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Align(
                  child: Material(
                    color: Colors.white,
                    elevation: 14.0,
                    borderRadius: BorderRadius.circular(24.0),
                    shadowColor: Color(0x802196F3),
                    child: Container(
                      width: 350.0,
                      height: 150.0,
                      margin: EdgeInsets.only(top: 10),
                      child: Column(
                        children: <Widget>[
                          Container(child:Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(child: Text(AppTranslations.of(context).text("Question2"),
                              style: TextStyle(color: Colors.black, fontSize: 22.0,fontWeight:FontWeight.bold),)),
                          ),),


                          RatingBar(
                            initialRating: 1.1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                this.rating = rating;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Align(
                  child: Material(
                    color: Colors.white,
                    elevation: 14.0,
                    borderRadius: BorderRadius.circular(24.0),
                    shadowColor: Color(0x802196F3),
                    child: Container(
                      width: 350.0,
                      height: 320.0,
                      margin: EdgeInsets.only(top: 10),
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 350.0,
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.only(left: 20),
                            child: Text(
                              AppTranslations.of(context).text("Question3"),
                              style: TextStyle(color: Colors.black, fontSize: 22.0,fontWeight:FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(20)) ,
                              border: Border.all(color: Colors.red, width: 1.0),
                            ),
                            child: TextField(
                              maxLines: 8,
                              decoration: InputDecoration.collapsed(hintText: AppTranslations.of(context).text("YourCommand")),
                            ),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const SizedBox(height: 30),
                              RaisedButton(
                                onPressed: (){
                                  ShowDialog(context);
                                },
                                textColor: Colors.white,
                                padding: const EdgeInsets.all(0.0),
                                child: Container(
                                    alignment: Alignment.center,
                                    width: 130,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: <Color>[
                                          Colors.redAccent,
                                          Colors.red,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                    ),
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(right: 10,left: 10),
                                          child: Icon(
                                            Icons.send,
                                          ),
                                        ),
                                        Text(
                                          AppTranslations.of(context).text("submit"),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    )
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),

        ],
      ),
    );
  }
  void ShowDialog(BuildContext context){
    var alertDialog = AlertDialog(
      title: Text(AppTranslations.of(context).text("YourFeebackSubmit")),
      content: Text(AppTranslations.of(context).text("Thanks")),
      actions: <Widget>[
        new FlatButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: new Text("Close"),
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context){
          return alertDialog;
        }
    );
  }
}