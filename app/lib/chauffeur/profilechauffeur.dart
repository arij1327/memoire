import 'dart:async';
import 'dart:convert';

import 'package:app/authentification/login.dart';
import 'package:app/chauffeur/detailcource.dart';
import 'package:app/user/registeruser.dart';
import 'package:background_location/background_location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
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
   String? _prenom;

  bool _isAvailable = false;
  bool isDialogShown = false;
  bool _isOccupe = false;
  List data = [];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
   Future<void> sendnotificationcource(title,messagee,token) async{
  String? Id_Driver= FirebaseAuth.instance.currentUser!.uid;

  
  
  

  

    const String projectId = 'apptaxi-89d1b';

  // Configuration pour l'authentification du compte de service
  const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  var serviceAccountJson = r'''
  {
   "type": "service_account",
  "project_id": "apptaxi-89d1b",
  "private_key_id": "2c6aeee8ecbd561ec229e9a3c0b63a20e6404a15",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDBcTLwC5uxqeyE\nTh+nYh20ie5lozVugmBkp1RihZXgV5+E+rKh3WTU2q7FnD99pUHnRzY/f+6tEc64\n6/gCmMnU+yrVKGgSa6IAEjnHUtmoRYZ92cwViArk306IUzG66jV/7J7MI1wLBDvf\nubx8b64LxTlKbIvqjxdUGNe2XYl+9gyIghs3uqERVqvBLtua5ArJXpxVf1Vvw93B\nccfNRRrVybqs5MZxSsxAsaQM30xEUbPMIricEVjmi22TY/KTTh/p1kMLDPc1lQqh\nc8YQmCI8LnnyXudmGQeDxQo40aH/w3w4xRkIVOmvqGomMO+Bhejq+adv8G+6w6+l\nOFqBZ54ZAgMBAAECggEAM9FSb0n0wXE+yawxv4FBatC9+xzunbUwBBZsvN2C6e8e\n7JzJSCHJtlkEEyxJN6uSjVUem4D2GwdXpGKVc4ChJDvJ3AKwairJ4RIAxzuS0Yga\nQFEc4bGpFWkaHNuISUUe4q8sVIuuRscyELqs2nqCGWYR9DVCf6kn+x+SfSfuQoNH\n8AafCL62S9xSIVGWIsKZcB8L16IWTJF00YYKPxcffEOPa9ZFxMevBytNpRYvBt15\nsjqPh6oggtfGRcngtTruYrPrPWQ9Ex2LxkyZ1ZrnEanMETgH78pdfmWU8MfFHjv0\ne2Ds3+/CdS+Rs7fiGPE77hFSKM4bcI2stoKNwL99HwKBgQDyEw1jtkfnS+kQBpjV\n+6rHB1pFT089NPtEJN09s/wDpIT76Pw5hyzWGqJ4Tkrh8YSBgsqF7fTOvoO1VnQS\nim54efvwIiE0cxY4s82smL4ufEOKObrnYgcQe2ZUZGVTfAD6XtC8uM4hfrWvhQ9W\nZRmlMJ6nFTvO31y8M1+J0IMdgwKBgQDMkfTK4VaCHeAjVcwQkXgY1sDU445OA6bB\nkUfvP0Y9F/P01ojUnXN/N6Xjou8lF9hdl9DIYQUNYhXkWx7He9ay5Yyz9xwfoSEX\n/6cLnocMkV2YB7vVJX7ppG3MTZs9y8YGlQZ1+kEfr5pAnWs2XLCOMgslL/uW9Atr\nzfWnu2y/MwKBgQDa8NRpXNHHpmaSsgTFdKtO+51vln2qdCLVzSm0xvamLMSCOoT1\nWwb4VnqfqOAdXp1jrXGSlFeYLcNd3WV5525m1J1C4Pt7PqPYgPcCpdtMm+NSP0iG\nQaj2BUXWCj+CtGMGD39nURZOQRX+O7BViXcaatDzeUbwoiBzr1s3gDk2FQKBgQCf\n+ihYHB5dxOVKXMcn0cr8ibzk/0uDAOIAkA+ULoRMNJYoSzlYJAV1YFxPh1TDSkF+\n98FjYlPkImeCXCvWzqaY4mDFQCLzLTvHG7tTn9Z24psx0CJ4zkjQiDEBS1Ny4Q9s\niFA0JM+W6umTTEfSjGvZ15LVsw9p/lGMLdXFJRIm9wKBgQCFFl3whWaIxsmwbbWn\n4WUkTeGuPNIDXxdPc8WNk3NQvf3eKlMCjM9uUNsADb3HDV3qGYMZe9JQEjnH8wFd\nLnnKeOqObFRBInLtAtyCOC/QxshPB5Xn8kR8APv1JZ3q1pU3VHbzJUnykyfs/8Jp\nQFrDHrWkwOqLjVM2nKtwd0KKfw==\n-----END PRIVATE KEY-----\n",
  "client_email": "apptaxi-89d1b@appspot.gserviceaccount.com",
  "client_id": "106201903903504776927",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/apptaxi-89d1b%40appspot.gserviceaccount.com",
  "universe_domain": "googleapis.com"
  }
  ''';

  var accountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
  var authClient = await clientViaServiceAccount(accountCredentials, _scopes);
  
 var headersList = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer 2c6aeee8ecbd561ec229e9a3c0b63a20e6404a15'
  };

