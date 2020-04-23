import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';


final _fireStore = Firestore.instance;

void saveMarker(LatLng location, FirebaseUser user) async{
  print("Saving marker data to db!");
  print(location);
  var uuid = Uuid();
  var markerId = uuid.v4();
  await _fireStore.collection('markers').document(markerId).setData({
    "markerId": markerId,
    "latitude" : location.latitude,
    "longitude" : location.longitude,
    "title": "Amanora",
    "snippet" : "Pune",
    "createdDate" : new DateTime.now(),
    "createdBy" : user.uid,
    "isFed" : false
  });

}