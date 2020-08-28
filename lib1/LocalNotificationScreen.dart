import 'package:flutter/material.dart';
// import 'package:flutter_demos/NotificationPlugin.dart';
// import './notficationPlu';
import './NotificationPlugin.dart';
import './NotificationScreen.dart';
// import 'package:flutter_demos/NotificationScreen.dart';

class LocalNotificationScreen extends StatefulWidget {
  @override
  _LocalNotificationScreenState createState() =>
      _LocalNotificationScreenState();
}

class _LocalNotificationScreenState extends State<LocalNotificationScreen> {
  //

  int count = 0;

  @override
  void initState() {
    super.initState();
    // notificationPlugin
    //     .setListenerForLowerVersions(onNotificationInLowerVersions);
    notificationPlugin.setOnNotificationClick(onNotificationClick);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Local Notifications'),
      ),
      body: Center(
        child: FlatButton(
          onPressed: () async {
            await notificationPlugin.showNotification(2);
            await notificationPlugin.showNotification(1);

            await notificationPlugin.scheduleNotification("schedule one",3);
            await notificationPlugin.scheduleNotification("schedule two",6);

            // await notificationPlugin.showNotificationWithAttachment();
            // await notificationPlugin.repeatNotification();
            // await notificationPlugin.showDailyAtTime();
            // await notificationPlugin.showWeeklyAtDayTime();
            // count = await notificationPlugin.getPendingNotificationCount();
            // print('Count $count');
            // await notificationPlugin.cancelNotification();
            count = await notificationPlugin.getPendingNotificationCount();
            print('Count $count');
          },
          child: Text('Send Notification'),
        ),
      ),
    );
  }

  onNotificationInLowerVersions(ReceivedNotification receivedNotification) {
    print('Notification Received ${receivedNotification.id}');
  }

  onNotificationClick(String payload) {
    print('Payload $payload');
    Navigator.push(context, MaterialPageRoute(builder: (coontext) {
      return NotificationScreen(
        payload: payload,
      );
    }));
  }
}
