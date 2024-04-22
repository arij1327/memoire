import 'package:flutter/material.dart';

class background_image extends StatelessWidget {
 

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("asset/chauff.jpeg"),
          fit: BoxFit.cover
        )
      ),

    );
  }
}