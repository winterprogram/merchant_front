import 'package:flutter/material.dart';
import 'package:merchantfrontapp/models/transaction.dart';

class PaymentHistory extends StatefulWidget {
  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
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
                    child: ListView(
                      children: <Widget>[
                        Transaction(
                          receptient: "User",
                          transactionAmout: "5000.00",
                          transactionDate: "26 Jun 2019",
                          transactionType: TransactionType.sent,
                        ),
                        Transaction(
                          receptient: "User",
                          transactionAmout: "15000.00",
                          transactionDate: "26 Jun 2019",
                          transactionType: TransactionType.received,
                        ),
                        Transaction(
                          receptient: "User",
                          transactionAmout: "25000.00",
                          transactionDate: "24 Jun 2019",
                          transactionType: TransactionType.pending,
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
            )));
  }
}
