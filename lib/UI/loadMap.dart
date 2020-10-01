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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Authentication/landingPage.dart';

class LoadMap extends StatefulWidget {
  var user;
  String firebase_userId;
  LoadMap({this.user, this.firebase_userId});
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
  var all_documents;

  Future<dynamic> getData() async {
    // firebase_document_outside1 = await cf.get().then<dynamic>((DocumentSnapshot snapshot)async{
    //  return snapshot.data;
    // });

    firebase_document_outside1 =
        await Firestore.instance.collection('problems').getDocuments();
    // tod instead use snapshot streams and listen everytime and  maeka list and update it....on every streamm13:23 growing dev CRUD parse jsonf rom list
    // in streamBuilder we cannot setSTate(s) but inise a function using snapshot steram we can.
  
    cf.snapshots().listen((snapshot) {
      return
      setState(() => {
            all_documents =
                snapshot.documents // this wil give list of document.s
          });
      print("all documents from snapshot${all_documents}");
      // to do create marker from this list instead
    });

    // await Firestore.instance.collection('problems').getDocuments();

    // print(firebase_document_outside1);
    var list1 = firebase_document_outside1.documents;

    print(list1[0].data);
    // print("firebase_doudment outside 1");
    // print("list1 alll ${list1}");
    // list1.forEach((element,index) => {
    

    list1.forEach((element) => {
          if (element.data['location_latitude'] != null)
            addMarker_again(
              latitude: element.data['location_latitude'],
              longitude: element.data['location_longitude'],
              title: element.data["title"],
              description: element.data["description"],
              image_url: element.data['image_url'],
              firebase_user_ID: element.data['user_ID'],
            ),
        });

    // todo: get data and  via provider pass on to all child components.
  }

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
    getData();

