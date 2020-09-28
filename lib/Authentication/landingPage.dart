import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:maddat/Authentication/homePage.dart';
import 'package:maddat/Authentication/login_page.dart';
import 'package:maddat/Authentication/signup_page.dart';
import 'package:maddat/UI/loadMap.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'firebase_uth/f';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          RaisedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context)=>
                     LoginPage(),fullscreenDialog: true
                  
                ),
              );
            },
            child: Text("login"),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return SignInPage();
                  },
                ),
              );
            },
            child: Text("sign up"),
          )
        ],
      ),
    );
  }
}
