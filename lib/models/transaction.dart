import 'package:flutter/material.dart';

enum TransactionType { success, failure }

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
      case TransactionType.success:
        transactionName = "Success";
        color = Colors.green;
        break;
      case TransactionType.failure:
        transactionName = "Failure";
        color = Colors.red;
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
                      "Rs. $transactionAmout",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      receptient,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Center(
                  child: Text(
                    "$transactionName",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('$transactionDate'),
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
