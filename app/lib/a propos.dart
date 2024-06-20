import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class A_propos extends StatefulWidget {
  const A_propos({super.key});

  @override
  State<A_propos> createState() => _A_proposState();
}

class _A_proposState extends State<A_propos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(onPressed: (){
        Navigator.pop(context);
      }, icon: Icon(Icons.arrow_back)),),
      body:Container(
         decoration: BoxDecoration(
           image: DecorationImage(image: AssetImage("asset/lu.png"),
           fit: BoxFit.fitWidth)
         ),)
    
    
    );
  }
}