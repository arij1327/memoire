import 'package:app/chauffeur/chauf.dart';

import 'package:app/user/utilisateur.dart';
import 'package:flutter/material.dart';

class homepage extends StatefulWidget {
  const homepage({super.key});

  @override
  State<homepage> createState() => _homepageState();
}

class _homepageState extends State<homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Center(
        child: Column(
          children: <Widget>[
            ElevatedButton(onPressed:(){Navigator.push(context,
             MaterialPageRoute(builder: (context)=>InterfacePage()),);} , child: Text("utilisateur")),
                ElevatedButton(onPressed:(){Navigator.push(context,
             MaterialPageRoute(builder: (context)=>Chauff()),);} , child: Text("chauffeur"))
          ],
          
          
        ),
      ),
    );
  }
}