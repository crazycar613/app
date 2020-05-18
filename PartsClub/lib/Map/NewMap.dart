import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:android_intent/android_intent.dart';
import 'package:geolocator/geolocator.dart';
import '../ChangeLanguage/app_translations.dart';

class NewMap extends StatefulWidget {
  final double lat;
  final double long;
  final String img;
  final String address;
  NewMap({Key key, this.lat, this.long, this.img, this.address})
      :super(key: key);
  NewMapState createState() => NewMapState(lat,long,img,address);
}

class NewMapState extends State<NewMap>{
  double lat;
  double long;
  String img;
  String address;
  NewMapState(this.lat,this.long,this.img,this.address);

  Geolocator geolocator = Geolocator();
  Position userLocation;
  String origin;

  void initState(){
    super.initState();
    _getLocation().then((position) {
      userLocation = position;
      origin = userLocation.latitude.toString() +"," +userLocation.longitude.toString();
    });
  }

  Completer<GoogleMapController> _controller = Completer();

  double zoomVal = 5.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildGoogleMap(context),
          _buildContainer(),
        ],
      ),
    );
  }

  Widget _buildContainer() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            SizedBox(width: 10.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _boxes(img, lat, long, address),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boxes(String _image, double lat, double long, String Address) {
    return GestureDetector(
      onTap: () {
        _gotoLocation(lat, long);
      },
      child: Stack(
        children: <Widget>[
          Material(
            color: Colors.white,
            elevation: 14.0,
            borderRadius: BorderRadius.circular(24.0),
            shadowColor: Color(0x802196F3),
            child: Row(
              children: <Widget>[
                Container(
                  width: 120,
                  height: 160,
                  padding: EdgeInsets.only(left: 8.0),
                  child: ClipRRect(
                    borderRadius: new BorderRadius.circular(24.0),
                    child: Image.asset(_image),
                  ),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: myDetailsContainer1(Address),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget myDetailsContainer1(String Address) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        SizedBox(height: 5.0),
        Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: Text(
                    Address,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14.0
                    ),
                  ),
                ),
              ],
            )
        ),

        SizedBox(height: 5.0),
        Container(
          child: Row(
            children: <Widget>[
              RaisedButton(
                onPressed: (){
                  String destination = lat.toString()+","+long.toString();
                  final AndroidIntent intent = new AndroidIntent(
                      action: 'action_view',
                      data: Uri.encodeFull(
                          "https://www.google.com/maps/dir/?api=1&origin=" +
                              "your location" + "&destination=" + destination + "&travelmode=driving&dir_action=navigate"),
                      package: 'com.google.android.apps.maps');
                  intent.launch();
                },
                textColor: Colors.white,
                padding: const EdgeInsets.all(0.0),
                child: Container(
                    alignment: Alignment.center,
                    width: width*0.3,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Colors.redAccent,
                          Colors.red,
                        ],
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    padding: const EdgeInsets.all(7.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(right: width*0.03),
                          child: Icon(
                            Icons.add_location,
                          ),
                        ),
                        Text(
                          AppTranslations.of(context).text("Navigate"),
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    )
                ),
              )
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildGoogleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
            target: LatLng(lat, long), zoom: 12),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: {
          _buildMarker(lat, long)
        },
      ),
    );
  }
  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  Future<void> _gotoLocation(double lat, double long) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(lat, long), zoom: 15, tilt: 50.0,
          bearing: 45.0,)));
  }

  Marker _buildMarker(double lat,double long){
    Marker brenchMarker1 = Marker(
      markerId: MarkerId('Brench1'),
      position: LatLng(lat, long),
      infoWindow: InfoWindow(title: 'Brench1'),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueViolet,
      ),
    );
    return brenchMarker1;
  }
}