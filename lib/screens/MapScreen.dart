import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  void initState() {
    super.initState();
  }
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(18.5204, 73.8567),
    zoom: 13,
  );

  List<Marker> markers = <Marker>[
    Marker(
      markerId: MarkerId('01'),
      position: LatLng(18.5204,73.9399),
      infoWindow: InfoWindow(
          title: 'Amanora', snippet: 'Pune'),
      onTap: () {},
    ),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        child: Text("Close"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          }),

    );
  }
}