    // tod  load markers async wait and then mark in map.
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
      //tod on tap of marker show details
      markers.add(Marker(
          position: cordinate,
          draggable: true,
          onTap: () {
            print("marker tap");
            // tod bottom slider but with thext,, the marker has not been added yet..
            // showTheBottomSheet(this.context);
            //tod from bottom slider appper and option to delete and all and got to places for direction..info about who added it
          },
          markerId: MarkerId(id.toString())));
    });
  }

  addMarker_again(
      {latitude, longitude, title, description, image_url, firebase_user_ID}) {
    int id = Random().nextInt(100);

    setState(() {
      //tod on tap of marker show details
      markers.add(Marker(
          position: LatLng(latitude, longitude),
          draggable: true,
          onTap: () {
            print("marker tap");
            // showBottomSheet();
            showTheBottomSheet(
                context: this.context,
                title: title,
                user_ID: firebase_user_ID,
                description: description,
                image_url: image_url);
            //tod from bottom slider appper and option to delete and all and got to places for direction..info about who added it
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
  TextEditingController select_radius = new TextEditingController();

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

  // load_markers() async {
  //   print("load_markers called out");
  //   if (firebase_document_outside != null) {
  //     print(
  //         "load_markers called inside firebase document oouside. ,${firebase_document_outside}");

  //     firebase_document_outside.forEach((element) => {
  //           addMarker_again(
  //               latitude: element.data['location_latitude'],
  //               longitude: element.data['location_longitude'])
  //         });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    changeImageUrl(String urlFromFirebase) {
      setState(() {
        image_url = urlFromFirebase;
      });
    }

    Future getDeviceImage() async {
      var selected_image =
          await ImagePicker().getImage(source: ImageSource.gallery);
      var select_image1 = File(selected_image.path);

      print("image_selcted111111${select_image1}");

      setState(() {
        select_image = select_image1;
        print("image__selected2222222${select_image}");
      });
    }

    final storage = FirebaseStorage.instance;

    Future uploadPic(context) async {
      String fileName = basename(select_image.path);

      var firebase_snapshot =
          await storage.ref().child(fileName).putFile(select_image).onComplete;

      var downloadUrl = await firebase_snapshot.ref.getDownloadURL();
      setState(() {
        uploaded_image_url = downloadUrl;
      });
      print("uploaded image to firebase");

      // StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
      // StorageUploadTask uploadTask = firebaseStorageRef.putFile(select_image);
      // StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

// String fileName = basename(select_image.path);
      // StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
      // StorageUploadTask uploadTask = firebaseStorageRef.putFile(select_image);
      // StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

      // Scaffold.of(context).showSnackBar(SnackBar(content:Text("added to firebase")));
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
        //todo in setting select the default radius.
        radius: select_radius.text.length == 0
            ? 5000
            : double.parse(select_radius.text) * 1000,
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
                // todo show the images picked in dialog too.
                RaisedButton(
                    onPressed: () {
                      // var selected_image = await ImagePicker().getImage(source: ImageSource.gallery);

                      // // uploadPic();

                      // setState(() {
                      //   select_image = selected_image;
                      //   // select_image = ImagePicker().getImage(source: ImageSource.gallery)
                      //   // todo: save timage to database and again retrive the image back___MULTIPLE IMAGES

                      // });
                      getDeviceImage();
                    },
                    child: Text('pick images')),
                Builder(
                  builder: (context) => RaisedButton(
                    onPressed: () async {
                      print(markers);
                      Navigator.pop(context);

                      select_image != null
                          ? await uploadPic(context)
                          : print('slect imageis null bitch}');

                      // find the current data
                      var date = new DateTime.now().toString();
                      var dateParse = DateTime.parse(date);
                      print(dateParse);
                      var formattedDAte =
                          " :second${dateParse.second} -${dateParse.day} -${dateParse.month} -${dateParse.year} -${dateParse.timeZoneName}-";

                      String sub_id = Random().nextInt(100000).toString();
                      String sub_id1 =
                          new DateTime.now().millisecondsSinceEpoch.toString();
                      print(formattedDAte);
                      String prob_id = "${sub_id}${sub_id1}";
                      print(prob_id);

                      //
                      // todo why snackbar aint working though builder aslos and scaffold also.
                      // Scaffold.of(context).showSnackBar(SnackBar(
                      //   content: Text("added to firebase"),
                      //   duration: Duration(seconds: 3),
                      // ));

                      setState(() {
                        //tod the user id shall match if the user wants to delecte teh thigs he added.
                        // tod also save the current date time, the time of creation
                        //tod if no location saved but still save,, then use current location.
                        to_be_saved = {
                          "problem_id": prob_id,
                          "title": title.text,
                          "description": description.text,
                          "location_latitude": problem_location_latitude == null
                              ? _currentPostion.latitude
                              : problem_location_latitude,
                          "location_longitude":
                              problem_location_longitude == null
                                  ? _currentPostion.longitude
                                  : problem_location_longitude,
                          "phone_number": default_checkbox_value,
                          "image_url": uploaded_image_url,
                          "created_date": dateParse,
                          "user_ID": widget.firebase_userId,
                        };
                        from_alert_dialog = 0;
                        title.text = "";
                        description.text = "";
                      });
                      LoadMarkers.addToDb(to_be_saved);
                    },
                    child: Text("save"),
                    //todo after save,,rebuild teh widget..
                  ),
                ),
              ],
            ),
          ]);
        },
      );
    }

    var within_radius = 5;
    find_number_of_markers(within_radius) {
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
      // need setState??  setstate is need when ver we need to rebuild widget tree.
      final_sorted_locations = all_location_map
          .where((element) => element['radius'] <= within_radius * 1000)
          .toList();
      print("finally $final_sorted_locations");
      print('finalsortedlocations",${final_sorted_locations.length}');
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
            bottom: 200,
            right: 0,
            child: RaisedButton(
                child: Text('signout'),
                onPressed: () async {
                  //for logout
                  SharedPreferences sharedPreferences =
                      await SharedPreferences.getInstance();
                  sharedPreferences.remove("email");
                  //firebase
                  FirebaseAuth ins = FirebaseAuth.instance;
                  ins.signOut().then((_) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return LandingPage();
                          },
                        ),
                      ));
                }),
          ),
          Positioned(
            bottom: 150,
            right: 0,
            child: RaisedButton(
                child: Text('Mylo'),
                onPressed: () {
                  print(all_documents[0].data);
                  // print(
                  // firebase_document_outside1.documents[0].data);
                  // print(all_documents);
                }),
          ),

          Positioned(
            child: SizedBox(
              width: 100,
              child: TextField(
                controller: select_radius,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(hintText: "radius in KM"),
                onChanged: (string) {
                  find_number_of_markers(5);
                  setState(() {
                    within_radius = int.parse(string);
                    select_radius.text.isNotEmpty
                        ? find_number_of_markers(within_radius)
                        : find_number_of_markers(5);
                  });
                },
              ),
            ),
          ),
          Positioned(
            top: 100,
            child: select_radius.text.length == 0
                ? Text(
                    "in area 5, there are ${final_sorted_locations.length} people in need.")
                : Text(
                    "in area ${select_radius.text}, there are ${final_sorted_locations.length} people in need."),
          ),

          StreamBuilder(
              stream: Firestore.instance.collection("problems").snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  firebase_document_outside = snapshot.data.documents;
                  // warning !! this doesnot call the set sate so the firebase_cdocument outside this stream builder never gets updatad.

                  //  print("firebase_doc,${firebase_document_outside}");
                  //  firebase_document.map((e) => {print("firebase${e}")});
                  //  firebase_document.forEach((element)=>{

                  //    addMarker_again(element.data['location_latitude'], element.data['location_longitude'])

                  //  });
                  // load_markers();

                  return Text(
                      'streambuilder snapshot length ,${snapshot.data.documents.length}');
                }
                return Text("not loaded the firebase documents right now. ");
              }),
        ]));
  }

  void showTheBottomSheet(
      {BuildContext context, title, description, image_url, user_ID}) {
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
                RaisedButton(
                    onPressed: () async {
                      // todo only those who added can delete photos. and ofc me...the boss
                      if (user_ID == widget.firebase_userId) {
                        StorageReference photRef = await FirebaseStorage
                            .instance
                            .getReferenceFromUrl(image_url);
                        await photRef.delete();
                        // todo delete the document in firestore too.   21:36 CRUD growing dev
                        //  CollectionReference collectionReference = Firestore.instance.collection("problems");
                        //  QuerySnapshot querySnapshot = await collectionReference.getDocuments();
                        //  querySnapshot.documents[0].reference.delete();
                        //  querySnapshot.documents[0].reference.updateData({"newupdatedvalue":true});

                        //todo update the image url in firestore too.

                      } else {
                        print("user_id donot match..");
                      }
                    },
                    child: Text("dlete image")),
                Text('Images'),
                image_url != null
                    ? Row(
                        children: [
                          FadeInImage.assetNetwork(
                              // todo on tap of image hero widget and oopen full image. and slider for multiple images.
                              placeholder: 'assets/spinner.gif',
                              image: image_url,
                              width: 100,
                              height: 100),
                        ],
                      )
                    : Container(),
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

// class DisplaySnack extends StatelessWidget{
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold.of(context).showSnackBar(new SnackBar(
//        content: Text("added"),
//        duration: Duration(seconds: 3),
//      ));
//     // TODO: implement build
//   }

// }

// class ShowSnack extends StatefulWidget {
//   @override
//   _ShowSnackState createState() => _ShowSnackState();
// }

// class _ShowSnackState extends State<ShowSnack> {
//   @override
//   Widget build(BuildContext context) {
//     return  Scaffold.of(context).showSnackBar(new SnackBar(
//        content: Text("added"),
//        duration: Duration(seconds: 3),
//      ));
//   }
// }
