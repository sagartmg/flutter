// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'firestore'
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';




// import 'package:flutter/'


class DemoMe extends StatefulWidget {
  @override
  _DemoMeState createState() => _DemoMeState();
}

class _DemoMeState extends State<DemoMe> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid;
  var initializationSettingsIOS;
  var initializationSettings;

  Future<void>_showNotification() async {
    print('setNotifications');
    await demoNotification(); // demo notifiicati ois a future so it needs some time to conmplet toso await.
  }

  
  var pendingCount = 0;
  void _showPending() async {
    var pendingCountNew = await getPendingNotifications();
    print("pending notifictaions:m${pendingCountNew}");

    setState(() {
      pendingCount = pendingCountNew;
    });
  }

  Future<dynamic> getPendingNotifications() async {
    List<PendingNotificationRequest> p =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return p.length;
  }

  Future<void> demoNotification() async {
    // var time = Time(20, 15, 0);
    // todo: set the remeaing seconds from todays date.
    print("demonotification");
    var scheduleNotificationTime = DateTime.now().add(Duration(seconds:5));
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
        0,
        'expirytitlie',
        'expiry of foods. ',
        // time,
        // scheduleNotificationTime,
        scheduleNotificationTime,
        platformChannelSpecifics,
        payload: 'test oayload');
  }
      Future<void> scheduleNotification() async {
    var scheduleNotificationDateTime = DateTime.now().add(Duration(seconds: 5));
    var androidChannelSpecifics = AndroidNotificationDetails(
      'CHANNEL_ID 1',
      'CHANNEL_NAME 1',
      "CHANNEL_DESCRIPTION 1",
      icon: 'secondary_icon',
      sound: RawResourceAndroidNotificationSound('my_sound'),
      largeIcon: DrawableResourceAndroidBitmap('large_notf_icon'),
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.Max,
      priority: Priority.High,
      playSound: true,
      timeoutAfter: 5000,
      styleInformation: DefaultStyleInformation(true, true),
    );
    var iosChannelSpecifics = IOSNotificationDetails(
      sound: 'my_sound.aiff',
    );
    var platformChannelSpecifics = NotificationDetails(
      androidChannelSpecifics,
      iosChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.schedule(
      0,
      'Test Title',
      'Test Body',
      scheduleNotificationDateTime,
      platformChannelSpecifics,
      payload: 'Test Payload',
    );
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');
    initializationSettingsIOS = new IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    initializationSettings = new InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expiry'),
      ),
      body: 
          Text("remainnig ntofiication:${pendingCount}"),
         
        // ],
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          
          // pendingCount  =  await  NotificationPlugin.getPendingNotifications();
          // _showNotification();
          scheduleNotification();
          _showPending();
          // flutterLocalNotificationsPlugin._showNotification();
       },
       
        child: Icon(Icons.add),
      ),
    );
  }
}