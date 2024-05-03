import 'package:app/authentification/login.dart';
import 'package:app/authentification/sign_up.dart';
import 'package:app/chauffeur/chauffeur.dart';
import 'package:app/chauffeur/profilechauffeur.dart';

import 'package:app/user/utilisateur.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed:(){Navigator.push(context,
             MaterialPageRoute(builder: (context)=>InterfacePage()),);} , child: Text("utilisateur")),
               ElevatedButton(
  onPressed: () {
    try {
      print("Current user: ${FirebaseAuth.instance.currentUser}");
      if (FirebaseAuth.instance.currentUser == null) {
        print("User not logged in, navigating to signup page.");
      Navigator.push(context,
             MaterialPageRoute(builder: (context)=>signuppage()),);
      } else {
        print("User logged in, navigating to Chauff page.");
        Navigator.push(context,
             MaterialPageRoute(builder: (context)=>UserProfilePage()),);
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  
  },

  child: Text("chauffeur")
)
          ],
          
          
        ),
      ),
    );
  }
}