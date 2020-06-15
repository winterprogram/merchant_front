import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:merchantfrontapp/widgets/Mixpanel.dart';
import 'package:merchantfrontapp/widgets/common_button.dart';
import 'package:merchantfrontapp/widgets/signup_page.dart';
import 'package:merchantfrontapp/widgets/login_page.dart';
import 'package:mixpanel_analytics/mixpanel_analytics.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fcm_notification.dart';

// landing page
class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  MixPanel mix = MixPanel();
  FcmNotification fcm;
  signup(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUp()),
    );
    if (result == true) {
      showModalBottomSheet(context: context, builder: (context) => Login());
    }
  }

  @override
  void initState() {
    super.initState();
    fcm = new FcmNotification(context: context);
    fcm.initialize();
    mix.createMixPanel();
    checkfirstLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/merchant.png'), //image
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ClickButton(
                    buttonTitle: 'Login',
                    buttonFunction: () {
                      onClickLandingPage('Login');
                      showModalBottomSheet(
                          context: context, builder: (context) => Login());
                    },
                  ),
                ), //Login Button
                Expanded(
                  child: ClickButton(
                    buttonTitle: 'Signup',
                    buttonFunction: () {
                      onClickLandingPage('SignUp');
                      signup(context);
                    },
                  ),
                ), //SignUp Button
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
  }

  onClickLandingPage(String button) async {
    fcm.getToken().then((value) {
      print(value);
      var result = mix.mixpanelAnalytics.track(
          event: 'onClickLandingPage',
          properties: {'button': button, 'distinct_id': value});
      result.then((value) {
        print('this is on click');
        print(value);
      });
    });
  }

  checkfirstLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var firstLogin = prefs.getBool('firstlogin');
    print(firstLogin);
    if (firstLogin != null && !firstLogin) {
      // Not first
    } else {
      // First time'
      print('firsttime');
      String deviceName;
      String identifier;
      String osVersion;
      String osName;
      String deviceBrand;
      final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
      try {
        if (Platform.isAndroid) {
          var build = await deviceInfoPlugin.androidInfo;
          osName = 'Android';
          osVersion = build.version.release;
          deviceBrand = build.brand;
          deviceName = build.model;
          identifier = build.androidId; //UUID for Android
        } else if (Platform.isIOS) {
          var data = await deviceInfoPlugin.iosInfo;
          osName = 'IOS';
          deviceBrand = data.name;
          osVersion = data.systemVersion;
          deviceName = data.name;
          identifier = data.identifierForVendor; //UUID for iOS
        }
      } on PlatformException {
        print('Failed to get platform version');
      }
      print(deviceName);
      print(identifier);
      print(deviceBrand);
      print(osVersion);
      fcm.getToken().then((value) {
        var result = mix.mixpanelAnalytics
            .engage(operation: MixpanelUpdateOperations.$set, value: {
          'osName': osName,
          'deviceName': deviceName,
          'deviceBrand': deviceBrand,
          'osVersion': osVersion,
          'installTime': DateTime.now().toUtc().toIso8601String(),
          'distinct_id': value
        });
        result.then((value) {
          print('This is first login');
          print(value);
        });
      });

      prefs.setBool('firstlogin', false);
    }
  }
}
