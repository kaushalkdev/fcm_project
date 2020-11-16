import 'dart:convert';

import 'package:fcm_app/notification_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  static Future<dynamic> myBackgroundMessageHandler(
      Map<String, dynamic> message) async {
    if (message.containsKey('data')) {
      // Handle data message
    }
    if (message.containsKey('notification')) {
      // Handle notification message

    }
  }

  @override
  void initState() {
    super.initState();

    initializeNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Fcm App',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
    );
  }

  Future _showItemDialog(String message) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Notification',
        ),
        content: Text(message),
        actions: [
          RaisedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Ok'),
          )
        ],
      ),
    );
  }

  void _navigateToItemDetail(
      Map<String, dynamic> message, BuildContext context) {
    NotificationModel notificationModel = NotificationModel.fromJson(message);
    showDialog(
      context: context,
      child: AlertDialog(
        title: Text(
          notificationModel.notification.title,
        ),
        content: Text(notificationModel.notification.body),
        actions: [
          RaisedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Ok'),
          )
        ],
      ),
    );
  }

  Future initializeNotification() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
      android: android,
      iOS: ios,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onselectNotification);
    configureFcm();
  }

  void configureFcm() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        try {
          var title = message['notification']['title'];
          var body = message['notification']['body'];
          var android = AndroidNotificationDetails(
              'channelId', 'channelName', 'channelDescription');
          var iOS = IOSNotificationDetails();
          var notificationDetails =
              NotificationDetails(android: android, iOS: iOS);

          _flutterLocalNotificationsPlugin
              .show(0, title, body, notificationDetails, payload: body);
          showMessageDialog(body: body ?? 'body', title: title ?? 'title');
        } catch (e) {
          print('Error $e');
        }
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _navigateToItemDetail(message, context);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _navigateToItemDetail(message, context);
      },
    );
  }

  Future onselectNotification(String payload) {
    debugPrint("payload $payload");
    return _showItemDialog(payload);
  }

  void showMessageDialog({String title, String body}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          RaisedButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
      ),
    );
  }
}
