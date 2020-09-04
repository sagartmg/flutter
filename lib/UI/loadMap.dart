import 'dart:async';
// import 'dart:ffi';
// import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';


class LoadMap extends StatefulWidget {
  @override
  _LoadMapState createState() => _LoadMapState();
}

class _LoadMapState extends State<LoadMap> {
  GoogleMapController _controller;

  final CameraPosition _initialPosition =
      CameraPosition(target: LatLng(24.903623, 67.198367));

  final List<Marker> markers = [];
  final Set all_location_map =Set();
   List final_sorted_locations =[];



  List differencesInRadius =[];
  Location location = Location();

  UserLocation _currentPostion;

  StreamSubscription<LocationData> positionSubscription;

  @override
  void initState() {
    super.initState();

    positionSubscription =  location.onLocationChanged
        .handleError((onError) => print(onError))
        .listen((streameddata) => setState(() {
              _currentPostion = UserLocation(
                  latitude: streameddata.latitude,
                  longitude: streameddata.longitude);
            }));

    // _myLocation();
  }

  @override
  void dispose() {
    positionSubscription
        ?.cancel(); //optionalChanining says  postionalSubscription may or maynot exist and if exist canceal it.
    super.dispose();
  }

  addMarker(cordinate) {
    int id = Random().nextInt(100);

    setState(() {
      //todo on tap of marker show details
      markers.add(Marker(
          position: cordinate,
          draggable: true,
          onTap: () {
            print("marker tap");
            //todo from bottom slider appper and option to delete and all and got to places for direction..info about who added it 
          },

          markerId: MarkerId(id.toString())));
    });
  }

  _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _myLocation();
  }

  _myLocation() {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(_currentPostion==null?24.903623:_currentPostion.latitude, _currentPostion==null?67.198367:_currentPostion.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Set<Circle> circlee = Set.from([
      Circle(
        circleId: CircleId("id"),
        onTap: () {
          print("circle withing radius is done");
        },
        strokeColor: Colors.blueAccent.withOpacity(0.0),
        fillColor: Colors.blueAccent.withOpacity(0.2),
        center: LatLng(_currentPostion.latitude, _currentPostion.longitude),
        radius: 5000,
      )
    ]);

    return Scaffold(
        //todo Stack and add find my location
        body: Stack(fit: StackFit.loose, children: [
      // StackFit.loose    PostionedWidtgt same as abolute // overflown??? then overflow:Overflow.clip
      GoogleMap(
        initialCameraPosition: _initialPosition,
        mapType: MapType.normal,
        onMapCreated: _onMapCreated,
        myLocationEnabled: true,
        markers: markers.toSet(),
        circles: circlee,
        onTap: (cordinate) {
          addMarker(cordinate);
        },
      ),
      Positioned(
        bottom: 50,
        right: 0,
        child: RaisedButton(
          child: Text('Mylo'),
          onPressed: _myLocation,
        ),
      ),
      Positioned(
        bottom: 80,
        left: 0,
        child: Text('number of markers within the radius 5KM'),
      ),
      Positioned(
        bottom: 1000,
        left: 0,
        child: Text('Selected Radius: 5KM'),
      ),
      Positioned(
          bottom: 150,
          left: 0,
          child: RaisedButton(
            onPressed: () {
              print(markers.length);
            },
            child: Text('number of markers'),
          )),
      Positioned(
        child: RaisedButton(
          onPressed: () {
            // var marker1 = markers[0];
            // double distance = Diff().distanceBetween(
            //     _currentPostion.latitude,
            //     _currentPostion.longitude,
            //     markers[0].position.latitude,
            //     markers[0].position.longitude);

            // print(distance);
          all_location_map.clear();

          markers.forEach((element) { 
             double radius_difference = Diff().distanceBetween(
                _currentPostion.latitude,
                _currentPostion.longitude,
                element.position.latitude,
                element.position.longitude);


                differencesInRadius.add(radius_difference);

                all_location_map.add({"location":element,"radius":radius_difference});

            


          });
            print(all_location_map.length);

            final_sorted_locations =  all_location_map.where((element) => element['radius']<=5000).toList();
            print("finally $final_sorted_locations");
            print('finalsortedlocations",${final_sorted_locations.length}');

          },
          child: Text('markers within radius '),
        ),
      ),
    ]));
  }
}

class UserLocation {
  double latitude;
  double longitude;

  UserLocation({this.latitude, this.longitude});
}

class Diff extends GeolocatorPlatform {}  // becuase instance member cannot be accessed using static access. Geo<Abstract> contains a function which
//  we need ,==> extend it and tehn use the class's instance  

