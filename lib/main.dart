import 'package:cloud_firestore/cloud_firestore.dart';
// import 'firestore'
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import './notifyme.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(home: Demo()));
}

class Demo extends StatefulWidget {
  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  Future<void>_showNotification(int secondss,String titlee) async {
    print('setNotifications');
    await demoNotification(secondss,titlee); // demo notifiicati ois a future so it needs some time to conmplet toso await.
  }

  
  var pendingCount = 0;
  void _showPending() async {
    var pendingCountNew = await getPendingNotifications();
    // print("pending notifictaions:m${pendingCountNew}");

    setState(() {
      pendingCount = pendingCountNew;
    });
  }

  Future<dynamic> getPendingNotifications() async {
    List<PendingNotificationRequest> p =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
         return p.length;
  }

  Future<void> demoNotification(int secondss,String titlee) async {
    // var time = Time(20, 15, 0);
    // todo: set the remeaing seconds from todays date.
    var scheduleNotificationTime = DateTime.now().add(Duration(seconds:10));
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_ID_1', 'channel name 1', 'channel description 1',
      importance: Importance.Max,
      priority: Priority.High,
      playSound: true,
      // timeoutAfter: 5000,
      // ticker: 'test ticker');
    );

    var iOSChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSChannelSpecifics);

    await flutterLocalNotificationsPlugin.schedule(
        secondss,
        titlee,
        'expiry of foods. ',
        // time,
        // scheduleNotificationTime,
        scheduleNotificationTime,
        platformChannelSpecifics,
        payload: 'test oayload');
  }
   Future<void> cancelNotification(int notification_canceal) async {
    await flutterLocalNotificationsPlugin.cancel(notification_canceal);
  }
  Future<void> instantNotification(int title) async {
    print("insatn");
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID${title}',
      'CHANNEL_NAME ${title}',
      "CHANNEL_DESCRIPTION ${title}",
      importance: Importance.Max,
      priority: Priority.High,
      playSound: true,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(androidChannelSpecifics, iosChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      title,
      title.toString(),
      'Test Body', //null
      platformChannelSpecifics,
      payload: 'New Payload',
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    
    super.initState();
    print('initsate callded');
    initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);

      var oneSec = const Duration(seconds:1);
    new Timer.periodic(oneSec,(Timer t)=>setState((){}));


    
  }

  Future onSelectNotification(String payload) async {
    // await notificationPlugin._
    if (payload != null) {
      debugPrint('Notification payload: $payload');
    }
    // await Navigator.push(context,
    // new MaterialPageRoute(builder: (context) => new Records()));
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
              title: Text(title),
              content: Text(body),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: Text('Ok'),
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                    // await Navigator.push(context,
                    // MaterialPageRoute(builder: (context) => Records()));
                  },
                )
              ],
            ));
  }

  var documents;
  CollectionReference cfo = Firestore.instance.collection('foods');
  var currentDate = DateTime.now();

  fetchData() {
    // CollectionReference cfo = Firestore.instance.collection('foods');
    cfo.snapshots().listen((event) {
      setState(() {
        documents = event.documents[0].data;
        // print(documents);
      });
    });
  }
  // var finalSeconds = 50;

  @override
  Widget build(BuildContext context) {
    // print('rebuild');
    return Scaffold(
      appBar: AppBar(
        title: Text('Expiry'),
      ),
      body: Column(
        
        children: [
          // Text("remainnig ntofiication:${pendingCount.toString()}"),
          Text('reminder time: 8AM '),

         
          //todo: may get her problem due to listview expanding///////wrap:strethc...
          Expanded(
                      child: StreamBuilder(
                stream: cfo.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    // print('snapshot as $snapshot ');

                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          var doc = snapshot.data.documents[index].data;
                          DateTime dt = doc["dateobj"].toDate();
                          var finald = dt.difference(DateTime.now()).inDays;
                          var finalSeconds;

                              finalSeconds =
                              dt.difference(DateTime.now()).inSeconds;
                          // finalSeconds = 5;
                          // --finalSeconds;/
                            
                          var tottal = finalSeconds + 28800;
                          // _showPending();
                          if(tottal==0){
                          instantNotification(22);


                          _showNotification(finalSeconds,doc['title']);


                          }
                          // _showPending();
                          // _showPending();

                          

                          // _showNotification(tottal,doc['title']);


                          return ListTile(
                            tileColor: tottal<0?Colors.redAccent:null,
                            

                            
                            title: Text(doc["title"]),
                            // title:Text('hello'),
                            subtitle: Text(doc["expirty_date"]),
                            trailing: Column(
                              children:[ 
                              Text("Remaining Days:${finald}"),
                              Text("Remaing secs: ${tottal}"),
                            ],
                            ),
                           
                            
                            // subtitle: Text('baka'),
                            onTap: () async{
                            snapshot.data.documents[index].reference.delete();
                             await cancelNotification(0);


                            },
                          );
                        });
                  }
                  print('nosnapshot $snapshot');
                  return (Text("Empty right now"));
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        _showPending();
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return MyApp();
              });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DateTime selectedDate = DateTime.now();
  var formattedDate;
  TextEditingController food = new TextEditingController();

  CollectionReference collectionReference =
      Firestore.instance.collection("foods");

  Map<String, dynamic> foods;
  var documents;

  addToDB() {
    collectionReference.add(foods).whenComplete(() => print('added db db  db'));
    final snacky = SnackBar(
      content: Text('added to db'),
      action: SnackBarAction(
        label: "undo",
        onPressed: () {},
      ),
    );
    Scaffold.of(context).showSnackBar(snacky);
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        var dateParse = DateTime.parse(picked.toString());
        formattedDate = "${dateParse.day}-${dateParse.month}-${dateParse.year}";
        print(formattedDate);
        selectedDate = picked;
      });
  }

 

  @override
  Widget build(BuildContext context) {
     AlertDialog dialog = new AlertDialog(
    content: Text('the name is empty or date is not selected'),
    title:Text("error"),
    actions: [
      RaisedButton(onPressed:(){
        Navigator.of(context).pop();
        
      },
      child:Text('dismiss'))
    ],
    
  );
   AlertDialog dialogsuc = new AlertDialog(
    content: Text('added to db'),
    title:Text("success"),

    actions: [
      RaisedButton(onPressed:(){
        // Navigator.of(context).pop();
        Navigator.push(context, MaterialPageRoute(builder: (context){
          return Demo();
        }));
        
      },
      child:Text('dismiss'))
    ],
    
  );
    return Scaffold(
      body: Column(
        
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        
        children: [
          
          Container(
            margin: EdgeInsets.only(left:20,right: 20),
            

            child: TextFormField(
              
              
              controller: food,
              decoration: InputDecoration(
                labelText: "name",
              ),
              validator: (str) => !(str.length > 2) ? "not valid" : null,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,


            children: [
              // Text(formattedDate == null
              //     ? selectedDate.toString().substring(0, 10)
              //     : formattedDate), //todo is it date only??  //set formatdat instead of picked
              RaisedButton(
                onPressed: () {
                  _selectDate(context);
                },
                child: Text('choose datae'),
              )
            ],
            // todo: dropdonw fro selection numbe rof daty sof prior notification
          ),
          RaisedButton(
            onPressed: () async{
              //todo save to firestore.
              if (food.text.length > 1 && formattedDate != null) {
                foods = {
                  "title": food.text,
                  "expirty_date": formattedDate,
                  "dateobj": selectedDate
                };

                collectionReference
                    .add(foods)
                    .whenComplete(() => print('added to db success'));
                // addToDB();
                //todo snackbar
              // Navigator.of(context).pop();
               showDialog(context: context,
                child:dialogsuc);
              // await Navigator.of(context).pop();



              }
              else{
                showDialog(context: context,
                child:dialog);

                  
                
              }
              print(food.text.length > 1 ? "food.text" : "food data is empty");
              // print(formattedDate);
            },
            child: Text('save'),
          )
        ],
      ),
    );
  }
}
