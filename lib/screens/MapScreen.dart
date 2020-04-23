import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../Utils/save_marker.dart';
final _fireStore = Firestore.instance;

class GoogleMapScreen extends StatefulWidget {
  GoogleMapScreen({this.firebase_user});
  FirebaseUser firebase_user;
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  void initState() {
    super.initState();
    getAllMarkers();
  }
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(18.5204, 73.8567),
    zoom: 13,
  );

  List<Marker> markers = <Marker>[

  ];

  void getAllMarkers () {
    print("Getting marker data");
    _fireStore.collection('markers').getDocuments()
        .then((QuerySnapshot snapshot) => {
    snapshot.documents.forEach((markerData) => {
      setState((){
        markers.add(Marker(
          markerId: MarkerId(markerData.data["markerId"]),
          position: LatLng(markerData.data["latitude"],markerData.data["longitude"]),
          infoWindow: InfoWindow(
              title: 'Amanora', snippet: 'Pune'),
          onTap: () {},
          icon: BitmapDescriptor.defaultMarkerWithHue(markerData.data["isFed"] ? 120.0 : 0 )
        ),
        );
      })

    }),
      print(markers)
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
            leading:  IconButton(
              icon: Icon(
                  Icons.ac_unit,
                color: Colors.orange,
              ),
            ),
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
            markers: Set<Marker>.of(markers),
            onTap: (LatLng location) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Map tapped!"),
                      content: Text("You tapped in " +
                          location.latitude.toString() +
                          ", " +
                          location.longitude.toString()),
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
                            saveMarker(location , widget.firebase_user);
                            getAllMarkers();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  });
            }),

      ),
    );
  }
}
