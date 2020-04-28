import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Merchant {
  final String fullname;
  final String mailid;
  final String mobilenumber;
  final String city;
  final String password;
  final String address;
  final String zipcode;
  final String category;
  final String shopname;
  final String latitude;
  final String longitude;
  Merchant({
    @required this.fullname,
    @required this.mailid,
    @required this.mobilenumber,
    @required this.city,
    @required this.password,
    @required this.address,
    @required this.zipcode,
    @required this.category,
    @required this.shopname,
    @required this.longitude,
    @required this.latitude,
  });
}
