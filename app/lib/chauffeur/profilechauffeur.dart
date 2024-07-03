import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app/access_token.dart';
import 'package:app/authentification/login.dart';
import 'package:app/chauffeur/detailcource.dart';
import 'package:app/user/registeruser.dart';
import 'package:background_location/background_location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:search_map_location/utils/google_search/latlng.dart';

class DriverProfilePage extends StatefulWidget {
  @override
  _DriverProfilePageState createState() => _DriverProfilePageState();
}

class _DriverProfilePageState extends State<DriverProfilePage> {
  late LatLng? _currentPositionchauff;
  late TextEditingController _emailController;
  double? currentlat;
  double? currentlong;
  Timer? timer;
  String? _prenom;

  bool _isAvailable = false;
  bool isDialogShown = false;
  bool _isOccupe = false;
  List data = [];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
   
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessageOpenedApp.listen((message) { 
      if(message.notification!.body == "utilisateur a annulé la course"){
        Navigator.pop(context);
      }
      else if(message.notification!.body =="utilisateur a confirmé la course"){
        Navigator.pushNamed(context, '/detailcource', arguments: {
          'adress':message.data['adress'],
          'prix':message.data['prix'],
          'token':message.data['token']
        });
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _handleMessage(message);
    });

    getDataUser();
    _updateoccupe(false);
    fetchoccupe();
    fetchAvailability();
    _determinePosition();
  }

