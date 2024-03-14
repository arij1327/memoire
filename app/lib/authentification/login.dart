import 'dart:async';

import 'package:app/authentification/sign_in.dart';
import 'package:app/chauffeur/chauf.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:search_map_location/utils/google_search/latlng.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late LatLng? _currentPositionchauff;
  bool _isSigningIn = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('position');

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _determinePosition();

    
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    if (permission == LocationPermission.whileInUse) {
    
                Position position = await Geolocator.getCurrentPosition();
      _currentPositionchauff = LatLng(latitude: position.latitude, longitude: position.longitude);
      print("Current Position: $_currentPositionchauff");
   
        
    
         Timer.periodic(Duration(minutes: 1), (timer) {
  // Appel de la fonction pour mettre à jour la position
  _currentPositionchauff;
      print("++++++++++++++++++++++++++++++++++++++++++++++++++");
      print((_currentPositionchauff));

});
        
      
    
    }
    
    
  }
  Future<String?> getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("************************FCM Token: $token");
return token;
  // Enregistrer ce jeton dans votre base de données côté serveur
}

 Future<void> addUser() async {



  try {
    if (_currentPositionchauff != null) {
      
      await users.add({
        'latitude': _currentPositionchauff!.latitude,
        'longitude': _currentPositionchauff!.longitude,
        'gmail':_emailController.text,
      
       "isAvailable": false,
       
       

      });
      print("User Added");
    } else {
      print("Failed to add user: Current position is null");
    }
  } catch (error) {
    print("Failed to add user: $error");
  }
}

  Future<void> _loginWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      // Navigate to the desired page after successful login
    } catch (e) {
      print("Failed to login: $e");
      // Handle login failure
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isSigningIn = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        // Navigate to the desired page after successful login
      }
    } catch (e) {
      print("Failed to sign in with Google: $e");
      // Handle sign-in failure
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.all(8)),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _loginWithEmailAndPassword();
              addUser();
              getToken();
            },
            child: Text("Login"),
          ),
          ElevatedButton(
            onPressed: _signInWithGoogle,
            child: Text(_isSigningIn ? "Signing in..." : "Login with Google"),
          ),
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
    );
  }
}
