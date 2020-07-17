import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './MapScreen.dart';
import '../Utils/deleteMarker.dart';
final _fireStore = Firestore.instance;

class MyMarkerScreen extends StatefulWidget {
  MyMarkerScreen({this.firebaseUser});
  FirebaseUser firebaseUser;
  @override
  _MyMarkerScreenState createState() => _MyMarkerScreenState();
}

class _MyMarkerScreenState extends State<MyMarkerScreen> {
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
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return GoogleMapScreen(firebaseUser: widget.firebaseUser);
                    }));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.location_on),
                  title: Text('My markers'),
                  onTap: () {
                    Navigator.pop(context);
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
          body: StreamBuilder<QuerySnapshot>(
            stream: _fireStore.collection('markers').where('createdBy',isEqualTo : widget.firebaseUser.uid).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return ListView(
                children: snapshot.data.documents.map((document) {
                  if (!snapshot.hasData) return new Text('Loading...');
                  return ListTile(
                    title: Text(document['address']),
                    subtitle: Text(document['title']),
                    trailing: FloatingActionButton(
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.deepOrangeAccent,
                      onPressed: (){
                        deleteMarker(widget.firebaseUser, document['markerId']);
                      },
                    ),
                  );
                }).toList(),
              );
            },
          )
      ),
    );
  }
}
