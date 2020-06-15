import 'package:flutter/material.dart';
import 'package:merchantfrontapp/widgets/razorpay.dart';
import 'Mixpanel.dart';
import 'fcm_notification.dart';

class Summary extends StatefulWidget {
  final double amount;
  @override
  Summary({
    this.amount,
  });
  @override
  _SummaryState createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  FcmNotification fcm;
  String token;
  MixPanel mix = MixPanel();
  double amount;
  int conveniencefee;
  double total;
  RazorPay r;
  @override
  void initState() {
    super.initState();
    mix.createMixPanel();
    amount = this.widget.amount;
    conveniencefee = (calculateConvenience(0.02 * total)).round();
    total += conveniencefee;
    fcm = new FcmNotification(context: context);
    fcm.initialize();
    fcm.getToken().then((value) {
      print(value);
      token = value;
      r = RazorPay(context: context, amount: total, token: token);
    });
  }

  @override
  void dispose() {
    super.dispose();
    r.clear();
    fcm.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 24, top: 65.0),
                        child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 24, top: 26),
                        child: Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding:
                                EdgeInsets.only(left: 24, top: 23, right: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Sub Total',
                                  style: TextStyle(
                                      color: Color(0xff293340), fontSize: 15),
                                ),
                                Text(
                                  'Rs. $amount',
                                  style: TextStyle(
                                      color: Color(0xff293340),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: 24, top: 19, right: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  'Convenience Fee',
                                  style: TextStyle(
                                      color: Color(0xff293340), fontSize: 15),
                                ),
                                Text(
                                  'Rs. $conveniencefee',
                                  style: TextStyle(
                                      color: Color(0xff293340),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 88,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Divider(),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Rs. $total',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                          color: Color(0xff293340)),
                                    ),
                                    Container(
                                      height: 48,
                                      width: 169,
                                      child: RaisedButton(
                                        onPressed: () async {
                                          onClick('MakePayment');
                                          await r.checkout();
                                          /*Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Navigation()),
                                            (Route<dynamic> route) => false,
                                          );*/
                                        },
                                        color: Color(0xff3a91ec),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              'Make Payment',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Icon(
                                                Icons.arrow_forward,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(24)),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  onClick(String button) async {
    var result = mix.mixpanelAnalytics.track(
        event: 'onClickSummaryPage',
        properties: {'button': button, 'distinct_id': fcm.getToken()});
    result.then((value) {
      print('this is click login');
      print(value);
    });
  }

  calculateConvenience(double convenience) {
    if (convenience < 0.1) {
      return convenience;
    } else {
      return convenience + calculateConvenience(0.02 * convenience);
    }
  }
}
