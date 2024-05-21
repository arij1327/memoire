import 'package:app/authentification/login.dart';
import 'package:app/authentification/sign_up.dart';
import 'package:app/chauffeur/detailcource.dart';
import 'package:app/firebase_options.dart';
import 'package:app/homepage.dart';
import 'package:app/paymentpaypal.dart';
import 'package:app/screenpage.dart';
import 'package:app/stripe_payment/stripe_keys.dart';
import 'package:app/user/loginuser.dart';
import 'package:app/user/registeruser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:app/chauffeur/profilechauffeur.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

 Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp (
        options: DefaultFirebaseOptions.currentPlatform,
);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel_id', // id
    'Default Channel', // name
    description: 'This is the default channel for notifications.', // description
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
await FirebaseAppCheck.instance.activate(
  androidProvider: AndroidProvider.playIntegrity,
);
  Stripe.publishableKey=ApiKeys.publishablekey;

  
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
      '/login': (context) =>LoginuserPage(),
            '/detail': (context) =>detailcource(),


      

    
      },
      home: ScreenPage(),
    );
  }
 

}

