import 'package:flutter/material.dart';
import 'package:app/homepage.dart';

class ScreenPage extends StatelessWidget {
  const ScreenPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InkWell(
        onTap: () {
          Navigator.pushReplacementNamed(context, '/home');
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("asset/splachsceen.jpeg"),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
