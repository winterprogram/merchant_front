import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:merchantfrontapp/models/create_coupon.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart';
import 'package:merchantfrontapp/widgets/constants.dart';
import 'package:merchantfrontapp/widgets/coupon_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'landing_page.dart';

class ManageCoupon extends StatefulWidget {
  @override
  _ManageCouponState createState() => _ManageCouponState();
}

class _ManageCouponState extends State<ManageCoupon> {
  Future<String> check;
  String discount;
  String flatdiscount;
  String startdate;
  String enddate;

  @override
  void initState() {
    check = manageCoupon(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.grey[300],
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  FutureBuilder(
                    builder: (context, projectSnap) {
                      if (projectSnap.data == 'Coupon') {
                        return SizedBox();
                      } else if (projectSnap.data == 'Error') {
                        return SizedBox();
                      } else if (projectSnap.data == 'Noactive') {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: FlatButton(
                            shape: CircleBorder(),
                            child: Icon(Icons.add),
                            onPressed: () {
                              openCreateForm(context);
                            },
                          ),
                        );
                      } else {
                        return SizedBox();
                      }
                    },
                    future: check,
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder(
                  builder: (context, projectSnap) {
                    print(check);
                    if (projectSnap.data == 'Coupon') {
                      return Coupon(
                              editFunction: () {
                                openEditForm(context);
                              },
                              deleteFunction: () {
                                setState(() {
                                  check = deleteCoupon(context);
                                });
                              },
                              discount: discount,
                              flatdiscount: discount,
                              startdate: startdate,
                              enddate: enddate)
                          .createCoupon();
                    } else if (projectSnap.data == 'Error') {
                      return Text('Some error occured',
                          style: TextStyle(fontSize: 20));
                    } else if (projectSnap.data == 'Noactive') {
                      return Text(
                          'No active coupon. Create by clicking on add icon',
                          style: TextStyle(fontSize: 20));
                    } else {
                      return Text('Some error occured',
                          style: TextStyle(fontSize: 20));
                    }
                  },
                  future: check,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> manageCoupon(context) async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); //get merchant id
    final merchantkey = 'merchantid';
    String merchantid = prefs.getString(merchantkey);
    try {
      Response response = await get(
        kCouponsManage,
        headers: <String, String>{
          'merchantid': merchantid,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      String body = response.body;
      print(body);
      String status = json.decode(body)['message'];
      if (status == ' coupon fetched') {
        List coupondata = json.decode(body)['data'];
        discount = coupondata[0]['discount'];
        flatdiscount = coupondata[0]['faltdiscountupto'];
        startdate = coupondata[0]['startdate'];
        enddate = coupondata[0]['enddate'];
        return 'Coupon';
      } else if (status == 'error while fetching merchant coupon details') {
        //1st coupon active
        return 'Error';
      } else {
        return 'Noactive';
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

  openCreateForm(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CouponGenerate(
          start: DateTime.now(),
          end: DateTime.now(),
        ),
      ),
    );
    print('i am back from add');
    setState(() {
      check = manageCoupon(context);
    });
  }

  openEditForm(BuildContext context) async {
    DateTime end = DateFormat('dd-MM-yyyy').parse(enddate);
    DateTime start = DateFormat('dd-MM-yyyy').parse(startdate);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CouponGenerate(
          initialDiscount: discount,
          initialflatDiscount: flatdiscount,
          start: start,
          end: end,
          edit: true,
        ),
      ),
    );
    setState(() {
      check = manageCoupon(context);
    });
  }

  Future<String> deleteCoupon(context) async {
    print('hi');
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); //get merchant id
    final merchantkey = 'merchantid';
    String merchantid = prefs.getString(merchantkey);
    print(merchantid);

    try {
      Response response = await put(
        kCouponDelete,
        headers: {
          'merchantid': merchantid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{}),
      ).timeout(const Duration(seconds: 10));
      String body = response.body;
      print(body);
      String status = json.decode(body)['message'];
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
            MaterialPageRoute(builder: (BuildContext ctx) => LandingPage()),
            ModalRoute.withName('/'));
      } else if (status == ' coupon delete') {
        Toast.show(
          "Success: Your Coupon has been deleted", //coupon created
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.green[200],
        );
        return 'Noactive';
      } else if (status == 'coupon exist didn\'t exist for this merchant') {
        //1st coupon active
        Toast.show(
          "No coupon exists",
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.red[200],
        );
        return 'Noactive';
      }
      print(body);
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
}
