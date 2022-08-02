import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goport/Const/AppColors.dart';

class SplashScreen extends StatefulWidget {
  static String id = 'SplashScreen';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 1)).then((value) {
      Navigator.of(context).pushNamed('LoginScreen');
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: null,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            child: Container(
              color: colorLogo,
              width: MediaQuery.of(context).size.width,
              height: 10,
            ),
          ),
          Positioned(
              bottom: 0,
              child: Column(
                children: [
                  Container(
                    color: colorLogo,
                    width: MediaQuery.of(context).size.width,
                    height: 10,
                  ),
                  Container(
                    color: colorAccent2,
                    width: MediaQuery.of(context).size.width,
                    height: 20,
                  )
                ],
              )),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/new_logo1.png",
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
