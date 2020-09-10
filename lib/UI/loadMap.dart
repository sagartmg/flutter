import 'dart:async';
// import 'dart:ffi';
// import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maddat/UI/Hood/loadMarkers.dart';

class LoadMap extends StatefulWidget {
  @override
  _LoadMapState createState() => _LoadMapState();
}

class _LoadMapState extends State<LoadMap> {
  GoogleMapController _controller;

  final CameraPosition _initialPosition =
      CameraPosition(target: LatLng(24.903623, 67.198367));

  final List<Marker> markers = [];
  final Set all_location_map = Set();
  List final_sorted_locations = [];

  List differencesInRadius = [];
  Location location = Location();

  UserLocation _currentPostion;

  StreamSubscription<LocationData> positionSubscription;

  @override
  void initState() {
    super.initState();

    positionSubscription = location.onLocationChanged
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
          target: LatLng(
              _currentPostion == null ? 24.903623 : _currentPostion.latitude,
              _currentPostion == null ? 67.198367 : _currentPostion.longitude),
          zoom: 15,
        ),
      ),
    );
  }

  TextEditingController title = new TextEditingController();
  TextEditingController description = new TextEditingController();
  Map<String,dynamic> to_be_saved;
  var problem_location_latitude;
  var problem_location_longitude;
    var from_alert_dialog = 0;


  changeAlertDialogStatus(){
    // set

    // ale
    setState(() {
    from_alert_dialog=1;


      
    });
  }
  updateProblemLocations(lat, long){
    setState(() {
      problem_location_latitude=lat;
      problem_location_longitude = long;
    });
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

    bool default_checkbox_value = false;

   


    Future<dynamic> show_dialog(){

      return showDialog(
                context: context,
                builder: (context) {
                  bool checkdata =false;

                  return AlertDialog(title: Text("data"), actions: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 700,
                          child: TextField(
                            controller: title,
                            decoration: InputDecoration(hintText: "Title"),
                          ),
                        ),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            controller: description,
                            decoration: InputDecoration(hintText: "desciption"),
                          ),
                        ),
                        Text('chosse location'),
                        Row(
                          children: [
                            FlatButton(
                                onPressed: () {
                                  print(from_alert_dialog);
                                problem_location_latitude = _currentPostion.latitude;
                                problem_location_longitude = _currentPostion.longitude;
                                  print(problem_location_latitude);
                                  print(problem_location_longitude);

                                 
                                },
                                child: Text("current loaction")),
                            FlatButton(
                                onPressed: () {
                                  changeAlertDialogStatus();
                                  print(from_alert_dialog);
                                  // todo: it is 1 but as soon as navigator.pop context..it is again set to default ...why>??
                                  Navigator.pop(context);
                                  // first choose from map,set the marker and again show alertdialog depending upon from alertdialog. 

                                // todo then from the last marker array extract latitiude and longitude as problems latlang. 
                                //todo: why making chnage inside alert dialog, and going outside, it reverts to original state...why??
                                            // print(markers.len);
                                           


                                },
                                child: Text("choose form map")),
                          ],
                        ),
                       
                        Row(
                          children: [
                            StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState){
                                print("satatefulBuilder");
                                return Checkbox(
                                onChanged: (bool value) {
                                  print(value);
                                  setState(() {
                                    default_checkbox_value = value;
                                  });
                                },
                                value: default_checkbox_value, //default_check_vlaue
                              );
                              }
                                                          
                            ),
                            Text("include your phone number")
                          ],
                        ),
                        RaisedButton(
                            onPressed: () {}, child: Text('pick images')),
                        RaisedButton(onPressed: () {
                          print(markers);
                          setState(() {
                            to_be_saved={
                              "title":title.text,
                              "description":description.text,
                              "location_latitude":  problem_location_latitude,
                              "location_longitude":  problem_location_longitude,
                              "phone_number":default_checkbox_value

                            };
                            from_alert_dialog=0;
                            title.text ="";
                            description.text = "";
                            
                          });
                          LoadMarkers.addToDb(to_be_saved);

                          Navigator.pop(context);
                        }, child: Text("save")),
                      ],
                    ),
                  ]);
                },
                );
     
    }

    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // title
            // description
            // location //current or choose on map\add photsos
            // ad photos
            // checkbox...display your number

            // on marker clicked..
            // title
            // 0 people on the way
            // sovled? if solved green...or green marker..
            // by Sagar Tamang.....ooptional 9840
            // photsl....half shown able to be scrolled.
            show_dialog();

           
          },
          child: Icon(Icons.add),
          tooltip: ('add about the problem'),
        ),
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
              if(from_alert_dialog ==1){
                show_dialog();
                 var markers_length = markers.length;
                print(markers_length);
                print(markers[markers_length-1].markerId);
                // print(markers[0].markerId.value);
                // print(markers[0].position.latitude);
                // print(markers[0].position.longitude);
                updateProblemLocations(markers[markers_length-1].position.latitude,markers[markers_length-1].position.longitude);




              }
             
              print(from_alert_dialog);
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
            top: 30,
            left: 0,
            child: Row(
              children: [
                StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return Checkbox(

                    value: default_checkbox_value,

                    onChanged: (bool value) {
                      setState(() {
                        default_checkbox_value = value;
                      });
                      print(value);

                    },
                  );
                }),
                Text("include your phone number")
              ],
            ),
          ),
          Checkbox(
          value :default_checkbox_value,
          onChanged:(bool value){}
        ),

          Positioned(
            child: RaisedButton(
              onPressed: () {
              
                all_location_map.clear();

                markers.forEach((element) {
                  double radius_difference = Diff().distanceBetween(
                      _currentPostion.latitude,
                      _currentPostion.longitude,
                      element.position.latitude,
                      element.position.longitude);

                  differencesInRadius.add(radius_difference);

                  all_location_map
                      .add({"location": element, "radius": radius_difference});
                });
                print(all_location_map.length);

                final_sorted_locations = all_location_map
                    .where((element) => element['radius'] <= 5000)
                    .toList();
                print("finally $final_sorted_locations");
                print('finalsortedlocations",${final_sorted_locations.length}');
              },
              child: Text('markers within radius '),
            ),
          ),
          RaisedButton(onPressed: (){
            print('show saved data /map');
            print(to_be_saved);
            print(from_alert_dialog);
            
          },
          child: Text('show saved data'),),
        ]));
  }
}

class UserLocation {
  double latitude;
  double longitude;

  UserLocation({this.latitude, this.longitude});
}

class Diff extends GeolocatorPlatform {
} // becuase instance member cannot be accessed using static access. Geo<Abstract> contains a function which
//  we need ,==> extend it and tehn use the class's instance
