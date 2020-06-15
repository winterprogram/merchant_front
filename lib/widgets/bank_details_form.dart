import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:merchantfrontapp/widgets/Mixpanel.dart';
import 'package:merchantfrontapp/widgets/fcm_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'constants.dart';
import 'landing_page.dart';

class BankDetails extends StatefulWidget {
  final bool edit;
  BankDetails(this.edit);
  @override
  _BankDetailsState createState() => _BankDetailsState(edit);
}

class _BankDetailsState extends State<BankDetails> {
  FcmNotification fcm;
  MixPanel mix = MixPanel();
  final accno = TextEditingController();
  final accverify = TextEditingController();
  final ifscCode = TextEditingController();
  final bankName = TextEditingController();
  bool _autoValidate = false;
  final _formKey = GlobalKey<FormState>();
  final bool edit;
  _BankDetailsState(this.edit);

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
    accno.dispose();
    accverify.dispose();
    ifscCode.dispose();
    bankName.dispose();
    fcm.close();
  }

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
                controller: accno,
                onSaved: (String value) {},
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Required';
                  } else {
                    return null;
                  }
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your account number',
                  labelText: 'Account No.',
                ),
              ),
              TextFormField(
                controller: accverify,
                onSaved: (String value) {},
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Required';
                  } else if (accno.text != accverify.text) {
                    return 'Account Number does not match';
                  } else {
                    return null;
                  }
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Verify Account number',
                  labelText: 'Account No.',
                ),
              ),
              TextFormField(
                controller: ifscCode,
                validator: (val) {
                  Pattern pattern = r'^[A-Za-z]{4}0[A-Z0-9a-z]{6}$';
                  RegExp regex = new RegExp(pattern);
                  if (val.isEmpty) {
                    return 'Required';
                  } else if (!regex.hasMatch(val)) {
                    return 'Enter Valid IFSC code';
                  } else {
                    return null;
                  }
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter IFSC Code',
                  labelText: 'IFSC Code',
                ),
              ),
              TextFormField(
                controller: bankName,
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Required';
                  } else {
                    return null;
                  }
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Bank Name',
                  labelText: 'Bank Name',
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: RaisedButton(
                    color: kOverallColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text('Submit'),
                    onPressed: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
                        _formKey.currentState.save();
                        print(edit);
                        if (edit) {
                          editBankDetails();
                        } else {
                          uploadBankDetails();
                        }
                      } else {
                        _autoValidate = true;
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

  editBankDetails() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); //get merchant id
    final merchantkey = 'merchantid';
    String merchantid = prefs.getString(merchantkey);
    print(merchantid);

    try {
      Response response = await put(
        kUrl + '/merchantBankChange',
        headers: {
          'merchantid': merchantid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'bankAccount': accno.text,
          'ifscCode': ifscCode.text,
          'bankName': bankName.text
        }),
      ).timeout(const Duration(seconds: 20));
      String body = response.body;
      print(body);
      String status = json.decode(body)['message'];
      int code = json.decode(body)['status'];
      if (code == 200) {
        Toast.show(
          "Bank Details Updated", //coupon created
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.red[200],
        );
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else if (status == 'auth token is empty' ||
          status == 'merchantid not found in db') {
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

  uploadBankDetails() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); //get merchant id
    final merchantkey = 'merchantid';
    String merchantid = prefs.getString(merchantkey);
    print(merchantid);

    try {
      Response response = await post(
        kUrl + '/bankdeatils',
        headers: {
          'merchantid': merchantid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'bankAccount': accno.text,
          'ifscCode': ifscCode.text,
          'bankName': bankName.text
        }),
      ).timeout(const Duration(seconds: 20));
      String body = response.body;
      print(body);
      String status = json.decode(body)['message'];
      onSubmitBankDetails(status);
      int code = json.decode(body)['status'];
      if (code == 200) {
        Toast.show(
          "Bank Details Updated", //coupon created
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.red[200],
        );
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } else if (status == 'auth token is empty') {
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
      } else if (status == ' coupon delete') {}
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

  onSubmitBankDetails(String status) async {
    fcm.getToken().then((value) {
      print(value);
      var result = mix.mixpanelAnalytics.track(
          event: 'onSubmitBankDetails',
          properties: {'status': status, 'distinct_id': value});
      result.then((value) {
        print('this is on click');
        print(value);
      });
    });
  }
}
