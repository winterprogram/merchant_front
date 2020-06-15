import 'package:flutter/material.dart';
import 'package:merchantfrontapp/widgets/Mixpanel.dart';
import 'package:merchantfrontapp/widgets/constants.dart';
import 'package:merchantfrontapp/widgets/manage_coupon_page.dart';
import 'package:http/http.dart';
import 'package:merchantfrontapp/widgets/promote_brand.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:toast/toast.dart';
import 'bank_details_page.dart';
import 'fcm_notification.dart';

class StatusPage extends StatefulWidget {
  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  FcmNotification fcm;
  String merchantEarning = "Loading";
  String couponissued = "Loading";
  String couponredeemed = "Loading";
  Timer t;
  Timer t1;
  Timer t2;
  MixPanel mix = MixPanel();
  @override
  void initState() {
    super.initState();
    fcm = new FcmNotification(context: context);
    fcm.initialize();
    mix.createMixPanel();
    showCouponIssued();
    showCouponRedeemed();
    showMerchantEarning();
    t = Timer.periodic(
        Duration(seconds: 30), (Timer t) => showMerchantEarning());
    t1 = Timer.periodic(
        Duration(seconds: 60), (Timer t) => showCouponRedeemed());
    t2 = Timer.periodic(Duration(seconds: 60), (Timer t) => showCouponIssued());
  }

  @override
  void dispose() {
    t.cancel();
    t1.cancel();
    t2.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Color(0xFFf1d300),
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 13, right: 10, left: 10),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Your earnings',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20)),
                              Text(merchantEarning,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('-20%',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20)),
                                  Icon(Icons.trending_down, color: Colors.red)
                                ],
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.elliptical(30, 30),
                                topRight: Radius.elliptical(30, 30)),
                          ),
                        ),
                      ),
                    ),
                    /* Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 13, left: 5, right: 10),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Amount you owe us',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20)),
                              Text('5500',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('+20%',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20)),
                                  Icon(Icons.trending_up, color: Colors.green)
                                ],
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.elliptical(30, 30),
                            ),
                          ),
                        ),
                      ),
                    ),*/
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10, left: 10, right: 5),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('No. of coupons issued',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20)),
                              Text('$couponissued',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('+20%',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                      )),
                                  Icon(Icons.trending_up, color: Colors.green)
                                ],
                              )
                            ],
                          ),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 10, right: 10, left: 5),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('No. of coupons redeemed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20)),
                              Text('$couponredeemed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('-10%',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20)),
                                  Icon(Icons.trending_down, color: Colors.red)
                                ],
                              )
                            ],
                          ),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 15, left: 10, right: 5, bottom: 5),
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: RaisedButton(
                            color: Color(0xFFf1d300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(30, 30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ManageCoupon()));
                            },
                            child: Center(
                                child: Text('Manage Coupons',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20))),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 5, left: 10, right: 5, bottom: 15),
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: RaisedButton(
                            color: Color(0xFFf1d300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(30, 30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Bank()));
                            },
                            child: Center(
                                child: Text('Bank Details',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20))),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 5, right: 10, left: 5, bottom: 15),
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: RaisedButton(
                            color: Color(0xFFf1d300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(30, 30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PromoteBrand()));
                            },
                            child: Center(
                                child: Text('Promote your brand',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20))),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.vertical(
              top: Radius.elliptical(30, 30),
            ),
          ),
        ),
      ),
    );
  }

  showMerchantEarning() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var merchantid = prefs.getString('merchantid');
    try {
      Response response = await get(
        kUrl + '/merchantEarning',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'merchantid': merchantid
        },
      ).timeout(const Duration(seconds: 10));
      String body = response.body;
      String status = json.decode(body)['message'];
      onGetMerchantEarning(status);
      int code = json.decode(body)['status'];
      List data = json.decode(body)['data'];
      print(body);
      print(code);
      if (code == 200) {
        double sum = 0;
        data.forEach((element) {
          sum += element;
        });
        setState(() {
          merchantEarning = sum.toStringAsFixed(2);
        });
        print(merchantEarning);
      } else if (status == 'error blank data while updating payments') {
        setState(() {
          merchantEarning = '0';
        });
      } else {
        Toast.show(
          "Error Fetching Data",
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.red[200],
        );
      }
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

  showCouponIssued() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var merchantid = prefs.getString('merchantid');
    try {
      Response response = await get(
        kUrl + '/getCouponCountDist',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'merchantid': merchantid
        },
      ).timeout(const Duration(seconds: 10));
      String body = response.body;
      String status = json.decode(body)['message'];
      int code = json.decode(body)['status'];
      int data = json.decode(body)['data'];
      onGetCouponIssued(status);
      print(body);
      print(code);
      if (code == 200) {
        setState(() {
          couponissued = data.toString();
        });
      } else if (status ==
          'error no coupon found for merchant as no active coupon exist') {
        setState(() {
          couponissued = 0.toString();
        });
      } else {
        Toast.show(
          "Error Fetching Data",
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.red[200],
        );
      }
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

  showCouponRedeemed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var merchantid = prefs.getString('merchantid');
    try {
      Response response = await get(
        kUrl + '/getCouponCountUsed',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'merchantid': merchantid
        },
      ).timeout(const Duration(seconds: 10));
      String body = response.body;
      String status = json.decode(body)['message'];
      onGetCouponRedeemed(status);
      int code = json.decode(body)['status'];
      int data = json.decode(body)['data'];
      print(body);
      print(code);
      if (code == 200) {
        print(data);
        couponredeemed = data.toString();
      } else if (status ==
          'error no coupon found for merchant as no active coupon exist') {
        couponredeemed = 0.toString();
      } else {
        Toast.show(
          "Error Fetching Data",
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.red[200],
        );
      }
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

  onGetMerchantEarning(String status) async {
    fcm.getToken().then((value) {
      print(value);
      var result = mix.mixpanelAnalytics.track(
          event: 'onGetMerchantEarning',
          properties: {'status': status, 'distinct_id': value});
      result.then((value) {
        print('this is on click');
        print(value);
      });
    });
  }

  onGetCouponIssued(String status) async {
    fcm.getToken().then((value) {
      print(value);
      var result = mix.mixpanelAnalytics.track(
          event: 'onGetCouponIssued',
          properties: {'status': status, 'distinct_id': value});
      result.then((value) {
        print('this is on click');
        print(value);
      });
    });
  }

  onGetCouponRedeemed(String status) async {
    fcm.getToken().then((value) {
      print(value);
      var result = mix.mixpanelAnalytics.track(
          event: 'onGetCouponRedeemed',
          properties: {'status': status, 'distinct_id': value});
      result.then((value) {
        print('this is on click');
        print(value);
      });
    });
  }
}
