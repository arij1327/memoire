import 'dart:async';
import 'dart:convert';


import 'package:app/authentification/login.dart';
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

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late LatLng? _currentPositionchauff;
    late TextEditingController _emailController;
    double ?currentlat;
    double? currentlong;
     Timer ?timer;

  bool _isAvailable = false;
  List data =[];
   void initState() {

    super.initState();

FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  try {
    if (message.notification != null) {
     // print(message.data['adress']);
      showDialog(
        context: context, // Ensure 'context' is accessible in this scope
        builder: (context) {
          return AlertDialog(
            content: Text('Vous avez une course'),

            actions: [
             Text(message.data['adress']),
              TextButton(
                onPressed: () {
                  String token = message.data['token'];
                  sendnotification("Hello", "Le chauffeur a accepté votre course", token);
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
            ],
          );
        },
      );
    }
  } catch (e) {
    print('Error handling FCM message: $e');
  }
});
  
 FirebaseMessaging.onMessage.listen((RemoteMessage message) async { 
  print('messsageeee');
if(message.notification!=null){
print(message.data['adress'])
;
 showDialog(context: context, builder: (context){
    return  AlertDialog(content:Text('vous avez une course'),
    actions: [
       Text(message.data['adress']),
      TextButton(onPressed: (){
    String token=message.data['token'];
      sendnotification("Hello", "Driver a accepté votre course", token);
    }, child: Text("Accepter"),),
    TextButton(onPressed: (){
      String token=message.data['token'];
      sendnotification("Hello", "Driver a refusé votre course", token);
    
    }, child: Text("Reffuser "),)],);
     }
    );

}

    

  });
  
   
    getDataUser();
  
  fetchAvailability();

_determinePosition();
    
  }
  Future<void> sendnotification(title,messagee,token) async{
 
  
  

  
  
 var headersList = {

 'Accept': '*/*',
 'Content-Type': 'application/json',
 'Authorization': 'key=AAAAnjSkllc:APA91bEHbLsmo9hyqylkEfBp1f0YYCjKfo6K6mQbB61Th1yYliWw0bvvnsLv05dJC_PIVsk4AX4_z8B6thDi8_8otTFdKV1Te6mnL1txjyhgZ7pGwTkMvg91i5Obp3kh64ah93d9KD4d' 
};
var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

 

var body = {
  "to": token,
  "notification": {
    "title":title,
    "body":messagee ,
    
  },
  "data":{


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
  Widget build(BuildContext context) {
    return Scaffold(
     bottomNavigationBar: GNav(tabs: [
       GButton(
      icon: Icons.settings,
      text: 'Setting',
      onPressed: (){

      },
    ), GButton(
      icon: Icons.star_rate,
      text: 'Rating',
    ),
   
  
    GButton(
      icon: Icons.exit_to_app,
      text: " Déconnecter",
      onPressed: (){
        showDialog(context: context, builder: (context){
          return AlertDialog(
            title: Text("Déconnecter"),
            content: Text("Voulez-vous vraiment vous déconnecter?"),
            
            actions: [TextButton(onPressed:()async {await FirebaseAuth.instance.signOut(); 


   Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));}, child: Text("Ok")),
            TextButton(onPressed: (){}, child: Text("Annuler"))],
          );
        } );
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
              await _updateAvailability( newValue);
              UpdateLocation();
        
            },
            activeColor: Colors.blue,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey[300],
          ),
      /*  IconButton(onPressed: ()async{
await FirebaseAuth.instance.signOut(); 


   Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginPage()));  }, icon: Icon(Icons.exit_to_app)),
      */  ],
      ),
      body: ListView.builder(itemBuilder: 
      (context,i) {
        return Column(
          children: [
           /* CircleAvatar(
              child:Image.network(data[i]['image']) ,
            ),*/
            
           Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(data[i]['Nom'],style: TextStyle(fontSize: 25),),
               SizedBox(width:8),
                Text(data[i]['Prénom'],style: TextStyle(fontSize: 25),),

            ],
           )
          ],
        );

      }, itemCount: data.length),
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

  Position position= await Geolocator.getCurrentPosition();
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
        // Check if the document exists
        final  DataSnapshot docSnapshot = await FirebaseDatabase.instance
            .ref('position')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .get();

        if (docSnapshot.exists) {
          // Update the document
          await docSnapshot.ref.update({'isAvailable': isAvailable
        
          });
          print("User availability updated successfully!");
        } else {
          // Create a new document
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



  /*Future<void> _fetchAvailability() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      try {
        // Get the document
        final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection('position')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get();

        if (documentSnapshot.exists) {
          setState(() {
            _isAvailable = documentSnapshot.exists
                ? (documentSnapshot.data() as Map<String, dynamic>)['isAvailable'] ?? false
                : false;
          });
        } else {
          print('Document does not exist on the database');
        }
      } catch (error) {
        print('Failed to get document: $error');
      }
    }
  }*/
Future<void> fetchAvailability() async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      // Get the document
      final DataSnapshot snapshot = await FirebaseDatabase.instance
          .reference()
          .child('position')
          .child(user.uid)
         .get();

      // Check if the document exists
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

  void UpdateLocation(){

    BackgroundLocation.startLocationService(distanceFilter : 1);
     BackgroundLocation.setAndroidConfiguration(1000);

  BackgroundLocation.getLocationUpdates((location) {
    currentlat=location.latitude;
    currentlong =location.longitude;
    Future.delayed( Duration(seconds: 2));
    timer=Timer.periodic(Duration(seconds: 10), (timer) { 
         FirebaseDatabase.instance.ref('position').child(FirebaseAuth.instance.currentUser!.uid).update({
    
   
       'lat':currentlat,
       'long':currentlong

      // Add more fields as needed
    });
    
    });
 
  });

  }
  /* getDataUser()async{
   DocumentSnapshot documentSnapshot= await FirebaseFirestore.instance.collection("chauffeur").doc(FirebaseAuth.instance.currentUser!.uid).get();
  if (documentSnapshot.exists) {
        data.add(documentSnapshot.data());
        setState(() {
          
        });
      } else {
        print("Document does not exist");
      }
  }*/

 // Import de la librairie Firebase Realtime Database

Future<void> getDataUser() async {
  DatabaseReference ref = FirebaseDatabase.instance.reference().child("position").child(FirebaseAuth.instance.currentUser!.uid);

  // Fetch data once
  DataSnapshot snapshot = await ref.get();

  if (snapshot.value != null) {
    // Data exists, add it to your list or use it as needed
    dynamic data1 = snapshot.value;
data.add(data1);    

    setState(() {
      // Update the UI with the retrieved data if necessary
    });
  } else {
    print("Document does not exist");
  }
}

}