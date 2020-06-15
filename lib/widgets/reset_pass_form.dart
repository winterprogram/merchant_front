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

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  FcmNotification fcm;
  MixPanel mix = MixPanel();
  @override
  Widget build(BuildContext context) {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();
    final newPassVerify = TextEditingController();
    bool _autoValidate = false;
    final _formKey = GlobalKey<FormState>();
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
                controller: oldPass,
                onSaved: (String value) {},
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Required';
                  } else {
                    return validatePassword(val);
                  }
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your old password',
                  labelText: 'Old Password',
                ),
              ),
              TextFormField(
                controller: newPass,
                keyboardType: TextInputType.number,
                onSaved: (String value) {},
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Required';
                  } else {
                    return validatePassword(val);
                  }
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter new Password',
                  labelText: 'New Password',
                ),
              ),
              TextFormField(
                controller: newPassVerify,
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Required';
                  } else if (newPass.text != newPassVerify.text) {
                    return 'Password does not match';
                  } else {
                    return null;
                  }
                },
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Renter new password',
                  labelText: 'Verify New Password',
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Text('Change Password'),
                    onPressed: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
                        _formKey.currentState.save();
                        resetPass(oldPass.text, newPass.text);
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

  String validatePassword(String value) {
    Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.{8,})';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value.length < 6)
      return 'Must contain - Alphabet (Caps/small), Number and Specialsdfs';
    else
      return null;
  }

  resetPass(String password, String newPassword) async {
    print('hi');
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); //get merchant id
    final merchantkey = 'merchantid';
    String merchantid = prefs.getString(merchantkey);
    print(merchantid);

    try {
      Response response = await put(
        kUrl + '/resetpassmerchant',
        headers: {
          'merchantid': merchantid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'password': password,
          'newpassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 20));
      String body = response.body;
      print(body);
      String status = json.decode(body)['message'];
      int code = json.decode(body)['status'];
      onResetPass(status);
      if (code == 200) {
        Toast.show(
          "Password Reset Successful", //coupon created
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.green[200],
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
            (Route<dynamic> route) => false);
      } else if (status == 'password didn\'t matched') {
        Toast.show(
          "Old password is not correct", //coupon created
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

  onResetPass(String status) async {
    fcm.getToken().then((value) {
      print(value);
      var result = mix.mixpanelAnalytics.track(
          event: 'onResetPass',
          properties: {'status': status, 'distinct_id': value});
      result.then((value) {
        print('this is on click');
        print(value);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    mix.createMixPanel();
    fcm = new FcmNotification(context: context);
    fcm.initialize();
  }
}
