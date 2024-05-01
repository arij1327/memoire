import 'package:app/authentification/login.dart';
import 'package:app/authentification/sign_in.dart';
import 'package:app/firebase_options.dart';
import 'package:app/homepage.dart';
import 'package:app/screenpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:app/chauffeur/profilechauffeur.dart';
import 'package:firebase_app_check/firebase_app_check.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp (
        options: DefaultFirebaseOptions.currentPlatform,
);
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.playIntegrity,
);

  
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  

  void initState(){
    FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user == null) {
      print('=========================================User is currently signed out!');
    } else {
      print('User is signed in!');
    }
  });
  
  }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
       initialRoute: '/',
      routes: {
        '/home': (context) =>homepage(),
      '/login': (context) =>LoginPage(),

      

    
      },
      home: ScreenPage(),
    );
  }
}