var body = {
  "message": {
    "token": token,
    "notification": {
      "title": title,
      "body": messagee,
      
    },
      "data":{
'identifiant':Id_Driver

    }
  }
};

 
  var url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');
  var req = http.Request('POST', url);
  req.headers.addAll({
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ${authClient.credentials.accessToken.data}'
  });
  req.body = json.encode(body);

  var res = await req.send();
  final resBody = await res.stream.bytesToString();

  if (res.statusCode >= 200 && res.statusCode < 300) {
    print('Notification sent successfully: $resBody');
  } else {
    print('Failed to send notification: ${res.statusCode} - ${res.reasonPhrase}');
    print('Response body: $resBody');
  }
}

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
// FirebaseMessaging.onMessage.listen((message) { 
//   if(message.notification!.body== "utilisateur a annulé la course"){
//     Navigator.pop(context);
//   }
//   else if(message.notification!.body =="utilisateur a confirmé la course"){
//      Navigator.pushNamed(context, '/detailcource', arguments: {
// 'adress':message.data['adress'],
// 'prix':message.data['prix'],
// 'token':message.data['token']

                 
                       
//                         });

//   }
// });

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

  void _handleMessage(RemoteMessage message)async {
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
              title: Text("Vous avez une course"),
              content: Column(
                children: [ Text(message.data['adress']),
                                    Text('Destination ${message.data['destination']}'),

                Text('Prix de course ${message.data['prix']}'),
                //Text(message.data['firstname']),
                Text('Mode de payment ${message.data['methode_payment']}')],
                
              ),
              actions: [
               
                TextButton(
                  onPressed: () {
                    String token = message.data['token'];
                    sendnotification("LuxBlack", "Le chauffeur a accepté votre course", token);
                    Navigator.pop(context);
                    

//                Navigator.pushNamed(context, '/detailcource', arguments: {
// 'adress':message.data['adress'],
// 'prix':message.data['prix'],
// 'token':message.data['token']

                 
                       
//                         });
                  
                  },
                  child: Text("Accepter"),
                ),
                TextButton(
                  onPressed: () {
                    String token = message.data['token'];
                    sendnotification("LuxBlack", "Le chauffeur a refusé votre course", token);
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

   Future<void> sendnotification(title,messagee,token) async{
 
  
 // var firstname= await getDataofUser();
  String? token1 = await FirebaseMessaging.instance.getToken();
String  id=FirebaseAuth.instance.currentUser!.uid;
    const String projectId = 'apptaxi-89d1b';

  // Configuration pour l'authentification du compte de service
  const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  var serviceAccountJson = r'''
  {
   "type": "service_account",
  "project_id": "apptaxi-89d1b",
  "private_key_id": "2c6aeee8ecbd561ec229e9a3c0b63a20e6404a15",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDBcTLwC5uxqeyE\nTh+nYh20ie5lozVugmBkp1RihZXgV5+E+rKh3WTU2q7FnD99pUHnRzY/f+6tEc64\n6/gCmMnU+yrVKGgSa6IAEjnHUtmoRYZ92cwViArk306IUzG66jV/7J7MI1wLBDvf\nubx8b64LxTlKbIvqjxdUGNe2XYl+9gyIghs3uqERVqvBLtua5ArJXpxVf1Vvw93B\nccfNRRrVybqs5MZxSsxAsaQM30xEUbPMIricEVjmi22TY/KTTh/p1kMLDPc1lQqh\nc8YQmCI8LnnyXudmGQeDxQo40aH/w3w4xRkIVOmvqGomMO+Bhejq+adv8G+6w6+l\nOFqBZ54ZAgMBAAECggEAM9FSb0n0wXE+yawxv4FBatC9+xzunbUwBBZsvN2C6e8e\n7JzJSCHJtlkEEyxJN6uSjVUem4D2GwdXpGKVc4ChJDvJ3AKwairJ4RIAxzuS0Yga\nQFEc4bGpFWkaHNuISUUe4q8sVIuuRscyELqs2nqCGWYR9DVCf6kn+x+SfSfuQoNH\n8AafCL62S9xSIVGWIsKZcB8L16IWTJF00YYKPxcffEOPa9ZFxMevBytNpRYvBt15\nsjqPh6oggtfGRcngtTruYrPrPWQ9Ex2LxkyZ1ZrnEanMETgH78pdfmWU8MfFHjv0\ne2Ds3+/CdS+Rs7fiGPE77hFSKM4bcI2stoKNwL99HwKBgQDyEw1jtkfnS+kQBpjV\n+6rHB1pFT089NPtEJN09s/wDpIT76Pw5hyzWGqJ4Tkrh8YSBgsqF7fTOvoO1VnQS\nim54efvwIiE0cxY4s82smL4ufEOKObrnYgcQe2ZUZGVTfAD6XtC8uM4hfrWvhQ9W\nZRmlMJ6nFTvO31y8M1+J0IMdgwKBgQDMkfTK4VaCHeAjVcwQkXgY1sDU445OA6bB\nkUfvP0Y9F/P01ojUnXN/N6Xjou8lF9hdl9DIYQUNYhXkWx7He9ay5Yyz9xwfoSEX\n/6cLnocMkV2YB7vVJX7ppG3MTZs9y8YGlQZ1+kEfr5pAnWs2XLCOMgslL/uW9Atr\nzfWnu2y/MwKBgQDa8NRpXNHHpmaSsgTFdKtO+51vln2qdCLVzSm0xvamLMSCOoT1\nWwb4VnqfqOAdXp1jrXGSlFeYLcNd3WV5525m1J1C4Pt7PqPYgPcCpdtMm+NSP0iG\nQaj2BUXWCj+CtGMGD39nURZOQRX+O7BViXcaatDzeUbwoiBzr1s3gDk2FQKBgQCf\n+ihYHB5dxOVKXMcn0cr8ibzk/0uDAOIAkA+ULoRMNJYoSzlYJAV1YFxPh1TDSkF+\n98FjYlPkImeCXCvWzqaY4mDFQCLzLTvHG7tTn9Z24psx0CJ4zkjQiDEBS1Ny4Q9s\niFA0JM+W6umTTEfSjGvZ15LVsw9p/lGMLdXFJRIm9wKBgQCFFl3whWaIxsmwbbWn\n4WUkTeGuPNIDXxdPc8WNk3NQvf3eKlMCjM9uUNsADb3HDV3qGYMZe9JQEjnH8wFd\nLnnKeOqObFRBInLtAtyCOC/QxshPB5Xn8kR8APv1JZ3q1pU3VHbzJUnykyfs/8Jp\nQFrDHrWkwOqLjVM2nKtwd0KKfw==\n-----END PRIVATE KEY-----\n",
  "client_email": "apptaxi-89d1b@appspot.gserviceaccount.com",
  "client_id": "106201903903504776927",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/apptaxi-89d1b%40appspot.gserviceaccount.com",
  "universe_domain": "googleapis.com"
  }
  ''';

  var accountCredentials = ServiceAccountCredentials.fromJson(serviceAccountJson);
  var authClient = await clientViaServiceAccount(accountCredentials, _scopes);
  
 var headersList = {
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer 2c6aeee8ecbd561ec229e9a3c0b63a20e6404a15'
  };

var body = {
  "message": {
    "token": token,
    "notification": {
      "title": title,
      "body": messagee,
      
    },
      "data":{
   'id':id,
'tok':token1
    }
  }
};

 
  var url = Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send');
  var req = http.Request('POST', url);
  req.headers.addAll({
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer ${authClient.credentials.accessToken.data}'
  });
  req.body = json.encode(body);

  var res = await req.send();
  final resBody = await res.stream.bytesToString();

  if (res.statusCode >= 200 && res.statusCode < 300) {
    print('Notification sent successfully: $resBody');
  } else {
    print('Failed to send notification: ${res.statusCode} - ${res.reasonPhrase}');
    print('Response body: $resBody');
  }
}

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        bottomNavigationBar: GNav(tabs: [
         
         GButton(            icon: Icons.exit_to_app,
         text: "parametre",
         onPressed: () {
         },
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
                    TextButton(onPressed: () {
                      Navigator.pop(context);
                    }, child: Text("Annuler"))
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
             await UpdateLocation();
          

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
      );
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;

    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   throw 'Location services are disabled.';
    // }
    permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      // if (permission == LocationPermission.denied) {
      //   throw 'Location permissions are denied';
      // }
    // }
    // if (permission == LocationPermission.deniedForever) {
    //   throw 'Location permissions are permanently denied.';
    // }
    // if (permission == LocationPermission.whileInUse) {
      Position position = await Geolocator.getCurrentPosition();
      print("====================================");
      print(position.latitude);
      print(position.longitude);
      print("====================================");
    // }
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

 

Future<void> UpdateLocation()async {
  // Start the background location service
  BackgroundLocation.startLocationService();

  //  BackgroundLocation.setAndroidConfiguration(1000);

  //   BackgroundLocation.getLocationUpdates((location) {
  //     currentlat = location.latitude;
  //     currentlong = location.longitude;
  //     Future.delayed(Duration(seconds: 2));
  //       FirebaseDatabase.instance.ref('position').child(FirebaseAuth.instance.currentUser!.uid).push().set({
  //         'lat': currentlat,
  //         'long': currentlong,
  //       });
    
  //   }); 
    
   
StreamSubscription<Position> positionStream = Geolocator.getPositionStream().listen(
    (Position? position) {
double? currentlat= position!.latitude;
double? currentlong= position.longitude;

        FirebaseDatabase.instance.ref('position').child(FirebaseAuth.instance.currentUser!.uid).update({
          'lat': currentlat,
          'long': currentlong,
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
   refrechtoken(){
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {

     });
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
}