import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../Utils/updateFeedStatus.dart';


class MarkerInfoScreen extends StatefulWidget {
  MarkerInfoScreen({this.lastFed, this.isFedEver , this.markerId, this.firebaseUser, this.updateMarkerView});
  DateTime lastFed; //To see if dog has been fed recently
  bool isFedEver;
  String markerId;
  FirebaseUser firebaseUser;
  Future<void> updateMarkerView;

  //To check if dog has been ever fed
  @override
  _MarkerInfoScreenState createState() => _MarkerInfoScreenState();
}

class _MarkerInfoScreenState extends State<MarkerInfoScreen> {

  void initState() {
    super.initState();
    setContext();
  }

  var status;
  var unit = '';

  void setContext () {
    setState(() {
      if(widget.isFedEver){
        status = DateTime.now().difference(widget.lastFed).inMinutes;
        unit = 'minutes ago';
        if(status > 60 && DateTime.now().difference(widget.lastFed).inDays==0) {
          status = DateTime.now().difference(widget.lastFed).inHours;
          unit = 'hours ago';
        }
        else if(status > 24){
          status = DateTime.now().difference(widget.lastFed).inDays.toString();
          unit = 'day(s) ago';
        }
      }
      else {
        status = 'NEVER';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff757575),
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: <Widget>[
            Text(
              'Feed Status',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.deepOrangeAccent,
                fontSize: 30.0,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Text(
                  'Status : ',
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                Text(
                  '$status $unit',
                  style: TextStyle(
                  color: widget.isFedEver ? Colors.green: Colors.redAccent ,
                  fontSize: 18.0,
                ),
                )
              ],
            ),
            SizedBox(height: 20),
            FlatButton(
              child: Text(
                'FED',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.deepOrangeAccent,
              onPressed: () {
                updateFeedStatus(widget.firebaseUser, widget.markerId);
                widget.updateMarkerView;
                Navigator.pop(context);
              },
            ),

          ],
        ),
      ),
    );
  }
}
