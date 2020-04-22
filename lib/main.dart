import 'package:flutter/material.dart';
import './screens/MapScreen.dart';
import './screens/SignInScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FeedTheStrays',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('FeedTheStrays'),
        ),
        body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child:  SignInScreen()
          ),
        ),
      ),
    );
  }
}
