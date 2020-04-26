import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final _fireStore = Firestore.instance;

void updateFeedStatus(FirebaseUser user, String markerId) async{
  print("Updating feed status to db!");

  await _fireStore.collection('markers').document(markerId).updateData({
    "FedAt" :   DateTime.now(),
    "isFedEver" : true,
    "updatedBy" : user.displayName
  });

}