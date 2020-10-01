import 'dart:async';
// import 'dart:ffi';
// import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maddat/Authentication/landingPage.dart';
import 'package:maddat/Authentication/login_page.dart';
import 'package:maddat/UI/loadMap.dart';
import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: LandingPage(),
      
//     );
//   }
// }


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString("email");
  var firebase_userId = prefs.getString("userID");
  runApp(MaterialApp(home: email==null? LandingPage() : LoadMap(firebase_userId: firebase_userId)));
}

