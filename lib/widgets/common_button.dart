import 'package:flutter/material.dart';
import 'package:merchantfrontapp/widgets/constants.dart';

// Button theme build
class ClickButton extends StatelessWidget {
  final Function buttonFunction;
  final String buttonTitle;
  ClickButton({@required this.buttonTitle, @required this.buttonFunction});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Text(buttonTitle),
        onPressed: buttonFunction,
        color: kOverallColor,
      ),
    );
  }
}
