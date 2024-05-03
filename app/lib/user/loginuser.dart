import 'dart:async';

import 'package:app/authentification/sign_up.dart';
import 'package:app/chauffeur/chauffeur.dart';
import 'package:app/chauffeur/profilechauffeur.dart';
import 'package:app/user/utilisateur.dart';
import 'package:app/widgets/backgroundimagelogin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:search_map_location/utils/google_search/latlng.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class LoginuserPage extends StatefulWidget {
  const LoginuserPage({Key? key}) : super(key: key);

  @override
  State<LoginuserPage> createState() => _LoginuserPageState();
}

class _LoginuserPageState extends State<LoginuserPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late LatLng? _currentPositionchauff;
  bool _isSigningIn = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  //CollectionReference users = FirebaseFirestore.instance.collection('position');

GlobalKey<FormState>  formKey= GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
   

    
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 
  Future<String?> getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("************************FCM Token: $token");
return token;
  
}

/*void isRefrechToken()async{
FirebaseMessaging.instance.onTokenRefresh.listen((event) {
  event.toString();
});

}*/
 
 Future signInWithGoogle() async {
  // Trigger the authentication flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
   await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>UserProfilePage()));
}

  @override
  Widget build(BuildContext context) {
    return 
  
      Scaffold(
        backgroundColor: Colors.white,
         body:Container(
           child: ListView(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Center(
                        child: Container(
                          child: Image.asset(
                            "asset/taxi.png",
                            height: 120,
                            
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12,),
                    
                    Form(
           
           key: formKey,
                      child: Container(
                          
                                
                                    child: Column(
                                               
                                                       children: <Widget>[
                                            
                                    TextFormField(
                                      validator: (value) {
                                        if(value==null||value.isEmpty)return "Error";
                                        return null;
                                      },
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Adresse Email',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.all(8)),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Mot de passe',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12,),
                                    InkWell(
                                      onTap: () async{
                                        await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
                                      },
                                      child: Container(
                                      margin: const EdgeInsets.only (top: 10, bottom: 20),
                                      alignment: Alignment.topRight,
                                      child: const Text(
                                      "Forgot Password ?",
                                      style: TextStyle(
                                      fontSize: 14,
                                      ), // TextStyle
                                      ), // Text
                                      ),
                                    ), // Container
                                    ElevatedButton(
                                    
                                      
                                      onPressed: () async{ 

                                        print("hhhhhhhhhhhhhhhhh") ; 
                                          if(formKey.currentState!.validate()){
                                              try {
                                         UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                       email: _emailController.text,
                                                       password: _passwordController.text,
                                         );
                                         
                                       
                                          
                                         print("okok") ; 
                                        
                                               Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>InterfacePage())) ;
                                       } on FirebaseAuthException catch (e) {
                                         if (e.code == 'user-not-found') {
                                       print('No user found for that email.');
                                         ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("No user found for that email."),
                                      duration: Duration(seconds: 2),
                                    ),
                                                       );
                                         } else if (e.code == 'wrong-password') {
                                       print('Wrong password provided for that user.');
                                        ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Wrong password provided for that user."),
                                      duration: Duration(seconds: 2),
                                    ),
                                                       );
                                                       
                                         }
                                         
                                       }
                                       
           
                                          }   
                                          else{
                                            print("Non Valider");
                                          }        
                                        
                                      //  addUser();
                                      //  getToken();
                                     
                                      },
                                      child: Text("Connexion",),
                                    ),
                                                           Row(
                                    children: [
                                                       
                                                           Padding(
                                     padding: const EdgeInsets.only(left: 6),
                                     child: Container(
                                        width: 70,
                                     
                                        child: Divider(
                                          thickness: 1,
                                          color: Colors.black,
                                          // width: 15,
                                        ),
                                      ),
                                                           ),
                                                       Text("Ou connectez-vous en utilisant", ),
                                                           Container(
                                      width: 100,
                                                           
                                      child: Divider(
                                        thickness: 1,
                                        color: Colors.black,
                                        // width: 15,
                                      ),
                                    ),
                                    ],
                                                       ),
                                    ElevatedButton(
                                      onPressed: ()async{
                                         final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  // Obtain the auth details from the request
  final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  // Create a new credential
  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth?.accessToken,
    idToken: googleAuth?.idToken,
  );

  // Once signed in, return the UserCredential
   await FirebaseAuth.instance.signInWithCredential(credential);
    Navigator.pushReplacement(context,MaterialPageRoute(builder:(context)=>UserProfilePage()));
                                      },
                                      child: Text(_isSigningIn ? "Signing in..." : "Login with Google"),
                                    ),
                                    
                                                           const SizedBox(height:230),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Don't have an account"),
                                        SizedBox(width: 5),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(builder: (context) => signuppage()),
                                              (route) => false,
                                            );
                                          },
                                          child: Text(
                                            "Signup",
                                            style: TextStyle(
                                              color: Color(0xFF53bcbd),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                                       ],
                                         ),
                                  ),
                    ),
                              
              ]),
             
                  
                
               
                   ],
                     ),
         ),
         );

              
          
      
         
        
              
                
  }
}
