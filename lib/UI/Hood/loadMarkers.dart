import 'dart:async';
// import 'dart:ffi';
// import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoadMark extends StatefulWidget {
  @override
  LoadMarkers createState() => LoadMarkers();
}

class LoadMarkers extends State<LoadMark> {
  static CollectionReference cf = Firestore.instance.collection('problems');
  static var documents;

  @override
  void initState() {
    super.initState();
    fetchData();
    print("inist sate documetn from load map${documents}");
  }

  fetchData() {
    print("inist sate documetn from load map i am fetch data ");

    cf.snapshots().listen((event) {
      setState(() {
        documents = event.documents[0].data;
      });
    });
  }
  static printdocument(){
    print("${documents} the content of documents");
  }

  static addToDb(var problems) {
    cf.add(problems).whenComplete(() => print('added to db success'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text("remainnig ntofiication:${pendingCount.toString()}"),
        Text('reminder time: 8AM '),

        //todo: may get her problem due to listview expanding///////wrap:strethc...
        Expanded(
          child: StreamBuilder(
              // static CollectionReference cf = Firestore.instance.collection('problems');

              stream: cf.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  print('snapshot as $snapshot ');
                  print("inist sate documetn from load map ${snapshot}");

                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data.documents[index].data;
                        DateTime dt = doc["dateobj"].toDate();
                        var finald = dt.difference(DateTime.now()).inDays;
                        var finalSeconds;

                        finalSeconds = dt.difference(DateTime.now()).inSeconds;
                        // finalSeconds = 5;
                        // --finalSeconds;/

                        var tottal = finalSeconds + 28800;
                        // _showPending();
                        if (tottal == 0) {
                          // instantNotification(22);

                          // _showNotification(finalSeconds,doc['title']);

                        }
                        final item = snapshot.data.documents[index];
                        // final item
                        Random random = new Random();
                        int rand = random.nextInt(99);
                        String kk = '${item}rand${rand}';
                        return Dismissible(
                          key: Key(kk),
                          onDismissed: (direction) async {
                            print('dismissed');
                            snapshot.data.documents[index].reference.delete();
                            //  await cancelNotification(0);
                          },
                          background: Container(color: Colors.green),
                          // Scaffold.of(context).

                          // padding: const EdgeInsets.bottom(8.0),
                          // padding: EdgeInsets.only(bottom:8.0),
                          child: ListTile(
                            // tileColor: tottal<0?Colors.redAccent:null,
                            tileColor: (() {
                              // immediated anynomous function

                              if (tottal < 0) {
                                return Colors.redAccent;
                              } else if (tottal < 8) {
                                return Colors.orangeAccent;
                              } else
                                return null;
                              // else return null;
                            }()),

                            title: Text(doc["title"]),
                            // title:Text('hello'),
                            subtitle: Text(doc["expirty_date"]),
                            trailing: Column(
                              children: [
                                Text("Remaining Days:${finald}"),
                                Text("Remaing secs: ${tottal}"),
                              ],
                            ),

                            // subtitle: Text('baka'),
                            onTap: () async {
                              snapshot.data.documents[index].reference.delete();
                              //  await cancelNotification(0);
                            },
                          ),
                        );
                      });
                }
                print('nosnapshot $snapshot');
                return (Text("Empty right now"));
              }),
        ),
      ],
    );
  }
}
