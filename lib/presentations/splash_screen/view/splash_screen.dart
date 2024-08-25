import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wincept_task/presentations/login_screen/view/login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('CHATIFY',style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold),
            ),
      ),
    );
  }
}