  void _handleMessage(RemoteMessage message) async {
    if (message.notification != null) {
      if (isDialogShown) {
        Navigator.of(navigatorKey.currentContext!).pop();
        isDialogShown = false;
      }
      try {
        if (message.notification != null) {
          showDialog(
            context: context,
            builder: (context) {
              isDialogShown = true;
              return AlertDialog(
                title: Text("Vous avez une course"),
                content: Column(
                  children: [
                    Text(message.data['adress']),
                    Text('Destination ${message.data['destination']}'),
                    Text('Prix de course ${message.data['prix']}'),
                    Text('Mode de payment ${message.data['methode_payment']}')
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      String token = message.data['token'];
                      PushNotificationService.sendFCMMessage("LuxBlack", "Le chauffeur a accepté votre course", token);
                      Navigator.pop(context);
                    },
                    child: Text("Accepter"),
                  ),
                  TextButton(
                    onPressed: () {
                      String token = message.data['token'];
                      PushNotificationService.sendFCMMessage("LuxBlack", "Le chauffeur a refusé votre course", token);
                      Navigator.pop(context);
                    },
                    child: Text("Refuser"),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        print('Error handling FCM message: $e');
      }
    }
  }

  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
  body: Stack(
    children: [
      Positioned.fill(
        child: Image.asset(
          'asset/chaufff.jpeg', // replace with your image path
          fit: BoxFit.fill,
        ),
      ),
      Column(
        children: [
          AppBar(
          actions: <Widget>[
            Switch(
              value: _isAvailable,
              onChanged: (newValue) async {
                setState(() {
                  _isAvailable = newValue;
                });
                await _updateAvailability(newValue);
             await UpdateLocation();
          

              },
              activeColor: Colors.black,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[300],
            ),
          ],
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, i) {
                return Column(
                  children: [
                    SizedBox(height: 80),
                    CircleAvatar(
                      backgroundColor: Colors.black,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          data[i]['Nom'],
                          style: TextStyle(fontSize: 25, color: Colors.black),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.envelope,
                            size: 30,
                            color: Colors.black,
                          ),
                          SizedBox(width: 20),
                          Text(
                            data[i]['email'],
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.phone,
                            size: 25,
                            color: Colors.black,
                          ),
                          SizedBox(width: 20),
                          Text(
                            data[i]['phone'],
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Image.asset("asset/matri.jpeg", width: 35, height: 30),
                          SizedBox(width: 25),
                          Text(
                            data[i]['Matricule'],
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Image.asset("asset/mod.jpeg", width: 40),
                          SizedBox(width: 20),
                          Text(
                            data[i]['Modèle'],
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          Image.asset("asset/taxi.jpeg", width: 50),
                          SizedBox(width: 25),
                          Text(
                            data[i]['Numéro du taxi'],
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ],
                      ),
                    )
                  ],
                );
              },
              itemCount: data.length,
            ),
          ),
        ],
      ),
    ],
  ),
  bottomNavigationBar: Container(
    decoration: BoxDecoration(
      image: DecorationImage(
        image: AssetImage('asset/chaufff.jpeg'),
        fit: BoxFit.cover,
      ),
    ),
    child: GNav(
      tabs: [
        GButton(
          icon: Icons.settings,
          text: "Paramètre",
          onPressed: () {},
        ),
        GButton(
          icon: Icons.exit_to_app,
          text: "Déconnecter",
          onPressed: () {
            showDialog(context: context, builder: (context) {
              return AlertDialog(
                title: Text("Déconnecter"),
                content: Text("Voulez-vous vraiment vous déconnecter?"),
                actions: [
                  TextButton(onPressed: () async {
                    await _updateAvailability(false);
                    await _refreshFCMToken();
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignupUserPage()));
                  }, child: Text("Ok")),
                  TextButton(onPressed: () {
                    Navigator.pop(context);
                  }, child: Text("Annuler"))
                ],
              );
            });
          },
        )
      ],
    ),
  ),
);

}

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition();
    print("====================================");
    print(position.latitude);
    print(position.longitude);
    print("====================================");
  }

  Future<void> _updateAvailability(bool isAvailable) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      try {
        final DataSnapshot docSnapshot = await FirebaseDatabase.instance
            .ref('position')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .get();

        if (docSnapshot.exists) {
          await docSnapshot.ref.update({'isAvailable': isAvailable});
          print("User availability updated successfully!");
        } else {
          await FirebaseDatabase.instance.ref('position').child(FirebaseAuth.instance.currentUser!.uid).set({
            'Id_user': userId,
            'isAvailable': isAvailable,
          });
          print("User availability added successfully!");
        }
      } catch (error) {
        print("Failed to update user availability: $error");
      }
    }
  }

  Future<void> fetchAvailability() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final DataSnapshot snapshot = await FirebaseDatabase.instance
            .reference()
            .child('position')
            .child(user.uid)
            .get();

        if (snapshot.value != null) {
          final dynamic data = snapshot.value;
          if (data is Map<dynamic, dynamic>) {
            final bool isAvailable = data['isAvailable'] ?? false;
            setState(() {
              _isAvailable = isAvailable;
            });
          } else {
            print('Invalid data format in snapshot');
          }
        } else {
          print('Document does not exist in the database');
        }
      } catch (error) {
        print('Failed to get document: $error');
      }
    }
  }

  Future<void> UpdateLocation() async {
    BackgroundLocation.startLocationService();

    StreamSubscription<Position> positionStream = Geolocator.getPositionStream().listen(
      (Position? position) {
        double? currentlat = position!.latitude;
        double? currentlong = position.longitude;

        FirebaseDatabase.instance.ref('position').child(FirebaseAuth.instance.currentUser!.uid).update({
          'lat': currentlat,
          'long': currentlong,
        });
      }
    );
  }

  Future<void> getDataUser() async {
    DatabaseReference ref = FirebaseDatabase.instance.reference().child("position").child(FirebaseAuth.instance.currentUser!.uid);
    DataSnapshot snapshot = await ref.get();

    if (snapshot.value != null) {
      dynamic data1 = snapshot.value;
      data.add(data1);

      setState(() {});
    } else {
      print("Document does not exist");
    }
  }

  Future<void> _updateoccupe(bool occupee) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      try {
        final DataSnapshot docSnapshot = await FirebaseDatabase.instance
            .ref('position')
            .child(userId)
            .get();

        if (docSnapshot.exists) {
          await docSnapshot.ref.update({'occupee': occupee});
          print("User availability updated successfully!");
        } else {
          await FirebaseDatabase.instance.ref('position').child(userId).set({
            'Id_user': userId,
            'occupee': occupee,
          });
          print("User availability added successfully!");
        }
      } catch (error) {
        print("Failed to update user availability: $error");
      }
    }
  }

  Future<void> fetchoccupe() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final DataSnapshot snapshot = await FirebaseDatabase.instance
            .ref('position')
            .child(user.uid)
            .get();

        if (snapshot.value != null) {
          final dynamic data = snapshot.value;
          if (data is Map<dynamic, dynamic>) {
            final bool isOccupe = data['occupee'] ?? false;
            setState(() {
              _isOccupe = isOccupe;
            });
          } else {
            print('Invalid data format in snapshot');
          }
        } else {
          print('Document does not exist in the database');
        }
      } catch (error) {
        print('Failed to get document: $error');
      }
    }
  }

  Future<void> _refreshFCMToken() async {
    try {
      // Supprimez l'ancien token
      await FirebaseMessaging.instance.deleteToken();
      
      // Générez un nouveau token
      String? newToken = await FirebaseMessaging.instance.getToken();
      
      if (newToken != null) {
        // Mettez à jour le token dans votre base de données
        await FirebaseDatabase.instance
            .ref('position')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .update({'fcmToken': newToken});
        
        print("FCM Token refreshed successfully");
      } else {
        print("Failed to generate new FCM Token");
      }
    } catch (e) {
      print("Error refreshing FCM Token: $e");
    }
  }
}