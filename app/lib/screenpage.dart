import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app/homepage.dart';

class ScreenPage extends StatelessWidget {
  const ScreenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 3), () {   Navigator.pushReplacementNamed(context, '/home');});
    return Scaffold(
      body: 
         Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/screen.jpeg"),
              fit: BoxFit.fill,
            ),
          ),
        ),
      );
  
  }
}
