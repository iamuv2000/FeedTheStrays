import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Utils/save_marker.dart';

import './MarkerInfoScreen.dart';
import './MyMarkerScreen.dart';
import 'package:location/location.dart';
import 'dart:math' show cos, sqrt, asin;

import 'package:geocoder/geocoder.dart';




final _fireStore = Firestore.instance;

class GoogleMapScreen extends StatefulWidget {
  GoogleMapScreen({this.firebaseUser});
  FirebaseUser firebaseUser;
  Location location = new Location();
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  void initState() {
    super.initState();
    _getLocation();
  }
  Completer<GoogleMapController> _controller = Completer();

  static double latitude;
  static double longitude;

  CameraPosition _kGooglePlex ;

  List<Marker> markers = <Marker>[

  ];

  List<Circle> circles = <Circle>[

  ];

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 +
        c(lat1 * p) * c(lat2 * p) *
            (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }


  void _getLocation() async {
    LocationData loc = await widget.location.getLocation();
    getAllMarkers();
    print(loc);
    latitude = loc.latitude;
    longitude = loc.longitude;
//    final coordinates=new Coordinates(latitude, longitude);
//    var address=await Geocoder.local.findAddressesFromCoordinates(coordinates);
//    var first=address.first;
//    //print('${first.locality}, ${first.adminArea}, ${first.subLocality}, ${first.addressLine},  ' );
//    print('${first.addressLine}');
//isko remove karna hai

    setState(() {
      _kGooglePlex = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 13,
      );
      final circle = Circle(
        circleId: CircleId("curr_loc"),
        center: LatLng(loc.latitude, loc.longitude),
        fillColor: Colors.blueAccent,
          strokeColor: Colors.blueAccent,
        radius: 5,
        zIndex: 100,

      );
      final circleBackground = Circle(
        circleId: CircleId("curr_loc_bg"),
        center: LatLng(loc.latitude, loc.longitude),
        strokeColor: Color.fromRGBO(230, 230, 230, 1),
        radius: 18,
        zIndex: 10,

      );
      circles.add(circle);
      circles.add(circleBackground);
    });
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(loc.latitude, loc.longitude),
        zoom: 17.0,
      ),
    ));
  }

  Future <void> getAllMarkers () {
    markers = [];
    print("Getting marker data");
    _fireStore.collection('markers').getDocuments()
        .then((QuerySnapshot snapshot) => {
    snapshot.documents.forEach((markerData) => {
      setState((){
        var maxFoodDelay = new DateTime.now().subtract(new Duration(days: 1));
        var lastFed = DateTime.fromMillisecondsSinceEpoch(markerData.data["FedAt"].seconds *1000);
        markers.add(Marker(
          markerId: MarkerId(markerData.data["markerId"]),
          position: LatLng(markerData.data["latitude"],markerData.data["longitude"]),
          infoWindow: InfoWindow(
              title: markerData.data["title"], snippet: markerData.data["address"]),
          onTap: () {
            showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => SingleChildScrollView(
                    child:Container(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: MarkerInfoScreen(lastFed: lastFed ,isFedEver:  markerData.data["isFedEver"], markerId: markerData.data["markerId"], firebaseUser: widget.firebaseUser, updateMarkerView : getAllMarkers())
                    )
                )
            );
          },
            flat: true,
            draggable: true,
          icon: BitmapDescriptor.defaultMarkerWithHue
            (
              lastFed.isBefore(maxFoodDelay)
                  ?
                  0
                  :
              120.0
          )
        ),
        );
      })

    }),
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(

        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text("${widget.firebaseUser.displayName}"),
                accountEmail: Text("${widget.firebaseUser.email}"),
                currentAccountPicture: CircleAvatar(
                  backgroundColor:
                  Theme.of(context).platform == TargetPlatform.iOS
                      ? Colors.blue
                      : Colors.white,
                  backgroundImage: NetworkImage(
                    widget.firebaseUser.photoUrl,
                  ),
                  radius: 60,
                ),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                ),
              ),
              ListTile(
                title: Text('Map'),
                leading: Icon(Icons.gps_fixed),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.location_on),
                title: Text('My markers'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return MyMarkerScreen(firebaseUser: widget.firebaseUser);
                  }));
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(

            title : Text(
                'Feed The Strays',
              style: TextStyle(
                  color: Colors.white
              ),
            )
        ),
        body: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            circles: Set<Circle>.of(circles),
            markers: Set<Marker>.of(markers),
            myLocationButtonEnabled: false,
            onTap: (LatLng location)  async{
              showDialog(
                  context: context,
                  builder: (BuildContext context) {

                   double totalDistance = calculateDistance(location.latitude, location.longitude,latitude, longitude);
                   print(totalDistance);

                   if(totalDistance > 0.5){
                     return AlertDialog(
                       title: Text("Location too far"),
                       content: Text("Sorry, the tapped location must be under 500m to mark location"),
                       actions: <Widget>[
// usually buttons at the bottom of the dialog
                         FlatButton(
                           child: Text("Cancel"),
                           onPressed: () {
                             Navigator.of(context).pop();
                           },
                         ),
                       ],
                     );
                   }
                   else{
                     return AlertDialog(
                       title: Text("Add location?"),
                       content:Text("Are you sure you want to add the tapped location (" + location.latitude.toString()+ " , " + location.longitude.toString()+ ")  to indicate the location of a stray dog"),
                       actions: <Widget>[
// usually buttons at the bottom of the dialog
                         FlatButton(
                           child: Text("Cancel"),
                           onPressed: () {
                             Navigator.of(context).pop();
                           },
                         ),
                         FlatButton(
                           child: Text(
                             "Add",
                             style: TextStyle(
                                 fontWeight: FontWeight.w700
                             ),
                           ),
                           onPressed: () {
                             saveMarker(location , widget.firebaseUser);
                             getAllMarkers();
                             Navigator.of(context).pop();
                             getAllMarkers();
                           },
                         ),
                       ],
                     );
                   }
                  });
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: _getLocation,
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          tooltip: 'Get Location',
          child: Icon(
              Icons.gps_fixed,
            color: Colors.blueGrey
          ),
        ),
      ),
    );
  }
}
