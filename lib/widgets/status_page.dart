import 'package:flutter/material.dart';
import 'package:merchantfrontapp/widgets/manage_coupon_page.dart';

class StatusPage extends StatefulWidget {
  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Color(0xFFf1d300),
        child: Container(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 13, right: 5, left: 10),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Your earnings',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20)),
                              Text('50',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('-20%',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20)),
                                  Icon(Icons.trending_down, color: Colors.red)
                                ],
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.elliptical(30, 30),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 13, left: 5, right: 10),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Amount you owe us',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20)),
                              Text('5500',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('+20%',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20)),
                                  Icon(Icons.trending_up, color: Colors.green)
                                ],
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.elliptical(30, 30),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 5, left: 10, right: 5),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('No. of coupons issued',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20)),
                              Text('50',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('+20%',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 20,
                                      )),
                                  Icon(Icons.trending_up, color: Colors.green)
                                ],
                              )
                            ],
                          ),
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 5, right: 10, left: 5),
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('No. of coupons redeemed',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20)),
                              Text('78',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 45,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text('-10%',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 20)),
                                  Icon(Icons.trending_down, color: Colors.red)
                                ],
                              )
                            ],
                          ),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 15, left: 10, right: 5, bottom: 5),
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: RaisedButton(
                            color: Color(0xFFf1d300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(30, 30),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ManageCoupon()));
                            },
                            child: Center(
                                child: Text('Manage Coupons',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20))),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 15, right: 10, left: 5, bottom: 5),
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: RaisedButton(
                            color: Color(0xFFf1d300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(30, 30),
                              ),
                            ),
                            onPressed: () {},
                            child: Center(
                                child: Text('Redeem Coupon',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20))),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 5, left: 10, right: 5, bottom: 15),
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: RaisedButton(
                            color: Color(0xFFf1d300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(30, 30),
                              ),
                            ),
                            onPressed: () {},
                            child: Center(
                                child: Text('Make Payment',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20))),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: 5, right: 10, left: 5, bottom: 15),
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          child: RaisedButton(
                            color: Color(0xFFf1d300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.elliptical(30, 30),
                              ),
                            ),
                            onPressed: () {},
                            child: Center(
                                child: Text('Promote your brand',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 20))),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.vertical(
              top: Radius.elliptical(30, 30),
            ),
          ),
        ),
      ),
    );
  }
}
