import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Coupon {
  final String discount;
  final String flatdiscount;
  final String startdate;
  final String enddate;
  final Function editFunction;
  final Function deleteFunction;
  Coupon({
    @required this.discount,
    @required this.flatdiscount,
    @required this.startdate,
    @required this.enddate,
    this.editFunction,
    this.deleteFunction,
  });
  Widget createCoupon() {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Your Active Coupon',
                style: TextStyle(fontSize: 25),
              ),
              Text(this.discount + "% discount")
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                this.startdate + '-' + this.enddate,
                style: TextStyle(fontSize: 20),
              ),
              Row(
                children: <Widget>[
                  Container(
                    child: RaisedButton(
                      child: Text('Edit'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      color: Colors.yellow,
                      onPressed: editFunction,
                    ),
                  ),
                  Container(
                    child: RaisedButton(
                      child: Text('Delete'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      color: Colors.yellow,
                      onPressed: deleteFunction,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
