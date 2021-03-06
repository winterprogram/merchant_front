import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:merchantfrontapp/widgets/Mixpanel.dart';
import 'package:merchantfrontapp/widgets/common_button.dart';
import 'package:merchantfrontapp/models/merchant_signup.dart';
import 'package:http/http.dart';
import 'package:merchantfrontapp/widgets/constants.dart';
import 'package:mixpanel_analytics/mixpanel_analytics.dart';
import 'dart:convert';
import 'package:toast/toast.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent/android_intent.dart';

import 'fcm_notification.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  MixPanel mix = MixPanel();
  FcmNotification fcm;
  static const platformMethodChannel = const MethodChannel('merchant/getGPS');
  String nativeMessage = '';
  bool _autoValidate = false;
  final _formKey = GlobalKey<FormState>();
  String shopName;
  String name;
  String phone;
  final password = TextEditingController();
  final verifyPassword = TextEditingController();
  String email;
  String address;
  String zipcode;
  String selectedCity;
  String selectedCategory;
  Geolocator geolocator = Geolocator();
  Position userLocation;
  List<String> geolocation = List<String>(2);
  final List<String> category = <String>[
    'Restaurant/Bar',
    'Beauty Salon/Spa',
    'Cafe/Fast Food',
    'Ice-Cream Parlour',
    'Boutiques'
  ];
  final List<String> city = <String>['Navi Mumbai', 'Thane', 'Mumbai'];
  final String textField = 'display';
  final String valueField = 'value';

  @override
  void initState() {
    mix.createMixPanel();
    super.initState();
    fcm = new FcmNotification(context: context);
    fcm.initialize();
    requestLocationPermission();
    //_gpsService();
    _getGPS();
    _getLocation().then((position) {
      userLocation = position;
    });
  }

  @override
  void dispose() {
    super.dispose();
    password.dispose();
    verifyPassword.dispose();
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
                onSaved: (String value) {
                  name = value;
                },
                validator: (val) => val.isEmpty ? 'Name is required' : null,
                textCapitalization: TextCapitalization.words,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  icon: IconTheme(
                    data: IconThemeData(
                      color: Color(0xFFf1d300),
                    ),
                    child: Icon(Icons.person),
                  ),
                  hintText: 'Enter Your Full Name',
                  labelText: 'Full Name',
                ),
              ),
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
                controller: password,
                validator: validatePassword,
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
              TextFormField(
                controller: verifyPassword,
                validator: (val) {
                  if (val.isEmpty) {
                    return 'Required';
                  } else if (password.text != verifyPassword.text) {
                    return 'Password does not match';
                  } else {
                    return null;
                  }
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
                  hintText: 'Enter your password again',
                  labelText: 'Verify Password',
                ),
              ),
              TextFormField(
                onSaved: (String value) {
                  email = value;
                },
                validator: validateEmail,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  icon: IconTheme(
                    data: IconThemeData(
                      color: Color(0xFFf1d300),
                    ),
                    child: Icon(Icons.email),
                  ),
                  hintText: 'Enter your email address eg - abc@xyz.com',
                  labelText: 'Email',
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    child: IconTheme(
                      data: IconThemeData(
                        color: Color(0xFFf1d300),
                      ),
                      child: Icon(Icons.location_city),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      child: DropdownButtonFormField<String>(
                        validator: (value) =>
                            value == null ? 'City is required' : null,
                        hint: Text(
                          'Select City',
                          style: TextStyle(color: Colors.black),
                        ),
                        value: selectedCity,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        onChanged: (String newValue) {
                          setState(() {
                            selectedCity = newValue;
                          });
                        },
                        items:
                            city.map<DropdownMenuItem<String>>((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                onSaved: (String value) {
                  shopName = value;
                },
                validator: (val) =>
                    val.isEmpty ? 'Name of your Shop is required' : null,
                // keyboardType: TextInputType.multiline,
                // maxLines: null,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  icon: IconTheme(
                    data: IconThemeData(
                      color: Color(0xFFf1d300),
                    ),
                    child: Icon(Icons.shopping_cart),
                  ),
                  hintText: 'Enter your Shop Name',
                  labelText: 'Shop Name',
                ),
              ),
              TextFormField(
                onSaved: (String value) {
                  address = value;
                },
                validator: (val) => val.isEmpty ? 'Address is required' : null,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  icon: IconTheme(
                    data: IconThemeData(
                      color: Color(0xFFf1d300),
                    ),
                    child: Icon(Icons.location_on),
                  ),
                  hintText: 'Enter your shop address',
                  labelText: 'Shop Address',
                ),
              ),
              TextFormField(
                onSaved: (String value) {
                  zipcode = value;
                },
                validator: (val) => val.isEmpty ? 'Zip Code is required' : null,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  icon: IconTheme(
                    data: IconThemeData(
                      color: Color(0xFFf1d300),
                    ),
                    child: Icon(Icons.code),
                  ),
                  hintText: 'Enter your zip code',
                  labelText: 'Zip Code',
                ),
              ),
              Row(
                children: <Widget>[
                  Container(
                    child: IconTheme(
                      data: IconThemeData(
                        color: Color(0xFFf1d300),
                      ),
                      child: Icon(Icons.apps),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Container(
                      child: DropdownButtonFormField<String>(
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        hint: Text(
                          'Select Category',
                          style: TextStyle(color: Colors.black),
                        ),
                        value: selectedCategory,
                        onChanged: (String newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                        items: category
                            .map<DropdownMenuItem<String>>((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                child: ClickButton(
                  buttonTitle: 'SignUp',
                  buttonFunction: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                    if (_formKey.currentState.validate()) {
//    If all data are correct then save data to out variables
                      _formKey.currentState.save();
                      _getLocation().then((value) {
                        userLocation = value;
                      });
                      geolocation[0] = userLocation.latitude.toString();
                      geolocation[1] = userLocation.longitude.toString();
                      print(geolocation[0]);
                      Merchant m = new Merchant(
                        fullname: name.trim(),
                        mailid: email.trim(),
                        city: selectedCity,
                        password: password.text.trim(),
                        address: address.trim(),
                        zipcode: zipcode.trim(),
                        mobilenumber: phone.trim(),
                        category: selectedCategory,
                        shopname: shopName.trim(),
                        latitude: geolocation[0],
                        longitude: geolocation[1],
                      );
                      print(m.latitude);
                      createMerchant(m);
                    } else {
                      _autoValidate = true;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String validateEmail(String value) {
    Pattern pattern = r'^[a-zA-z]+\W?\w+\W+[a-z]+\W+\w+';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  String validatePassword(String value) {
    Pattern pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.{8,})';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value) || value.length < 6)
      return 'Must contain - Alphabet (Caps/small), Number and Specialsdfs';
    else
      return null;
  }

  createMerchant(Merchant m) async {
    try {
      Response response = await post(
        kUrl + '/merchantSignup',
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, dynamic>{
          'fullname': m.fullname,
          'mobilenumber': m.mobilenumber,
          'password': m.password,
          'email': m.mailid,
          'city': m.city,
          'address': m.address,
          'zipcode': m.zipcode,
          'shopname': m.shopname,
          'category': m.category,
          'latitude': m.latitude,
          'longitude': m.longitude,
        }),
      ).timeout(const Duration(seconds: 10));
      String body = response.body;

      String status = json.decode(body)['message'];

      if (status == 'user registered') {
        onCreateAccount(m);
        Toast.show(
          "Success: Your account has been created. Please login.",
          context,
          duration: 3,
          gravity: Toast.BOTTOM,
          textColor: Colors.black,
          backgroundColor: Colors.green[200],
        );
        Future.delayed(const Duration(milliseconds: 3000), () {
// Here you can write your code

          setState(() {
            Navigator.pop(context, true);
            // Here you can write your code for open new view
          });
        });
      } else if (status == 'user already exist') {
        Toast.show(
          "Failure: Your account already exists.",
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

  //Code below is for asking location
  Future<bool> _requestPermission(Permission permission) async {
    PermissionStatus permissionStatus = await permission.status;

    if (permissionStatus == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

/*Checking if your App has been Given Permission*/
  Future<bool> requestLocationPermission({Function onPermissionDenied}) async {
    var granted = await _requestPermission(Permission.location);
    if (granted != true) {
      requestLocationPermission();
    }
    debugPrint('requestLocationPermission $granted');
    return granted;
  }

/*Show dialog if GPS not enabled and open settings location*/
  Future _checkGps(String message) async {
    print('running gps function2');
    if (message == 'false') {
      if (Theme.of(context).platform == TargetPlatform.android) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("LoginCan't get gurrent location"),
                content: const Text(
                    'Please make sure you enable GPS and set location mode to High accruacy and try again'),
                actions: <Widget>[
                  FlatButton(
                      child: Text('Ok'),
                      onPressed: () {
                        final AndroidIntent intent = AndroidIntent(
                            action:
                                'android.settings.LOCATION_SOURCE_SETTINGS');
                        intent.launch();
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                        Navigator.pop(context);
                      })
                ],
              );
            });
      }
    }
  }

  /*Check if gps service is enabled or not*/
  /*
  Future _gpsService() async {
    // Geolocator().checkGeolocationPermissionStatus().then((status) {
    // print('status: $status');
    //});
    if (!(await Geolocator().isLocationServiceEnabled())) {
      _checkGps();
      return null;
    } else {
      print('Gps turned on ');
      print(Geolocator().isLocationServiceEnabled());
      return true;
    }
  }
*/
// popup for geo access

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

  Future<Null> _getGPS() async {
    print('I am here');
    String _message;
    try {
      final String result = await platformMethodChannel.invokeMethod('getGPS');
      _message = result;
      if (_message == 'false') {
        _checkGps(_message);
        print('this is message ' + _message);
      }
    } on PlatformException catch (e) {
      _message = "Can't do native stuff ${e.message}.";
    }
    setState(() {
      nativeMessage = _message;
    });
  }

  onSignUp(String status) async {
    fcm.getToken().then((value) {
      print(value);
      var result = mix.mixpanelAnalytics.track(
          event: 'onSignup',
          properties: {'status': status, 'distinct_id': value});
      result.then((value) {
        print('this is on click');
        print(value);
      });
    });
  }

  onCreateAccount(Merchant m) async {
    fcm.getToken().then((value) {
      var result = mix.mixpanelAnalytics
          .engage(operation: MixpanelUpdateOperations.$set, value: {
        '\$first_name': m.fullname,
        '\$created': DateTime.now().toUtc().toIso8601String(),
        '\$email': m.mailid,
        '\$phone': m.mobilenumber,
        'city': m.city,
        'address': m.address,
        'shopname': m.address,
        'category': m.category,
        'zipcode': m.zipcode,
        'distinct_id': value
      });
    });
  }
}
