import 'dart:async';

import 'package:app/authentification/sign_up.dart';
import 'package:app/chauffeur/chauffeur.dart';
import 'package:app/chauffeur/profilechauffeur.dart';
import 'package:app/user/registeruser.dart';
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

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InterfacePage()),
        );
      }
    } catch (e) {
      print('Google sign-in failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to sign in with Google."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    if (formKey.currentState!.validate()) {
      try {
        UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        DatabaseEvent event = await FirebaseDatabase.instance
            .ref('position/${credential.user!.uid}/statut')
            .once();

        String? userStatut = event.snapshot.value as String?;

        if (userStatut == "chauffeur") {
          await FirebaseDatabase.instance.ref('position').child(credential.user!.uid).push().set({});
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DriverProfilePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => InterfacePage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'No user found for that email.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Wrong password provided for that user.';
        } else {
          errorMessage = 'An error occurred. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print("Form not validated");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("asset/chauff.jpeg"), fit: BoxFit.fill),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      
                    ),
                  ),
                  SizedBox(height: 200),
                  Form(
                    key: formKey,
                    child: Container(
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) return "Error";
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
                          SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              if (_emailController.text.isNotEmpty) {
                                await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 10, bottom: 20),
                              alignment: Alignment.topRight,
                              child: const Text(
                                "Mot de passe oublié?",
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          ElevatedButton(
                            
                            onPressed: () async {
                              await signInWithEmailAndPassword();
                            },
                            child: Text("Connexion",style: TextStyle(color: Colors.black),),
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
                                  ),
                                ),
                              ),
                              Text("Ou connectez-vous en utilisant"),
                              Container(
                                width: 100,
                                child: Divider(
                                  thickness: 1,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isSigningIn = true;
                              });
                              await signInWithGoogle();
                              setState(() {
                                _isSigningIn = false;
                              });
                            },
                            child: Text(_isSigningIn ? "Signing in..." : "Login avec Google",style: TextStyle(color: Colors.black),),
                          ),
                          const SizedBox(height: 130),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Avez vous un compte?"),
                              SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignupUserPage()),
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  "Registrer",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
