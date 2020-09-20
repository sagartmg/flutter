import 'dart:async';
import 'dart:io';
// import 'dart:js';
// import 'dart:ffi';
// import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maddat/UI/Hood/loadMarkers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LoadMap extends StatefulWidget {
  @override
  _LoadMapState createState() => _LoadMapState();
}

class _LoadMapState extends State<LoadMap> {
  GoogleMapController _controller;
  File select_image;
  String uploaded_image_url;
  String image_url;

  final CameraPosition _initialPosition =
      CameraPosition(target: LatLng(24.903623, 67.198367));

  final List<Marker> markers = [];
  final Set all_location_map = Set();
  List final_sorted_locations = [];

  List differencesInRadius = [];
  Location location = Location();

  UserLocation _currentPostion;

  StreamSubscription<LocationData> positionSubscription;

  //  LoadMarkers.fetchData();
  var documents = LoadMarkers.documents;
  CollectionReference cf = Firestore.instance.collection('problems');
  var firebase_document_outside1;
// getting data from firestore.
  Future<dynamic> getData() async {
    // firebase_document_outside1 = await cf.get().then<dynamic>((DocumentSnapshot snapshot)async{
    //  return snapshot.data;
    // });
    firebase_document_outside1 =
        await Firestore.instance.collection('problems').getDocuments();

    print(firebase_document_outside1);
    var list1 = firebase_document_outside1.documents;
    print(list1[0].data);
    print("firebase_doudment outside 1");
    print("list1 alll ${list1}");
    list1.forEach((element) => {
          if (element.data['location_latitude'] != null)
            addMarker_again(
                latitude: element.data['location_latitude'],
                longitude: element.data['location_longitude'],
                title: element.data["title"],
                description: element.data["description"],
                image_url: element.data['image_url']),

          // changeURL(element.data['image_url'].toString())

          // changeImageUrl()
        });
  }

  // changeURL(String fromfire){
  //   setState(() {
  //     image_url = fromfire;
  //   });

  //   print("the image url is ${image_url}");

  // }

  // end of getting data from firestroe.

  @override
  void initState() {
    super.initState();

    positionSubscription = location.onLocationChanged
        .handleError((onError) => print(onError))
        .listen((streameddata) => setState(() {
              _currentPostion = UserLocation(
                  latitude: streameddata.latitude == null
                      ? 27.735994237159627
                      : streameddata.latitude,
                  longitude: streameddata.longitude == null
                      ? 85.28792303055525
                      : streameddata.longitude);
            }));
    // load_markers();
    getData();
    // addMarker_again(27.735994237159627, 85.28792303055525);

    // todo  load markers async wait and then mark in map.
  }

  @override
  void dispose() {
    positionSubscription
        ?.cancel(); //optionalChanining says  postionalSubscription may or maynot exist and if exist canceal it.
    super.dispose();
  }

  addMarker(cordinate) {
    int id = Random().nextInt(100);
    // CoordinateLatlng clng =

    setState(() {
      //todo on tap of marker show details
      markers.add(Marker(
          position: cordinate,
          draggable: true,
          onTap: () {
            print("marker tap");
            // showTheBottomSheet(this.context);
            //tod from bottom slider appper and option to delete and all and got to places for direction..info about who added it
          },
          markerId: MarkerId(id.toString())));
    });
  }

  addMarker_again({latitude, longitude, title, description, image_url}) {
    int id = Random().nextInt(100);
    // CoordinateLatlng clng =

    setState(() {
      //todo on tap of marker show details
      markers.add(Marker(
          position: LatLng(latitude, longitude),
          draggable: true,
          onTap: () {
            print("marker tap");
            // showBottomSheet();
            showTheBottomSheet(
                context: this.context,
                title: title,
                description: description,
                image_url: image_url);
            //todo from bottom slider appper and option to delete and all and got to places for direction..info about who added it
          },
          markerId: MarkerId(id.toString())));
    });
  }

  _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    // _myLocation();
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
  Map<String, dynamic> to_be_saved;
  var problem_location_latitude;
  var problem_location_longitude;
  var from_alert_dialog = 0;

  changeAlertDialogStatus() {
    setState(() {
      from_alert_dialog = 1;
    });
  }

  updateProblemLocations(lat, long) {
    setState(() {
      problem_location_latitude = lat;
      problem_location_longitude = long;
    });
  }

  var firebase_document_outside;

