import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:newmap2/Map/NewMap.dart';
import '../ChangeLanguage/app_translations.dart';
import 'package:url_launcher/url_launcher.dart';

class newBranchList extends StatefulWidget {
  _newBranchListState createState() => _newBranchListState();
}

class _newBranchListState extends State<newBranchList>{
  String area = "NT";
  bool button1 = true;
  bool button2 = false;
  bool button3 = false;

  void _button1() {
    setState(() {
      button1 = true;
      button2 = false;
      button3 = false;
      area = "NT";
    });
  }

  void _button2() {
    setState(() {
      button1 = false;
      button2 = true;
      button3 = false;
      area = "KL";
    });
  }

  void _button3() {
    setState(() {
      button1 = false;
      button2 = false;
      button3 = true;
      area = "HK";
    });
  }

  List<CarType> _carTypes = CarType.getType();
  List<DropdownMenuItem<CarType>>_dropdownMenuItem;
  CarType _selectedType;

  void initState() {
    super.initState();
    _dropdownMenuItem = buildDropdownMenuItems(_carTypes);
    _selectedType = _dropdownMenuItem[0].value;
  }

  onChangeDropDownItem(CarType selectType){
    setState(() {
      _selectedType = selectType;
    });
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
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ButtonTheme(
                  minWidth: width*0.3,
                  child: RaisedButton(onPressed: () {
                    _button1();
                  },
                    color: button1 ? Colors.red : Colors.orangeAccent,
                    child: Row(
                      children: <Widget>[
                        Text(AppTranslations.of(context).text("NewTerritories"), style: TextStyle(color: Colors.white,fontSize: 13),)
                      ],
                    ),
                  ),
                ),
                ButtonTheme(
                  minWidth: width*0.3,
                  child: RaisedButton(onPressed: (){
                    _button2();
                  },
                    color: button2 ? Colors.red : Colors.orangeAccent,
                    child: Row(
                      children: <Widget>[
                        Text(AppTranslations.of(context).text("Kowloon"),style: TextStyle(color: Colors.white,fontSize: 13),),
                      ],
                    ),
                  ),
                ),
                ButtonTheme(
                  minWidth: width*0.3,
                  child: RaisedButton(onPressed: (){
                    _button3();
                  },
                    color: button3 ? Colors.red : Colors.orangeAccent,
                    child: Row(
                      children: <Widget>[
                        Text(AppTranslations.of(context).text("HongKong"),style: TextStyle(color: Colors.white,fontSize: 13),),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Text("品牌 : " ,style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),),
              Container(
                margin: EdgeInsets.only(top: 15),
                height: 60,
                padding: const EdgeInsets.only(left: 20),
                alignment: Alignment.topLeft,
                child: DropdownButton(
                  items: _dropdownMenuItem,
                  value: _selectedType,
                  onChanged: onChangeDropDownItem,
                ),
              ),
            ],
          ),

          (area == "NT")
            ?Column(
              children: <Widget>[
                (_selectedType.TypeOfCar.toString()=="Toyota"||_selectedType.TypeOfCar.toString()=="All")
                ?myGridItems(AppTranslations.of(context).text("BranchAddress1"),"images/newBranch1.PNG", AppTranslations.of(context).text("Time1"),"2880 4468",context,22.444759,114.002412,"images/slogo_toyota.png")
                :Container(),

                (_selectedType.TypeOfCar.toString()=="Hino"||_selectedType.TypeOfCar.toString()=="All")
                ?myGridItems(AppTranslations.of(context).text("BranchAddress2"),"images/newBranch2.PNG", AppTranslations.of(context).text("Time2"),"2841 8540",context,22.443870,114.001218,"images/slogo_hino.png")
                :Container(),
              ],
            )
            :Container(),

          (area == "NT")
            ?Column(
              children: <Widget>[
                (_selectedType.TypeOfCar.toString()=="Toyota"||_selectedType.TypeOfCar.toString()=="All")
                ?myGridItems(AppTranslations.of(context).text("BranchAddress3"), "images/newBranch3.PNG", AppTranslations.of(context).text("Time3"), "2825 5242", context, 22.391136, 114.209156,"images/slogo_toyota.png")
                :Container(),
              ],
            )
            :Container(),

          (area == "NT")
            ?Column(
              children: <Widget>[
                (_selectedType.TypeOfCar.toString()=="Hino"||_selectedType.TypeOfCar.toString()=="All")
                ?myGridItems(AppTranslations.of(context).text("BranchAddress4"), "images/newBranch4.PNG", AppTranslations.of(context).text("Time4"), "2823 3221", context, 22.371979, 114.108721,"images/slogo_hino.png")
                :Container(),

                (_selectedType.TypeOfCar.toString()=="Toyota"||_selectedType.TypeOfCar.toString()=="All")
                ?myGridItems(AppTranslations.of(context).text("BranchAddress5"), "images/newBranch5.PNG", AppTranslations.of(context).text("Time5"), "2828 4510", context, 22.372969, 114.110093,"images/slogo_toyota.png")
                :Container(),
              ],
            )
            :Container(),

            (area == "NT")
              ?Column(
                children: <Widget>[
                  (_selectedType.TypeOfCar.toString()=="Lexus"||_selectedType.TypeOfCar.toString()=="All")
                  ?myGridItems(AppTranslations.of(context).text("BranchAddress6"), "images/newBranch6.PNG", AppTranslations.of(context).text("Time6"), "2880 4915", context, 22.369928, 114.132729,"images/slogo_lexus.png")
                  :Container(),
                ],

              )
              :Container(),

            (area == "KL")
              ?Column(
                children: <Widget>[
                  (_selectedType.TypeOfCar.toString()=="Toyota"||_selectedType.TypeOfCar.toString()=="All")
                  ?myGridItems(AppTranslations.of(context).text("BranchAddress7"), "images/newBranch7.PNG", AppTranslations.of(context).text("Time7"), "2821 7333", context, 22.323296, 114.205822,"images/slogo_toyota.png")
                  :Container(),
                ],
              )
              :Container(),

            (area == "KL")
              ?Column(
                children: <Widget>[
                  (_selectedType.TypeOfCar.toString()=="Toyota"||_selectedType.TypeOfCar.toString()=="All")
                  ?myGridItems(AppTranslations.of(context).text("BranchAddress8"), "images/newBranch8.PNG", AppTranslations.of(context).text("Time8"), "2825 5299", context, 22.312893, 114.223569,"images/slogo_toyota.png")
                  :Container(),
                ],
              )
              :Container(),

            (area == "HK")
              ?Column(
                children: <Widget>[
                  (_selectedType.TypeOfCar.toString()=="Toyota"||_selectedType.TypeOfCar.toString()=="All")
                  ?myGridItems(AppTranslations.of(context).text("BranchAddress9"), "images/newBranch9.PNG", AppTranslations.of(context).text("Time9"), "2880 1584", context, 22.287437, 114.190614,"images/slogo_toyota.png")
                  :Container(),
                ],
              )
              :Container(),

            (area == "KL" || area == "HK")
                ?(_selectedType.TypeOfCar.toString()=="Hino" || _selectedType.TypeOfCar.toString()=="Lexus")
                  ?Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 140,
                        margin: EdgeInsets.only(top: 40),
                        child: Text(AppTranslations.of(context).text("NoBranchInHere"),style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                  :Container()
                :Container(),
        ],
      ),

    );
  }

  Widget myGridItems(String Address, String gridimage,String Time,String Phone,BuildContext context,double lat,double long,String branchIcon) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      back: Container(
        margin: EdgeInsets.only(top: 20, right: 20, left: 20),
        height: height*0.4,
        decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, 0),
              radius: 0.9,
              colors: [Colors.white, Colors.white60],
            ),
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26.withOpacity(.2),
                  blurRadius: 10,
                  spreadRadius: 5),
            ]),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(right: 10,top:10,),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Icon(Icons.arrow_back,size: 30,),
                ],
              ),
            ),


            Container(
              margin: const EdgeInsets.only(left: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30),
                  RaisedButton(
                    onPressed: ()=> launch("tel://"+Phone),
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                        alignment: Alignment.center,
                        width: width*0.5,
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
                              margin: EdgeInsets.only(right: width*0.06),
                              child: Icon(
                                Icons.call,
                              ),
                            ),
                            Text(
                              AppTranslations.of(context).text("CallUSBtn"),
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        )
                    ),
                  ),
                  const SizedBox(height: 30),
                  RaisedButton(
                    onPressed: (){
                      Navigator.push(context,MaterialPageRoute(builder: (context)=> NewMap(lat: lat,long: long,img: gridimage,address: Address)));
                    },
                    textColor: Colors.white,
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                        alignment: Alignment.center,
                        width: width*0.5,
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
                              margin: EdgeInsets.only(right: width*0.06),
                              child: Icon(
                                FontAwesomeIcons.locationArrow,
                              ),
                            ),
                            Text(
                              AppTranslations.of(context).text("LocationBtn"),
                              style: TextStyle(fontSize: 20),
                            ),
                          ],
                        )
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),


      front: Container(
        margin: EdgeInsets.only(top: 10, right: 20, left: 20,bottom: 20),
        height: height*0.40,
        decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, 0),
              radius: 0.9,
              colors: [Colors.white,Colors.white],
            ),
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26.withOpacity(.2),
                  blurRadius: 10,
                  spreadRadius: 5),
            ]
        ),
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Image.asset(branchIcon),
                    padding: EdgeInsets.only(left: 10),
                  ),
                  Container(
                    width: 30,
                    height: 38,
                    child: Icon(
                      Icons.arrow_forward,size: 30,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 10),
                  padding: EdgeInsets.only(left: 5,top:10),
                  child: Image.asset(gridimage,height:height*0.3,width:width*0.3, fit: BoxFit.fill,),
                ),
                Column(
                  children: <Widget>[
                    Container(
                      width: width*0.5,
                      child: Text(AppTranslations.of(context).text("Address"),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),),
                    ),
                    Text(Address,style: TextStyle(fontSize: 10)),
                    Container(
                      width: width*0.5,
                      child:Text(AppTranslations.of(context).text("OpeningTime"),style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                    ),
                    Text(Time,style: TextStyle(fontSize: 10)),
                    Container(
                      width: width*0.5,
                      child: Text(AppTranslations.of(context).text("CallUs")+Phone,style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}

class CarType{
  String TypeOfCar;
  CarType(this.TypeOfCar);
  static List<CarType> getType(){
    return <CarType>[
      CarType("All"),
      CarType("Toyota"),
      CarType("Lexus"),
      CarType("Hino"),
    ];
  }
}