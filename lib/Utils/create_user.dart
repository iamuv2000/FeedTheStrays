import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


final _fireStore = Firestore.instance;

void createUser(FirebaseUser user) async{
  print("Running function!");
  final snapShot = await Firestore.instance
      .collection('users')
      .document(user.uid)
      .get();
  print("Snapshot received!");

  if (snapShot == null || !snapShot.exists) {
    print("Snapshot not present!");

    // Creating user
    await _fireStore.collection('users').document(user.uid).setData({
      'uid': user.uid,
      'name': user.displayName,
      'createdDate' : new DateTime.now()
    });
    print("User created!");

  }
  else{
    print("Snapshot present!");
  }
}