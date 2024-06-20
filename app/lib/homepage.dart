 import 'package:app/authentification/login.dart';
 import 'package:app/authentification/sign_up.dart';
 import 'package:app/chauffeur/chauffeur.dart';
 import 'package:app/chauffeur/profilechauffeur.dart';
 import 'package:app/user/loginuser.dart';
 import 'package:app/user/registeruser.dart';

 import 'package:app/user/utilisateur.dart';
 import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
        body: Container(
         decoration: BoxDecoration(
           image: DecorationImage(image: AssetImage("asset/home.jpeg"),
           fit: BoxFit.fill)
         ),
          child: Center(
        
          
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             crossAxisAlignment: CrossAxisAlignment.center,
            
            
             children: <Widget>[
               SizedBox(height: 250),

                  ElevatedButton(
            onPressed: ()async {
              try {
                print("Current user: ${FirebaseAuth.instance.currentUser}");
                if (FirebaseAuth.instance.currentUser == null) {
           print("User not logged in, navigating to signup page.");
                Navigator.push(context,
                MaterialPageRoute(builder: (context)=>SignupUserPage()),);
                } else {
                 DatabaseEvent event = (await FirebaseDatabase.instance
      .ref('position/${FirebaseAuth.instance.currentUser!.uid}/statut')
      .once()) ;

String? userStatut;

if (event.snapshot != null) {
  userStatut = event.snapshot!.value as String?;
} else {
  // Handle if snapshot is null or no data found
}
if(userStatut=="chauffeur")
                         {
                                               Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>DriverProfilePage())) ;

                         }  
                         else{
             Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>InterfacePage())) ;

                         }  
                }
              } catch (e) {
                print("Error occurred: $e");
              }
           
            },
            style: ElevatedButton.styleFrom(
             minimumSize: Size(300, 50)
           ),
         
            child: Text("Bienvenue", style: TextStyle(color: Colors.black),)
          )
             ],
            
            
           ),
                ),
        ),
     );
   }
 }