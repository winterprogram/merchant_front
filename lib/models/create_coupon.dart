import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Coupon {
  final String discount;
  final String flatdiscount;
  final String startdate;
  final String enddate;
  final String shopname;
  final Function editFunction;
  final Function deleteFunction;
  Coupon({
    @required this.discount,
    @required this.flatdiscount,
    @required this.startdate,
    @required this.enddate,
    this.shopname,
    this.editFunction,
    this.deleteFunction,
  });
  Widget createCoupon() {
    return Padding(
      padding: EdgeInsets.only(top: 24),
      child: Container(
          padding: EdgeInsets.only(top: 24, left: 31),
          height: 220,
          decoration: BoxDecoration(
              color: Color(0xff3A91EC),
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'DISCOUNT',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  '$discount%',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 21),
                child: Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'EXPIRY',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 9.0),
                          child: Text(
                            enddate,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 47),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'DISCOUNT UPTO',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              'Rs.$flatdiscount',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 15),
                child: Text(
                  'MERCHANT',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '$shopname',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red[500],
                    ),
                    onPressed: deleteFunction,
                  )
                ],
              )
            ],
          )),
    );
  }
}