  load_markers() async {
    print("load_markers called out");
    //  todo wait til firebase dta has been extracted.
    // firebase_document_outside = await StreamBuilder(
    //     stream: cf.snapshots(),
    //     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //       if (snapshot.hasData) {
    //         firebase_document_outside = snapshot.data.documents;
    //         print("firebase_snapshot_saved");

    //         return Text(
    //             'streambuilder snapshot length ,${snapshot.data.documents.length}');
    //       }
    //     });

    if (firebase_document_outside != null) {
      print(
          "load_markers called inside firebase document oouside. ,${firebase_document_outside}");

      firebase_document_outside.forEach((element) => {
            addMarker_again(
                latitude: element.data['location_latitude'],
                longitude: element.data['location_longitude'])
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    changeImageUrl(String urlFromFirebase) {
      setState(() {
        image_url = urlFromFirebase;
      });
    }

    Future getDeviceImage() async {
      // var selected_image = await ImagePicker.pickImage(source:ImageSource.gallery );
      //  var selected_image = await ImagePicker().getImage(source: ImageSource.gallery);
      var selected_image =
          await ImagePicker().getImage(source: ImageSource.gallery);
      var select_image1 = File(selected_image.path);

      print("image_selcted111111${select_image1}");

      setState(() {
        select_image = select_image1;
        print("image__selected2222222${select_image}");
      });

      // setState((){

      // });
      //  setState(){
      //    select_image = select_image1;
      //    print("image__selected2222222${select_image}");
      //  }
    }

    Future uploadPic(BuildContext context) async {
      final storage = FirebaseStorage.instance;
      String fileName = basename(select_image.path);

      var firebase_snapshot =
          await storage.ref().child(fileName).putFile(select_image).onComplete;

      var downloadUrl = await firebase_snapshot.ref.getDownloadURL();
      setState(() {
        uploaded_image_url = downloadUrl;
      });

      // StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
      // StorageUploadTask uploadTask = firebaseStorageRef.putFile(select_image);
      // StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

// String fileName = basename(select_image.path);
      // StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
      // StorageUploadTask uploadTask = firebaseStorageRef.putFile(select_image);
      // StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

      setState(() {
        print("uploaded image to firebase");
        // Scaffold.of(context).showSnackBar(SnackBar(content:Text("added to firebase")));
      });
    }

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

    Future<dynamic> show_dialog() {
      return showDialog(
        context: context,
        builder: (context) {
          bool checkdata = false;

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
                          problem_location_longitude =
                              _currentPostion.longitude;
                          print(problem_location_latitude);
                          print(problem_location_longitude);
                        },
                        child: Text("current loaction")),
                    FlatButton(
                        onPressed: () {
                          changeAlertDialogStatus();
                          print(from_alert_dialog);
                          // tod: it is 1 but as soon as navigator.pop context..it is again set to default ...why>??
                          Navigator.pop(context);
                          // first choose from map,set the marker and again show alertdialog depending upon from alertdialog.

                          // tod then from the last marker array extract latitiude and longitude as problems latlang.
                          //tod: why making chnage inside alert dialog, and going outside, it reverts to original state...why??
                          // print(markers.len);
                        },
                        child: Text("choose form map")),
                  ],
                ),
                Row(
                  children: [
                    StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
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
                    }),
                    Text("include your phone number")
                  ],
                ),
                RaisedButton(
                    onPressed: () {
                      // var selected_image = await ImagePicker().getImage(source: ImageSource.gallery);

                      // // uploadPic();

                      // setState(() {
                      //   select_image = selected_image;
                      //   // select_image = ImagePicker().getImage(source: ImageSource.gallery)
                      //   // todo: save timage to database and again retrive the image back

                      // });
                      getDeviceImage();
                    },
                    child: Text('pick images')),
                RaisedButton(
                    onPressed: () async {
                      print(markers);

                      Navigator.pop(context);
                      await uploadPic(context);
                      setState(() {
                        //todo  the user id shall match if the user wants to delecte teh thigs he added. 
                        to_be_saved = {
                          "userId":12,
                          "title": title.text,
                          "description": description.text,
                          "location_latitude": problem_location_latitude,
                          "location_longitude": problem_location_longitude,
                          "phone_number": default_checkbox_value,
                          "image_url": uploaded_image_url
                        };
                        from_alert_dialog = 0;
                        title.text = "";
                        description.text = "";
                      });
                      LoadMarkers.addToDb(to_be_saved);
                    },
                    child: Text("save")),
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
              print("coordinate${cordinate}");
              addMarker(cordinate);
              if (from_alert_dialog == 1) {
                show_dialog();
                var markers_length = markers.length;
                print(markers_length);
                print(markers[markers_length - 1].markerId);
                // print(markers[0].markerId.value);
                // print(markers[0].position.latitude);
                // print(markers[0].position.longitude);
                updateProblemLocations(
                    markers[markers_length - 1].position.latitude,
                    markers[markers_length - 1].position.longitude);
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
          Checkbox(value: default_checkbox_value, onChanged: (bool value) {}),

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
          RaisedButton(
            onPressed: () {
              print('show saved data /map');
              print(to_be_saved);
              print(from_alert_dialog);
            },
            child: Text('show saved data'),
          ),
          Positioned(
            bottom: 100,
            right: 0,
            child: RaisedButton(
                onPressed: () {
                  // LoadMarkers.printdocument();
                  // print(firebase_document_outside);
                  // firebase_document_outside.forEach((element,index)=>{
                  //   print("elm${element}, index ${index}")
                  // });
                  // print(firebase_document_outside[0].data);

                  // load from firebase();
                  for (int i = 0; i < firebase_document_outside.length; i++) {
                    print(firebase_document_outside[i].data);
                  }
                  // buttonPressed();
                },
                child: Text('print documents')),
          ),

          StreamBuilder(
              stream: Firestore.instance.collection("problems").snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  firebase_document_outside = snapshot.data.documents;
                  //  print("firebase_doc,${firebase_document_outside}");
                  //  firebase_document.map((e) => {print("firebase${e}")});
                  //  firebase_document.forEach((element)=>{

                  //    addMarker_again(element.data['location_latitude'], element.data['location_longitude'])

                  //  });
                  // load_markers();

                  return Text(
                      'streambuilder snapshot length ,${snapshot.data.documents.length}');
                }
              }),
        ]));
  }

  void showTheBottomSheet(
      {BuildContext context, title, description, image_url}) {
    // showModalBottomSheet(
    //     context: context,
    //     builder: (context) {
    //       return Container(
    //         height: 180,
    //         child: Container(
    //             decoration: BoxDecoration(
    //               color: Theme.of(context).canvasColor,
    //               borderRadius: BorderRadius.only(
    //                   topLeft: Radius.circular(10),
    //                   topRight: Radius.circular(10)),
    //             ),
    //             child: Column(
    //               children: [
    //                 Container(
    //                   height: 100,
    //                   color: Colors.red,
    //                 ),
    //                 Container(
    //                   height: 100,
    //                   color: Colors.redAccent,
    //                 ),
    //                 Container(
    //                   height: 100,
    //                   color: Colors.cyan,
    //                 ),
    //                 Container(
    //                   height: 100,
    //                   color: Colors.purple,
    //                 ),
    //               ],
    //             )),
    //       );
    //     });
    showModalBottomSheet(
        context: this.context,
        builder: (context) {
          return Container(
            color: Colors.green,
            // height: 180,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              child: Column(children: [
                Row(children: [
                  Column(
                    children: [
                      Icon(Icons.arrow_drop_up),
                      Text('-12'),
                      Icon(Icons.arrow_drop_down)
                    ],
                  ),
                  Text(title),
                ]),
                Row(
                  children: [
                    Column(
                      children: [
                        Text("by Soemone${description}"),
                        Text("98404025514")
                      ],
                    )
                  ],
                ),
                Row(
                  children: [
                    RaisedButton(
                      onPressed: () {},
                      child: Text('add as going'),
                    ),
                    RaisedButton(
                      onPressed: () {
                        // todo details of people on go
                      },
                      child: Text(' 5 people on go'),
                    ),
                    RaisedButton(
                      onPressed: () {},
                      child: Text('mark as solved'),
                    )
                  ],
                ),
                Text('Images'),
                image_url!=null?
                Row(
                  children: [
                   
                    FadeInImage.assetNetwork(placeholder:'assets/spinner.gif', image:image_url, width: 100,height: 100),
                  ],
                ):Container(),
              ]),
            ),
          );
        });
  }
}

Widget showDraggableSheet() {
  // return DraggableScrollableSheet(builder:BuildContext context, ScrollContainer scrollContainer){
  //   return Container(

  //   );
  // };
  // return DraggableScrollableSheet(builder: (BuildContext context, ScrollContainer));
}

class UserLocation {
  double latitude;
  double longitude;

  UserLocation({this.latitude, this.longitude});
}

class Diff extends GeolocatorPlatform {
} // becuase instance member cannot be accessed using static access. Geo<Abstract> contains a function which
//  we need ,==> extend it and tehn use the class's instance
