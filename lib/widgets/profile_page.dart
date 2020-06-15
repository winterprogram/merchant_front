import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:merchantfrontapp/models/merchant_signup.dart';
import 'package:merchantfrontapp/widgets/Mixpanel.dart';
import 'package:merchantfrontapp/widgets/reset_pass_form.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'constants.dart';
import 'custom_dialog.dart';
import 'landing_page.dart';
import 'fcm_notification.dart';

class BoolValue {
  TextEditingController controller;
  bool edit;
  BoolValue(this.edit);
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const platformMethodChannel = const MethodChannel('merchant/getGPS');
  Geolocator geolocator = Geolocator();
  Position userLocation;
  FcmNotification fcm;
  Merchant m;
  BoolValue shopEdit = BoolValue(false);
  TextEditingController shopName = TextEditingController();
  BoolValue mobileEdit = BoolValue(false);
  TextEditingController mobileName = TextEditingController();
  BoolValue addressEdit = BoolValue(false);
  TextEditingController addressName = TextEditingController();
  BoolValue cityEdit = BoolValue(false);
  TextEditingController cityName = TextEditingController();
  BoolValue zipEdit = BoolValue(false);
  TextEditingController zipName = TextEditingController();
  BoolValue mailEdit = BoolValue(false);
  TextEditingController mailName = TextEditingController();
  MixPanel mix = MixPanel();
  @override
  void initState() {
    mix.createMixPanel();
    fcm = new FcmNotification(context: context);
    fcm.initialize();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    shopName.dispose();
    mobileName.dispose();
    addressName.dispose();
    cityName.dispose();
    zipName.dispose();
    mailName.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: FutureBuilder(
      future: createMerchant(),
      builder: (context, asyncSnap) {
        if (asyncSnap.hasError) {
          return Text('An Error Occurred');
        } else if (asyncSnap.hasData) {
          m = asyncSnap.data;
          setMerchantController();
          return Container(
            color: Color(0xFFf1d300),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.vertical(
                  top: Radius.elliptical(30, 30),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.elliptical(30, 30))),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Profile',
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Name',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(m.fullname)
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: showEditTextBox(
                            'Shop Name',
                            shopName,
                            shopEdit,
                            '/merchantShopNameChange',
                            'shopname',
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: showEditTextBox(
                            'E-Mail',
                            mailName,
                            mailEdit,
                            '/merchantEmailChange',
                            'email',
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Mobile Number',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(m.mobilenumber)
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Password',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          RaisedButton(
                            color: kOverallColor,
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ResetPassword()));
                            },
                            child: Text('Reset'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: showEditTextBox(
                            'Address',
                            addressName,
                            addressEdit,
                            '/merchantAddressChange',
                            'address',
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: showEditTextBox('City', cityName, cityEdit,
                              '/merchantCityChange', 'city')),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: showEditTextBox('Zip Code', zipName,
                              zipEdit, '/merchantZipcodeChange', 'zipcode')),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Geo Location',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          RaisedButton(
                            color: kOverallColor,
                            onPressed: () {
                              changeGeoLocation();
                            },
                            child: Text('Reset'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    ));
  }

  setMerchantController() {
    shopName.text = m.shopname;
    mobileName.text = m.mobilenumber;
    addressName.text = m.address;
    cityName.text = m.city;
    zipName.text = m.zipcode;
    mailName.text = m.mailid;
  }

  showEditTextBox(String profileKey, TextEditingController profileValue,
      BoolValue edit, String url, String param) {
    if (edit.edit == true) {
      return [
        Text(
          profileKey,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(width: 150, child: TextField(controller: profileValue)),
              IconButton(
                icon: Icon(Icons.check),
                onPressed: () {
                  editProfileDetails(
                      url, param, profileValue, {param: profileValue.text});
                  setState(() {
                    edit.edit = false;
                  });
                },
              )
            ],
          ),
        )
      ];
    } else {
      return [
        Text(
          profileKey,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: <Widget>[
            Text(profileValue.text),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  edit.edit = true;
                });
              },
            )
          ],
        )
      ];
    }
  }

  createMerchant() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return Merchant(
        zipcode: prefs.getString('zipcode'),
        shopname: prefs.getString('shopname'),
        mobilenumber: prefs.getString('mobile'),
        mailid: prefs.getString('email'),
        city: prefs.getString('city'),
        fullname: prefs.getString('name'),
        address: prefs.getString('address'));
  }

  editProfileDetails(String url, String param, TextEditingController controller,
      Map<String, dynamic> bodyMap) async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); //get merchant id
    final merchantkey = 'merchantid';
    String merchantid = prefs.getString(merchantkey);
    print(merchantid);

    try {
      Response response = await put(
        kUrl + url,
        headers: {
          'merchantid': merchantid,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyMap),
      ).timeout(const Duration(seconds: 20));
      String body = response.body;
      print(body);
      String status = json.decode(body)['message'];
      int code = json.decode(body)['status'];
      onEditProfile(status);
      if (code == 200) {
        Toast.show(
          "Bank Details Updated", //coupon created
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.green[200],
        );
        if (param != null) {
          prefs.setString(param, controller.text);
        }
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
      } else if (code == 500) {
        Toast.show('This Merchant is not found. Login Again', context,
            duration: 3,
            gravity: Toast.BOTTOM,
            textColor: Colors.black,
            backgroundColor: Colors.red[200]);
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LandingPage()),
              (Route<dynamic> route) => false);
        });
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

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  Future _checkGps(String message) async {
    print('running gps function2');
    await CustomDialog.show(
            context,
            'GPS turned off',
            'Gps should be turned on for login',
            'Open location settings',
            AppSettings.openLocationSettings)
        .then((_) {
      return;
    });
  }

  //to know if gps is on
  Future<bool> _getGPS() async {
    String _message;
    try {
      final String result = await platformMethodChannel.invokeMethod('getGPS');
      _message = result;
      print('this is _message' + _message);
      if (_message == 'false') {
        await _checkGps(_message).then((value) {
          _getGPS();
        });
        print('this is _checkGps ' + _message);
      } else {
        return true;
      }
    } on PlatformException catch (e) {
      _message = "Can't do native stuff ${e.message}.";
    }
    return true;
  }

  changeGeoLocation() {
    _getGPS().then((value) {
      print(value);
      if (value == true) {
        _getLocation().then((position) {
          if (!mounted) {
            return;
          }
          setState(() {
            userLocation = position;

            //userLocation =
            //  Position(latitude: 29.474045, longitude: 77.695810);
            editProfileDetails(
              '/merchantGeoChange',
              null,
              null,
              {
                'latitude': userLocation.latitude.toString(),
                'longitude': userLocation.longitude.toString()
              },
            );
          });
        });
      }
    });
  }

  onEditProfile(String status) async {
    fcm.getToken().then((value) {
      print(value);
      var result = mix.mixpanelAnalytics.track(
          event: 'onEditProfile',
          properties: {'status': status, 'distinct_id': value});
      result.then((value) {
        print('this is on click');
        print(value);
      });
    });
  }
}
