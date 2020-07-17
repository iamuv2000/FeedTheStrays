import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _fireStore = Firestore.instance;

void deleteMarker(FirebaseUser user, String markerId) async{
  print("Deleting the Marker");
  await _fireStore.collection('markers').document(markerId).delete();
}