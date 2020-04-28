import 'package:flutter/material.dart';

enum TransactionType { sent, received, pending }

class Transaction extends StatelessWidget {
  final TransactionType transactionType;
  final String transactionAmout, transactionDate, receptient;
  const Transaction(
      {Key key,
      this.transactionType,
      this.transactionAmout,
      this.transactionDate,
      this.receptient})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    String transactionName;
    Color color;
    switch (transactionType) {
      case TransactionType.sent:
        transactionName = "Sent";
        color = Theme.of(context).primaryColor;
        break;
      case TransactionType.received:
        transactionName = "Received";
        color = Colors.green;
        break;
      case TransactionType.pending:
        transactionName = "Pending";
        color = Colors.orange;
        break;
    }
    return Container(
      margin: EdgeInsets.all(9.0),
      padding: EdgeInsets.all(9.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 5.0,
            color: Colors.grey[350],
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          SizedBox(width: 5.0),
          Flexible(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      receptient,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Rs. $transactionAmout",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "$transactionName",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
