import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:merchantfrontapp/models/create_coupon.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:merchantfrontapp/widgets/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'landing_page.dart';

class CouponGenerate extends StatefulWidget {
  String initialDiscount;
  String initialflatDiscount;
  DateTime start;
  DateTime end;
  bool edit;

  CouponGenerate(
      {this.initialDiscount = null,
      this.initialflatDiscount = null,
      this.start,
      this.end,
      this.edit = false});
  @override
  _CouponGenerateState createState() => _CouponGenerateState();
}

class _CouponGenerateState extends State<CouponGenerate> {
  bool _autoValidate = false;
  final _formKey = GlobalKey<FormState>();
  String discount;
  String flatDiscount;
  String startDate;
  String endDate;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        child: Form(
          autovalidate: _autoValidate,
          key: _formKey,
          child: ListView(
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
              TextFormField(
                initialValue: this.widget.initialDiscount,
                onSaved: (String value) {
                  discount = value;
                },
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val.isEmpty) {
                    return 'This field is required';
                  } else if (int.parse(val) == 0) {
                    return 'This field is required';
                  } else {
                    return null;
                  }
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter the discount in %',
                  labelText: 'Discount (%)',
                ),
              ),
              TextFormField(
                initialValue: this.widget.initialflatDiscount,
                keyboardType: TextInputType.number,
                onSaved: (String value) {
                  flatDiscount = value;
                },
                validator: (val) {
                  if (val.isEmpty) {
                    return 'This field is required';
                  } else if (int.parse(val) == 0) {
                    return 'This field is required';
                  } else {
                    return null;
                  }
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter the maximum discount in Rs.',
                  labelText: 'Flat Discount upto (INR)',
                ),
              ),
              Container(
                child: DateTimeField(
                  initialValue: this.widget.start,
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(Duration(days: 1)),
                        initialDate: this.widget.start,
                        lastDate: DateTime(2100));
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'You have to specify the start date';
                    } else {
                      return null;
                    }
                  },
                  format: DateFormat("dd-MM-yyyy"),
                  decoration:
                      InputDecoration(labelText: 'Select starting date'),
                  onSaved: (value) {
                    this.widget.start = value;
                  },
                ),
              ),
              Container(
                child: DateTimeField(
                  initialValue: this.widget.end,
                  validator: (value) {
                    if (value == null) {
                      return 'You have to specify the end date';
                    } else if (this.widget.start == null) {
                      return 'First specify the start date';
                    } else if (value.difference(this.widget.start).inDays < 1) {
                      return 'End date cannot be before start date';
                    } else if (!(value.difference(this.widget.start).inDays <
                        1)) {
                      return null;
                    }
                  },
                  onShowPicker: (context, currentValue) {
                    return showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(Duration(days: 1)),
                        initialDate: this.widget.end,
                        lastDate: DateTime(2100));
                  },
                  format: DateFormat("dd-MM-yyyy"),
                  decoration: InputDecoration(labelText: 'Select ending date'),
                  onSaved: (value) {
                    this.widget.end = value;
                  },
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text('Generate Form'),
                    onPressed: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
                        _formKey.currentState.save();
                        startDate =
                            DateFormat('dd-MM-yyyy').format(this.widget.start);
                        endDate =
                            DateFormat('dd-MM-yyyy').format(this.widget.end);
                        print('this is difference');
                        print(this
                            .widget
                            .end
                            .difference(this.widget.start)
                            .inDays
                            .runtimeType);
                        Coupon c = new Coupon(
                          discount: discount.trim(),
                          flatdiscount: flatDiscount.trim(),
                          startdate: startDate,
                          enddate: endDate,
                        );
                        if (this.widget.edit) {
                          editCoupon(c);
                        } else {
                          createCoupon(c);
                        }
                      } else {
                        _autoValidate = true;
                        print(DateTime.now());
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//Coupon Creation
  createCoupon(Coupon c) async {
    print('this is add');
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); //get merchant id
    final merchantkey = 'merchantid';
    String merchantid = prefs.getString(merchantkey);
    print(merchantid);

    try {
      Response response = await post(
        kCouponGenerate,
        headers: {
          'merchantid': merchantid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'discount': c.discount,
          'faltdiscountupto': c.flatdiscount,
          'startdate': c.startdate,
          'enddate': c.enddate,
        }),
      ).timeout(const Duration(seconds: 10));
      String body = response.body;
      String status = json.decode(body)['message'];
      print(body);
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
      } else if (status == ' data is stored') {
        Toast.show(
          "Success: Your Coupon has been created", //coupon created
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.green[200],
        );
        Future.delayed(const Duration(milliseconds: 3000), () {
// Here you can write your code
          Navigator.pop(context);
        });
        print(body);
      } else if (status == '1st coupon of the merchant is active') {
        //1st coupon active
        Toast.show(
          "Please deactivate the previous coupon",
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

  editCoupon(Coupon c) async {
    print('this is eidt');
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); //get merchant id
    final merchantkey = 'merchantid';
    String merchantid = prefs.getString(merchantkey);
    try {
      Response response = await put(
        kCouponEdit,
        headers: {
          'merchantid': merchantid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'discount': c.discount,
          'faltdiscountupto': c.flatdiscount,
          'startdate': c.startdate,
          'enddate': c.enddate,
        }),
      ).timeout(const Duration(seconds: 10));
      String body = response.body;

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
      } else if (status == ' data is stored') {
        Toast.show(
          "Success: Your Coupon has been edited", //coupon created
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.green[200],
        );
        Future.delayed(const Duration(milliseconds: 3000), () {
          Navigator.pop(context);
// Here you can write your code
        });
      } else if (status == '1st coupon of the merchant is active') {
        //1st coupon active
        Toast.show(
          "Please deactivate the previous coupon",
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.red[200],
        );
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
