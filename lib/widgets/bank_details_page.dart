import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:merchantfrontapp/widgets/Mixpanel.dart';
import 'package:merchantfrontapp/widgets/bank_details_form.dart';
import 'package:merchantfrontapp/widgets/fcm_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'constants.dart';
import 'landing_page.dart';

class Bank extends StatefulWidget {
  @override
  _BankState createState() => _BankState();
}

class _BankState extends State<Bank> {
  FcmNotification fcm;
  MixPanel mix = MixPanel();

  @override
  void initState() {
    super.initState();
    fcm = new FcmNotification(context: context);
    fcm.initialize();
    mix.createMixPanel();
  }

  @override
  void dispose() {
    super.dispose();
    fcm.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: FlatButton(
                    shape: CircleBorder(),
                    child: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 20, left: 40),
                    child:
                        Text('Bank Details', style: TextStyle(fontSize: 24))),
              ],
            ),
            Expanded(
              child: FutureBuilder(
                future: getBankDetails(),
                builder: (context, projectSnap) {
                  if (projectSnap.hasError) {
                    return Container(child: Text('An Error has occurred'));
                  } else if (projectSnap.hasData) {
                    if (projectSnap.data['data'] == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.add_circle_outline,
                                size: 35,
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BankDetails(false)));
                              },
                            ),
                            Text('Add Bank Account Details'),
                          ],
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Account No.'),
                                Text(':'),
                                Text(projectSnap.data['data'][0]['bankAccount'])
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('IFSC Code'),
                                Text(':'),
                                Text(projectSnap.data['data'][0]['ifscCode'])
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Bank Name'),
                                Text(':'),
                                Text(projectSnap.data['data'][0]['bankName'])
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RaisedButton(
                              color: kOverallColor,
                              child: Text('Edit'),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            BankDetails(true)));
                              },
                            )
                          ],
                        ),
                      );
                    }
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  getBankDetails() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); //get merchant id
    final merchantkey = 'merchantid';
    String merchantid = prefs.getString(merchantkey);
    print(merchantid);

    try {
      Response response = await get(
        kUrl + '/merchantBankDeatils',
        headers: {
          'merchantid': merchantid,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));
      String body = response.body;
      print(body);
      String status = json.decode(body)['message'];
      onGetBankDetails(status);
      if (status == 'auth token is empty') {
        Toast.show(
          "You have been logged out. Please login again", //coupon created
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.red[200],
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('merchantid');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LandingPage()),
          (Route<dynamic> route) => false,
        );
      }
      return json.decode(body);
    } on TimeoutException catch (_) {
      Toast.show(
        "Check your internet connection",
        context,
        duration: 3,
        gravity: Toast.BOTTOM,
        textColor: Colors.black,
        backgroundColor: Colors.red[200],
      );
    } on SocketException catch (_) {
      Toast.show(
        "Check your internet connection",
        context,
        duration: 3,
        gravity: Toast.BOTTOM,
        textColor: Colors.black,
        backgroundColor: Colors.red[200],
      );
    }
  }

  onGetBankDetails(String status) async {
    fcm.getToken().then((value) {
      print(value);
      var result = mix.mixpanelAnalytics.track(
          event: 'onGetBankDetails',
          properties: {'status': status, 'distinct_id': value});
      result.then((value) {
        print('this is on click');
        print(value);
      });
    });
  }
}
