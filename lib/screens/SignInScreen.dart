import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../Utils/create_user.dart';
import './MapScreen.dart';


final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.orangeAccent[400] ,Colors.orangeAccent[200]],
            )
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right : 30.0),
            child: Image.asset(
                "assets/feed_the_stray_logo.png",
              scale: 1
            ),
          ),
              SizedBox(height: 100),
              _signInButton(context),
            ],
        ),
      ),
    );
  }
}

Widget _signInButton(BuildContext context){
  return Container(
    decoration: BoxDecoration(
      boxShadow: [
      BoxShadow(
          color: Colors.black12,
          blurRadius: 10.0, // has the effect of softening the shadow
          spreadRadius: 1.0, // has the effect of extending the shadow
          offset: Offset(
          0, // horizontal, move right 10
          5.0, // vertical, move down 10
      ),
      ),
      ],
    ),
    child: FlatButton(
        color: Colors.deepOrange,
      splashColor: Colors.orange,
      onPressed: () async {
        final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final AuthResult authResult = await _auth.signInWithCredential(credential);
        final FirebaseUser user = authResult.user;
        createUser(user);
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return GoogleMapScreen(firebaseUser: user);
        }));
        },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),

              child: Text(
                'Sign in with Google',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    ),
  );
}