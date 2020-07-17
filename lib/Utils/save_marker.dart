import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:geocoder/geocoder.dart';


final _fireStore = Firestore.instance;

void saveMarker(LatLng location, FirebaseUser user) async{
  print("Saving marker data to db!");
  print(location);
  var uuid = Uuid();
  var markerId = uuid.v4();
  final coordinates=new Coordinates(location.latitude, location.longitude);
  var address=await Geocoder.local.findAddressesFromCoordinates(coordinates);
  var first=address.first;
  await _fireStore.collection('markers').document(markerId).setData({
    "markerId": markerId,
    "latitude" : location.latitude,
    "longitude" : location.longitude,
    "title" : first.addressLine,
    "address": first.postalCode,
    "createdDate" : new DateTime.now(),
    "FedAt" :   DateTime.now().subtract(new Duration(days: 1)),
    "createdBy" : user.uid,
    "isFedEver" : false,
    "createdByName" : user.displayName
  });

}
