import 'dart:async';
// import 'dart:ffi';
// import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';




class LoadMarkers {
  static CollectionReference cf = Firestore.instance.collection('problems');
  var documents;

   fetchData() {
    cf.snapshots().listen((event) {
      // setState(() {
      //   documents = event.documents[0].data;
      // });
    });
  }

   static Map<String,dynamic> foods = {
                  "title":"fuck",
                  "expirty_date": 12,
                  "dateobj": 122
                };

  static addToDb(var problems){
     cf.add(problems).whenComplete(() => print('added to db success'));

  }


}