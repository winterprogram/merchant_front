import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flushbar/flushbar.dart';
import 'dart:io';

class FcmNotification {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;
  BuildContext context;
  FcmNotification({this.context});
  void initialize() {
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
      });
    }
    _fcm.requestNotificationPermissions(IosNotificationSettings());
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('hi');
        print("onMessage: $message");
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          title: message['notification']['title'],
          message: message['notification']['body'],
        ).show(context);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  getToken() async {
    String fcmtoken = await _fcm.getToken();
    return fcmtoken;
  }

  void close() {
    iosSubscription.cancel();
  }
}
