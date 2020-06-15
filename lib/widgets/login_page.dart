import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:merchantfrontapp/widgets/Mixpanel.dart';
import 'package:merchantfrontapp/widgets/common_button.dart';
import 'package:merchantfrontapp/widgets/constants.dart';
import 'package:merchantfrontapp/widgets/upload_image.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:merchantfrontapp/widgets/dashboard.dart';

import 'fcm_notification.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  FcmNotification fcm;
  bool _autoValidate = false;
  SharedPreferences prefs;
  final _formKey = GlobalKey<FormState>();
  String phone;
  String password;
  MixPanel mix = MixPanel();

  @override
  void initState() {
    super.initState();
    fcm = new FcmNotification(context: context);
    fcm.initialize();
    mix.createMixPanel();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Form(
          autovalidate: _autoValidate,
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                onSaved: (String value) {
                  phone = value;
                },
                validator: (val) => val.length != 10
                    ? 'Phone Number should have 10 digits'
                    : null,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  icon: IconTheme(
                    data: IconThemeData(
                      color: Color(0xFFf1d300),
                    ),
                    child: Icon(Icons.contact_phone),
                  ),
                  hintText: 'Enter your mobile number',
                  labelText: 'Mobile Number',
                ),
              ),
              TextFormField(
                onSaved: (String value) {
                  password = value;
                },
                obscureText: true,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  icon: IconTheme(
                    data: IconThemeData(
                      color: Color(0xFFf1d300),
                    ),
                    child: Icon(Icons.security),
                  ),
                  hintText: 'Enter your password',
                  labelText: 'Password',
                ),
              ),
              Container(
                  child: ClickButton(
                      buttonTitle: 'Login',
                      buttonFunction: () {
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }

                        if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
                          _formKey.currentState.save();
                          print(phone);
                          loginMerchant(context, phone, password);
                        } else {
                          _autoValidate = true;
                        }
                      })),
            ],
          ),
        ),
      ),
    );
  }

  loginMerchant(BuildContext context, String mobile, String password) async {
    fcm.getToken().then((value) async {
      var deviceToken = value;
      try {
        Response response = await post(
          kUrl + '/merchantlogin',
          headers: <String, String>{'Content-Type': 'application/json'},
          body: jsonEncode(<String, dynamic>{
            'mobilenumber': mobile,
            'password': password,
            'devicetoken': deviceToken,
          }),
        ).timeout(const Duration(seconds: 10));
        String body = response.body;
        String status = json.decode(body)['message'];
        print(status);
        onLogin(status);
        if (status == 'successful login') {
          Toast.show(
            "Login Successful",
            context,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.BOTTOM,
            textColor: Colors.black,
            backgroundColor: Colors.green[200],
          );
          print(json.decode(body)['data']['merchantData']['shopname']);
          save(
            address: json.decode(body)['data']['merchantData']['address'],
            city: json.decode(body)['data']['merchantData']['city'],
            merchantid: json.decode(body)['data']['merchantid'],
            mailid: json.decode(body)['data']['merchantData']['email'],
            shopname: json.decode(body)['data']['merchantData']['shopname'],
            zipcode: json.decode(body)['data']['merchantData']['zipcode'],
            mobile: json.decode(body)['data']['merchantData']['mobilenumber'],
            name: json.decode(body)['data']['merchantData']['fullname'],
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
                (Route<dynamic> route) => false,
              );
            });
          });
        } else if (status == 'images are not uploaded by this merchant') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => ImagePickerWidget(mobile, password)),
            (Route<dynamic> route) => false,
          );
        } else {
          Toast.show(
            "Icorrect username/password",
            context,
            duration: 3,
            gravity: Toast.BOTTOM,
            textColor: Colors.black,
            backgroundColor: Colors.red[200],
          );
        }

        //call saving keys function
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
    });
  }

//save keys function
  void save(
      {String merchantid,
      String shopname,
      String name,
      String address,
      String city,
      String mobile,
      String mailid,
      String zipcode}) async {
    print(merchantid);
    print('hi');
    prefs = await SharedPreferences.getInstance(); //get instance of app memory
    final merchantkey = 'merchantid';
    //save keys in memory
    prefs.setString(merchantkey, merchantid);
    prefs.setString('shopname', shopname);
    prefs.setString('name', name);
    prefs.setString('address', address);
    prefs.setString('city', city);
    prefs.setString('mobile', mobile);
    prefs.setString('mailid', mailid);
    prefs.setString('zipcode', zipcode);
    print(prefs.getString(merchantkey));
  }

  onLogin(String status) async {
    fcm.getToken().then((value) {
      print(value);
      var result = mix.mixpanelAnalytics.track(
          event: 'onLogin',
          properties: {'status': status, 'distinct_id': value});
      result.then((value) {
        print('this is on click');
        print(value);
      });
    });
  }
}
