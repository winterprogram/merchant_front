import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:merchantfrontapp/widgets/common_button.dart';
import 'package:merchantfrontapp/widgets/signup_page.dart';
import 'package:merchantfrontapp/widgets/login_page.dart';
import 'package:merchantfrontapp/widgets/upload_image.dart';

// landing page
class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  signup(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    bool result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImagePickerWidget()),
    );
    if (result == true) {
      showModalBottomSheet(context: context, builder: (context) => Login());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/merchant.png'), //image
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ClickButton(
                    buttonTitle: 'Login',
                    buttonFunction: () {
                      showModalBottomSheet(
                          context: context, builder: (context) => Login());
                    },
                  ),
                ), //Login Button
                Expanded(
                  child: ClickButton(
                    buttonTitle: 'Signup',
                    buttonFunction: () {
                      signup(context);
                    },
                  ),
                ), //SignUp Button
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
        ],
      ),
    );
  }
}
