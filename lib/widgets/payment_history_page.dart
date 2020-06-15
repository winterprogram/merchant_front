import 'package:flutter/material.dart';
import 'package:merchantfrontapp/models/transaction.dart';
import 'package:merchantfrontapp/widgets/Mixpanel.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'fcm_notification.dart';

class PaymentHistory extends StatefulWidget {
  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  FcmNotification fcm;
  String status = 'Loading';
  List data;
  Map<bool, dynamic> transactionType = {
    true: TransactionType.success,
    false: TransactionType.failure
  };
  Timer t;
  MixPanel mix = MixPanel();

  @override
  void initState() {
    super.initState();
    mix.createMixPanel();
    fcm = new FcmNotification(context: context);
    fcm.initialize();
    getMerchantTransactionHistory();
    t = Timer.periodic(
        Duration(seconds: 10), (timer) => getMerchantTransactionHistory());
  }

  @override
  void dispose() {
    t.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
            color: Color(0xFFf1d300),
            child: Container(
              padding: EdgeInsets.only(bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Center(
                    child: Text(
                      "RECENT TRANSACTIONS",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17.0,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        itemCount: calculateCount(),
                        itemBuilder: (BuildContext ctx, int index) {
                          if (status == 'Loading') {
                            return Padding(
                              padding: EdgeInsets.all(10),
                              child: Shimmer.fromColors(
                                baseColor: Colors.white,
                                highlightColor: Colors.grey[400],
                                child: Container(
                                  height: 50,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          } else if (status == 'Loaded') {
                            print(data[index]);
                            return Transaction(
                              receptient: data[index]['username'],
                              transactionDate: data[index]['createdon'],
                              transactionAmout:
                                  data[index]['amount_paid'].toString(),
                              transactionType:
                                  transactionType[data[index]['isPaid']],
                            );
                          } else if (status == 'No Transaction History') {
                            return Container(
                                child: Text('No Transaction history found'));
                          } else {
                            return Container(child: Text('Some Error Occured'));
                          }
                        }),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.vertical(
                  top: Radius.elliptical(30, 30),
                ),
              ),
            )));
  }

  int calculateCount() {
    if (status == 'Loading') {
      return 3;
    } else if (status == 'Loaded') {
      return data.length;
    } else {
      return 1;
    }
  }

  getMerchantTransactionHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var merchantid = prefs.getString('merchantid');
    try {
      Response response = await get(
        kUrl + '/merchantTransaction',
        headers: <String, String>{
          'Content-Type': 'application/json',
          'merchantid': merchantid,
        },
      ).timeout(const Duration(seconds: 10));
      String body = response.body;
      // print('this is body');
      print(body);
      String message = json.decode(body)['message'];
      int code = json.decode(body)['status'];
      onGetTransactionHistory(message);
      if (code == 200) {
        setState(() {
          status = 'Loaded';
          data = json.decode(body)['data'];
          print(data[0]);
        });
      } else if (message == 'error no payments found for merchant') {
        setState(() {
          status = 'No Transaction History';
        });
      } else {
        setState(() {
          status = 'Error';
        });
        Toast.show(
          "Some error occurred",
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
  }

  onGetTransactionHistory(String status) async {
    fcm.getToken().then((value) {
      print(value);
      var result = mix.mixpanelAnalytics.track(
          event: 'onGetTransactionHistory',
          properties: {'status': status, 'distinct_id': value});
      result.then((value) {
        print('this is on click');
        print(value);
      });
    });
  }
}
