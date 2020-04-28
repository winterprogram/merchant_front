import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/rendering.dart';
import 'package:merchantfrontapp/widgets/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'status_page.dart';
import 'landing_page.dart';
import 'package:merchantfrontapp/widgets/payment_history_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int pageNumber = 1;
  List<Color> elementColor = [
    Color(0xFFf1d300),
    Colors.white,
    Color(0xFFf1d300)
  ];
  Widget _pageChooser(int page) {
    switch (page) {
      case 0:
        return PaymentHistory();
        break;
      case 1:
        return StatusPage();
        break;
      case 2:
        return ProfilePage();
        break;
      default:
        return Container(
            child: Center(
          child: Text(
            'No page found',
            style: TextStyle(fontSize: 35),
          ),
        ));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.add_photo_alternate),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.exit_to_app, size: 35),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.remove('merchantid');
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext ctx) => LandingPage()),
                    ModalRoute.withName('/'));
              },
            ),
          ],
          backgroundColor: Color(0xFFf1d300),
          elevation: 0,
        ),
        bottomNavigationBar: CurvedNavigationBar(
          index: 1,
          color: Colors.white,
          buttonBackgroundColor: Color(0xFFf1d300),
          animationDuration: Duration(milliseconds: 200),
          height: 60,
          backgroundColor: Colors.grey[300],
          items: <Widget>[
            Icon(FontAwesomeIcons.rupeeSign, size: 30, color: elementColor[0]),
            Icon(Icons.home, size: 35, color: elementColor[1]),
            Icon(Icons.person, size: 35, color: elementColor[2]),
          ],
          onTap: (index) {
            setState(() {
              elementColor[0] = Color(0xFFf1d300);
              elementColor[1] = Color(0xFFf1d300);
              elementColor[2] = Color(0xFFf1d300);
              elementColor[index] = Colors.white;
              pageNumber = index;
            });
          },
        ),
        body: _pageChooser(pageNumber));
  }
}
