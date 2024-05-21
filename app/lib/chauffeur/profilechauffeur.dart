import 'dart:async';
import 'dart:convert';

import 'package:app/authentification/login.dart';
import 'package:app/chauffeur/detailcource.dart';
import 'package:app/user/registeruser.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:background_location/background_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
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

  bool _isAvailable = false;
  bool isDialogShown = false;
  List data = [];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
   Future<void> sendnotificationcource(title,messagee,token) async{
 
  
  

  
  
 var headersList = {

 'Accept': '*/*',
 'Content-Type': 'application/json',
 'Authorization': 'key=AAAAnjSkllc:APA91bEHbLsmo9hyqylkEfBp1f0YYCjKfo6K6mQbB61Th1yYliWw0bvvnsLv05dJC_PIVsk4AX4_z8B6thDi8_8otTFdKV1Te6mnL1txjyhgZ7pGwTkMvg91i5Obp3kh64ah93d9KD4d' 
};
var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

 String? Id_Driver= FirebaseAuth.instance.currentUser!.uid;

var body = {
  "to": token,
  "notification": {
    "title":title,
    "body":messagee ,
    
  },
  "data":{

'identifiant':Id_Driver
    }
};

var req = http.Request('POST', url);
req.headers.addAll(headersList);
req.body = json.encode(body);


var res = await req.send();
final resBody = await res.stream.bytesToString();

if (res.statusCode >= 200 && res.statusCode < 300) {
  print(resBody);
}
else {
  print(res.reasonPhrase);
}
}

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _handleMessage(message);
    });

    getDataUser();
    fetchAvailability();
    _determinePosition();
  }

  void _handleMessage(RemoteMessage message) {
       if (message.notification != null) {
      // Fermer toute boîte de dialogue existante avant d'en afficher une nouvelle
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
              title: Text("Vous avez une cource"),
              content: Column(
                children: [ Text(message.data['adress']),
                Text(message.data['prix']),
                //Text(message.data['firstname']),
                Text(message.data['methode_payment'])],
                
              ),
              actions: [
               
                TextButton(
                  onPressed: () {
                    String token = message.data['token'];
                    sendnotification("Hello", "Le chauffeur a accepté votre course", token);
                  // Navigator.push(context, MaterialPageRoute(builder: (context) => detailcource()));
                  },
                  child: Text("Accepter"),
                ),
                TextButton(
                  onPressed: () {
                    String token = message.data['token'];
                    sendnotification("Hello", "Le chauffeur a refusé votre course", token);
                  },
                  child: Text("Refuser"),
                ),
                TextButton(onPressed: (){
                                      String token = message.data['token'];

                  sendnotificationcource("couce terminé", "couce terminé", token);
                }, child: Text("cource terminé"))
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

  Future<void> sendnotification(title, messagee, token) async {
    var headersList = {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'key=AAAAnjSkllc:APA91bEHbLsmo9hyqylkEfBp1f0YYCjKfo6K6mQbB61Th1yYliWw0bvvnsLv05dJC_PIVsk4AX4_z8B6thDi8_8otTFdKV1Te6mnL1txjyhgZ7pGwTkMvg91i5Obp3kh64ah93d9KD4d'
    };
    var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    var body = {
      "to": token,
      "notification": {
        "title": title,
        "body": messagee,
      },
      "data": {}
    };

    var req = http.Request('POST', url);
    req.headers.addAll(headersList);
    req.body = json.encode(body);

    var res = await req.send();
    final resBody = await res.stream.bytesToString();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      print(resBody);
    } else {
      print(res.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        bottomNavigationBar: GNav(tabs: [
          GButton(
            icon: Icons.settings,
            text: 'Setting',
            onPressed: () {},
          ),
          GButton(
            icon: Icons.star_rate,
            text: 'Rating',
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
                      await FirebaseAuth.instance.signOut();
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignupUserPage()));
                    }, child: Text("Ok")),
                    TextButton(onPressed: () {}, child: Text("Annuler"))
                  ],
                );
              });
            },
          )
        ]),
        appBar: AppBar(
          title: Text('Votre Profile'),
          actions: <Widget>[
            Switch(
              value: _isAvailable,
              onChanged: (newValue) async {
                setState(() {
                  _isAvailable = newValue;
                });
                await _updateAvailability(newValue);
                UpdateLocation();
              },
              activeColor: Colors.blue,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[300],
            ),
          ],
        ),
        body: ListView.builder(
          itemBuilder: (context, i) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(data[i]['Nom'], style: TextStyle(fontSize: 25)),
                    SizedBox(width: 8),
                  ],
                ),
              ],
            );
          },
          itemCount: data.length,
        ),
      ),
    );
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
      print("====================================");
      print(position.latitude);
      print(position.longitude);
      print("====================================");
    }
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

  void UpdateLocation() {
    BackgroundLocation.startLocationService(distanceFilter: 1);
    BackgroundLocation.setAndroidConfiguration(1000);

    BackgroundLocation.getLocationUpdates((location) {
      currentlat = location.latitude;
      currentlong = location.longitude;
      Future.delayed(Duration(seconds: 2));
      timer = Timer.periodic(Duration(seconds: 10), (timer) {
        FirebaseDatabase.instance.ref('position').child(FirebaseAuth.instance.currentUser!.uid).update({
          'lat': currentlat,
          'long': currentlong,
        });
      });
    });
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
}
