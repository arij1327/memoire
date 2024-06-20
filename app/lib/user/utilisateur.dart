import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:app/a%20propos.dart';
import 'package:app/getpointpolyline.dart';
import 'package:app/homepage.dart';
import 'package:app/location_search_screen.dart';
import 'package:app/paymentpaypal.dart';
import 'package:app/provider.dart';
import 'package:app/stripe_payment/stripe_keys.dart';
import 'package:app/user/historiquetrajet.dart';
import 'package:app/user/profileuser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:flutter_address_from_latlng/flutter_address_from_latlng.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_paypal_checkout/flutter_paypal_checkout.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:app/constant.dart';
import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';






class InterfacePage extends StatefulWidget  {
  const InterfacePage({Key? key}) : super(key: key);

  @override
  _InterfacePageState createState() => _InterfacePageState();
}

class _InterfacePageState extends State<InterfacePage>  with SingleTickerProviderStateMixin{
  String? _placeName;
  double average =0.0;
 
String? methodepayment;
 
double searchwidth=400;
bool isLoding=true;
 
Future<Object> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
 

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 
if(permission==LocationPermission.whileInUse){
  Position position= await Geolocator.getCurrentPosition();
  print("====================================");
  print(position.latitude);
  print(position.longitude); 
  print("====================================");
 
   String formattedAddress = await FlutterAddressFromLatLng().getFormattedAddress(
  latitude: position.latitude,
  longitude: position.longitude,
  googleApiKey: "AIzaSyC7ckSip1a_oVGM1y7nPSWGUdTEPbkANIA",);
 print(formattedAddress);
 
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);

    
    });
    markersList.add (Marker (markerId: const MarkerId ("0"), position: LatLng (_currentPosition!.latitude,_currentPosition!.longitude)));
_mapController?.animateCamera (CameraUpdate.newLatLngZoom (LatLng (_currentPosition!.latitude, _currentPosition!.longitude), 14.0));

    print(_currentPosition);

    


}

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
Set<Marker> markersList = {
  
};

  static const LatLng _initialPosition = LatLng(33.886740, 10.101340);
  final TextEditingController destinationController = TextEditingController();
  GoogleMapController? _mapController;
  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);

  double ?latuser;
 double? longuser;
  LatLng? _currentPosition;
  LatLng? _destinationposition;
  bool draweropen= true;



  List<Map<String, dynamic>> nearbyDrivers = [];




   int currentDriverIndex = 0;

bool destinationChosen = false; 
  LatLng? l;
  LatLng? _currentPositionchauff;
  final double radiusInKm = 0.1;
   // LatLng? _currentPositionchauff;<
   bool selected= false;
    String ?selectedMethodePayment='';
 int? courcePrice;
 List datauser= [];
 
  
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
 // late Location _locationController;
   late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    
     _animationController = AnimationController(
      duration: const Duration(seconds: 2), // Adjust the duration as needed
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
   
  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
   
    if (message.notification!.body == "Le chauffeur a accepté votre course") {
         _animationController.reset();
        _animationController.forward();
  showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Voulez vous confirmé la course? ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _animation.value,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      );
                    },
                  ),
                  SizedBox(height: 40),
               Column(children: [   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     Text(
                    'Annuler la course',
                    style: TextStyle(fontSize: 16),
                  ), 
                      SizedBox(width: 40),
                      IconButton(
                        icon: Icon(Icons.cancel_outlined),
                        onPressed: () {
                          String token = message.data['tok'];
                         Navigator.pop(context);
                         sendnotification("Annulation du course ","utilisateur a annulé la course", token);
                     repeatSearchDestination();
                        },
                      ),
                    ],
                  ),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     Text(
                    'Confirmer la course',
                    style: TextStyle(fontSize: 16),
                  ), 
                      SizedBox(width: 40),
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                        
                          sendnotification("Confirmation du course ","utilisateur a confirmé la course", message.data['tok']);
                      Navigator.pop(context);
                        // repeatSearchDestination();
                        },
                      ),
                    ],
                  ),
                  ],),
                  SizedBox(height: 20),
                 
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Fermer'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
             
  
      
      }
    });

  
     FirebaseMessaging.onMessage.listen((message)async {
        
       
    if (message.notification!.body == "Le chauffeur a accepté votre course") {
         _animationController.reset();
        _animationController.forward();
  showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Voulez vous confirmé la course? ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _animation.value,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      );
                    },
                  ),
                  SizedBox(height: 40),
               Column(children: [   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     Text(
                    'Annuler la course',
                    style: TextStyle(fontSize: 16),
                  ), 
                      SizedBox(width: 40),
                      IconButton(
                        icon: Icon(Icons.cancel_outlined),
                        onPressed: () {
                         Navigator.pop(context);
                         sendnotification("Annulation du course ","utilisateur a annulé la course ", message.data['id']);
                         repeatSearchDestination();
                        },
                      ),
                    ],
                  ),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                     Text(
                    'Confirmer la course',
                    style: TextStyle(fontSize: 16),
                  ), 
                      SizedBox(width: 40),
                      IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                         Navigator.pop(context);
                     
                         repeatSearchDestination();
                        },
                      ),
                    ],
                  ),
                  ],),
                  SizedBox(height: 20),
                 
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Fermer'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
             
  
      
      }
  });
  
    //getnotification();
    _determinePosition();
    getDataUser();
    
   // getDataofUser();
   //_getNearbyDrivers();

    super.initState();
    
  

  
FirebaseMessaging.onMessageOpenedApp.listen((message) {
  print("refuse");
  if (message.notification!.body == "Le chauffeur a refusé votre course") {
    
      
    
handleDriverRefusal();   
  }
});

    //_locationController = Location();
    /*getLocationUpdates();*/
 
  FirebaseMessaging.onMessage.listen((message) {
    print("refuse");
     if (message.notification!.body=="Le chauffeur a refusé votre course"){

 
       
handleDriverRefusal();
       
    }
   });











FirebaseMessaging.onMessage.listen((message)async { 

      if (message.notification?.body == "Course terminé") {
      
       
                        if (selectedMethodePayment == "Stripe") {
   Navigator.pushNamed(context, '/payment', arguments: {
                         'id': message.data['identifiant']
                          
                        });

      }else if(selectedMethodePayment== "Espèce"){
         showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: RatingDialog(
            initialRating: 1.0,
            title: Text(
              'Quel est votre avis sur le service du taxi',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            message: Text(
              'Tap a star to set your rating. Add more description here if you want.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            image: const FlutterLogo(size: 100),
            submitButtonText: 'Submit',
            commentHint: 'Set your custom comment hint',
            onCancelled: () => print('cancelled'),
            onSubmitted: (response) {
              print('rating: ${response.rating}, comment: ${response.comment}');
              // Call your submitRating function here
              submitRating(response.rating, response.comment,message.data['id']);
            },
          ),
        );
      },
    );
      }

  }});


  
    FirebaseMessaging.onMessageOpenedApp.listen((message)async {
      
      if (message.notification?.body == "Course terminé") {
   
       
                        if (selectedMethodePayment == "Stripe") {
   Navigator.pushNamed(context, '/payment', arguments: {
                         'id': message.data['identifiant']
                          
                        });

      }else if(selectedMethodePayment== "Espèce"){
         showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: RatingDialog(
            initialRating: 1.0,
            title: Text(
              'Quel est votre avis sur le service du taxi',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            message: Text(
              'Tap a star to set your rating. Add more description here if you want.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            image: const FlutterLogo(size: 100),
            submitButtonText: 'Submit',
            commentHint: 'Set your custom comment hint',
            onCancelled: () => print('cancelled'),
            onSubmitted: (response) {
              print('rating: ${response.rating}, comment: ${response.comment}');
              // Call your submitRating function here
              submitRating(response.rating, response.comment,message.data['id']);
            },
          ),
        );
      },
    );
      }

  }});

  }
   static Future<void> submitRating(double rating, String comment, id) async {
    try {
      // Enregistrer la notation dans Firebase Database
      await FirebaseDatabase.instance
          .ref('rating')
         .child(id.toString())
          .push()
          .set({
        // ID de l'utilisateur actuel
        'rating': rating.toString(),
        'comment': comment.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      print('Notation soumise avec succès !');
    } catch (e) {
      print('Échec de la soumission de la notation : $e');
    }
  }
   
     Future<void> handleDriverRefusal() async {
  print("provider");
  var driverNotifier = Provider.of<DriverNotifier>(context, listen: false);

  // Check if there are drivers in the list
  if (driverNotifier.nearbyDrivers.isNotEmpty) {
    // Check if the current index is within bounds
    if (driverNotifier.currentDriverIndex < driverNotifier.nearbyDrivers.length) {
      // Remove the driver at the current index
      driverNotifier.removeDriverAtIndex(driverNotifier.currentDriverIndex);
      // Increment the index after successful removal
      driverNotifier.currentDriverIndex++;
    } else {
      // Handle the case where the current index is out of bounds
      print("No more drivers to remove. Current index: ${driverNotifier.currentDriverIndex}, List length: ${driverNotifier.nearbyDrivers.length}");
    }
  } else {
    // Handle the case where there are no drivers in the list
    print("No nearby drivers available.");
    // Load nearby drivers if the list is empty
    await _loadNearbyDrivers();
  }
}


   Future<void> _loadNearbyDrivers() async {
  try {
    List<Map<String, dynamic>> drivers = await findNearbyDrivers();
    Provider.of<DriverNotifier>(context, listen: false).setNearbyDrivers(drivers);
   setState(() {
     courcePrice;
   });
   
    print("Drivers loaded successfully: $drivers");
  } catch (error) {
    print("Error loading drivers: $error");
    // Gérer les erreurs comme nécessaire
  }
}


  @override
  void dispose() {
   // _locationController.dispose(); // Dispose location controller
    super.dispose();
   
    
  }
  
   
  void repeatSearchDestination() {
  setState(() {
    polylineSet.clear();
    markersList.clear();
    polylineCo.clear();
    destinationChosen = false;
  });
}
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
  key: homeScaffoldKey,
  drawer: Drawer(
    child: Column(
      children: [
        ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: _buildUserList(),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileUser()));
          },
        ),
       
        ListTile(
          leading:Icon(Icons.access_alarm) ,
          title: Text("Historique", style: TextStyle(fontSize: 18)),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Historique()));
          },
        ),
          ListTile(
            leading: Icon(Icons.info),
          title: Text("A propos", style: TextStyle(fontSize: 18)),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => A_propos()));
          },
        ),
        ListTile(
          leading:  Icon(Icons.exit_to_app),
          title: Text("Déconnecter", style: TextStyle(fontSize: 18)),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (context) => homepage()));
          },
        ),
      ],
    ),
  ),
  body:  Stack(
    children: [
      GoogleMap(
        markers: markersList,
        polylines: polylineSet,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: true,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 15,
        ),
        onMapCreated: (controller) {
          setState(() {
            _mapController = controller;
          });
        },
      ),
      Positioned(
        top: 40,
        left: 30,
        child: GestureDetector(
          onTap: () {
            if (!draweropen) {
              homeScaffoldKey.currentState!.openDrawer();
            } else {
              setState(() {
                polylineSet.clear();
                markersList.clear();
                polylineCo.clear();
                destinationChosen = !destinationChosen;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22.0),
              boxShadow: [
                BoxShadow(color: Colors.black, blurRadius: 6.0, spreadRadius: 0.5, offset: Offset(0.7, 0.7)),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon((!destinationChosen) ? Icons.menu : Icons.close),
            ),
          ),
        ),
      ),
      (!destinationChosen)
          ? Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 160),
                child: Container(
                  width: 400,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 24),
                    child: TextField(
                      controller: destinationController,
                      onTap: () async {
                        await searchPlace();
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter destination',
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Consumer<DriverNotifier>(
  builder: (context, driverNotifier, child) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      maxChildSize: 0.95,
      minChildSize: 0.1,
      builder: (BuildContext context, ScrollController scrollController) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
            ),
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
             SliverList(
  delegate: SliverChildBuilderDelegate(
    (BuildContext context, int index) {
      if (index < driverNotifier.nearbyDrivers.length) {
        Map<String, dynamic> driver = driverNotifier.nearbyDrivers[index];
        return Column(
          children: [
            ListTile(
              leading: Image.asset("asset/logotaxi.jpg", width: 80),
              title: Row(
                children: [
                  Text(driver['nom']),
                  SizedBox(width: 5),
                  Text(driver['prenom']),
                ],
              ),
              subtitle: Text('Prix: ${driver['prix']} TND'),
              trailing: Text(driver['voiture']),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                   
                    return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return AlertDialog(
                          title: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.arrow_back),
                              ),
                              Text(
                                "Choisir le mode de paiement",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile(
                                value: "Espèce",
                                groupValue: selectedMethodePayment,
                                onChanged: (val) {
                                  setState(() {
                                    selectedMethodePayment = val as String?;
                                  });
                                },
                                title: Text("Espèce"),
                                subtitle: Text("Payez en espèces au lieu de déposer"),
                              ),
                              RadioListTile(
                                value: "Stripe",
                                groupValue: selectedMethodePayment,
                                onChanged: (val) {
                                  setState(() {
                                    selectedMethodePayment = val as String?;
                                  });
                                },
                                title: Text("Stripe"),
                                subtitle: Text("Payez avec carte de crédit"),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                sendnotification("hello", "notification", driver['token']);
                                Navigator.pop(context);
                              },
                              child: Text("Confirmer"),
                            )
                          ],
                        );
                      },
                    );
                  },
                );
              },
              child: Text('Envoyer Notification'),
            ),
          ],
        );
      } else {
        return null;
      }
    },
    childCount: 1,
  ),
)

            ],
          ),
        );
      },
    );
  },
),

  ]));}

       
Widget _buildUserList(){
  
  return ListView.builder(
    shrinkWrap: true,
    itemCount:datauser.length ,
    itemBuilder: (context,i){
    return ListTile(
      title: Text(
datauser[i]['Nom']?? ''     ),
    );
  });
}
 Future<void> getDataUser() async {
  DatabaseReference ref = FirebaseDatabase.instance.ref().child('user').child(FirebaseAuth.instance.currentUser!.uid);

  // Fetch data once
  DataSnapshot snapshot = await ref.get();

  if (snapshot.value != null) {
    // Data exists, add it to your list or use it as needed
    dynamic data = snapshot.value;

    setState(() {
      datauser.add(data);    

    });
  } else {
    print("Document does not exist");
  }
}

    void _requestPermissions() {
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  


Future getAdress()async{
    Position position= await Geolocator.getCurrentPosition();
   String formattedAddress = await FlutterAddressFromLatLng().getFormattedAddress(
  latitude: position.latitude,
  longitude: position.longitude,
  googleApiKey: "AIzaSyC7ckSip1a_oVGM1y7nPSWGUdTEPbkANIA",);
  return formattedAddress;
}
Future getdestination()async{
    Position position= await Geolocator.getCurrentPosition();
   String destination = await FlutterAddressFromLatLng().getFormattedAddress(
  latitude: _destinationposition!.latitude,
  longitude: _destinationposition!.longitude,
  googleApiKey: "AIzaSyC7ckSip1a_oVGM1y7nPSWGUdTEPbkANIA",);
  return destination;
}


  Future<void> sendnotification(title,messagee,token) async{
 var formattedAddress = await getAdress();
 var destination= await getdestination();
 String? methodepayment=selectedMethodePayment;
  
  //var firstname= await getDataofUser();

  
  
 var headersList = {

 'Accept': '*/*',
 'Content-Type': 'application/json',
 'Authorization': 
 'key=AAAAnjSkllc:APA91bEHbLsmo9hyqylkEfBp1f0YYCjKfo6K6mQbB61Th1yYliWw0bvvnsLv05dJC_PIVsk4AX4_z8B6thDi8_8otTFdKV1Te6mnL1txjyhgZ7pGwTkMvg91i5Obp3kh64ah93d9KD4d' 
};
var url = Uri.parse('https://fcm.googleapis.com/fcm/send');

  String? token1 = await FirebaseMessaging.instance.getToken();

var body = {
  "to": token,
  "notification": {
    "title":title,
    "body":messagee ,
    
  },
  "data":{
     "token":token1,
   "adress": formattedAddress,
   "destination":destination,
   "methode_payment":methodepayment.toString(),
   "prix":courcePrice.toString(),
//   "firstname":firstname

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

getAddressFromCoordinates()async{
   Position position= await Geolocator.getCurrentPosition();
   String formattedAddress = await FlutterAddressFromLatLng().getFormattedAddress(
  latitude: position.latitude,
  longitude: position.longitude,
  googleApiKey: "AIzaSyC7ckSip1a_oVGM1y7nPSWGUdTEPbkANIA",
  
);


return formattedAddress;}

Future<List<Map<String, dynamic>>> findNearbyDrivers() async {
    List<Map<String, dynamic>> nearbyDrivers = [];
      List<Placemark> placemarks = await placemarkFromCoordinates(_currentPosition!.latitude, _currentPosition!.longitude);
Placemark firstPlacemark = placemarks.first;
String? placeName = firstPlacemark.name;

  String dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    try {
      
      var snapshot = await FirebaseDatabase.instance.ref().child('position').once();

      DataSnapshot dataSnapshot = snapshot.snapshot;

      var value = dataSnapshot.value;

      if (value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data = value;
        data.forEach((key, value) {
          var lat = value['lat'];
          var lng = value['long'];
          var nom = value['Nom'];
          var prenom = value['Prénom'];
          var availability = value['isAvailable'];
          var tokench = value['token'];
          var voiture= value['Modèle'];
          var occupe=value['occupee'];


          // Vérifiez si toutes les valeurs nécessaires sont présentes
          if (lat != null && lng != null && availability == true && occupe== false ) {
            double distance = Geolocator.distanceBetween(
              _currentPosition?.latitude ?? 0.0,
              _currentPosition?.longitude ?? 0.0,
              lat,
              lng,
            );

            double dis = Geolocator.distanceBetween(
              _currentPosition?.latitude ?? 0.0,
              _currentPosition?.longitude ?? 0.0,
              _destinationposition?.latitude ?? 0.0,
              _destinationposition?.longitude ?? 0.0,
            );

            double prix = (distance + dis) / 1000;
            double prixCource = (prix * 900);
            int courcePrice = prixCource.toInt();
         


            nearbyDrivers.add({
              'lat': lat,
              'long': lng,
              'nom': nom,
              'prenom': prenom,
            
              'token': tokench,
              'distance': distance,
              'prix': courcePrice,
              'voiture':voiture
            });
          }
        });

        // Triez les conducteurs par distance
        nearbyDrivers.sort((a, b) => a['distance'].compareTo(b['distance']));

        // Mettez à jour le prix de la course si des conducteurs à proximité sont trouvés
        if (nearbyDrivers.isNotEmpty) {
           
        setState(() {
          this.courcePrice = nearbyDrivers.first['prix'];
        });

         

          // Imprimer le prix de la course une seule fois
          print("Prix de la course: $courcePrice");

          // Mettez à jour le prix dans la base de données Firebase
          FirebaseDatabase.instance
              .ref('user')
              .child(FirebaseAuth.instance.currentUser!.uid)
              .push().set({
            'prix': courcePrice,
          });
            FirebaseDatabase.instance.ref('trajets').child(FirebaseAuth.instance.currentUser!.uid).push().set({
  'date_debut': dateFormat,
  'prix':courcePrice,
  'monthYear':DateTime.now().month, 
  'latitude': placeName,

  'position_arrivee': {
    'latitude': _destinationposition!.latitude,
    'longitude': _destinationposition!.longitude,
  },
  
  // Ajoutez d'autres détails du trajet si nécessaire
});
        } else {
          print("Aucun conducteur trouvé à proximité.");
        }
      } else {
        print("Les données récupérées ne sont pas du type attendu.");
      }
    } catch (error) {
      print("Erreur lors de la récupération des conducteurs: $error");
    }

    return nearbyDrivers;
  }



Future<double> getAverageRating() async {
  List<double> ratings = [];
  DatabaseReference ref = FirebaseDatabase.instance
      .ref('position')
      .child(FirebaseAuth.instance.currentUser!.uid);
  DataSnapshot snapshot = await ref.get();

  if (snapshot.exists) {
    dynamic ratingMap = snapshot.value;

    if (ratingMap is Map) {
      ratingMap.forEach((key, value) {
        if (value != null && value is Map && value['rating'] != null) {
          ratings.add(value['rating'].toDouble());
        }
      });
    }
  }

  // Default value if no ratings
  if (ratings.isNotEmpty) {
    if (ratings.length == 1) {
      average = ratings.first;
    } else {
      double sum = ratings.reduce((a, b) => a + b);
      average = sum / ratings.length;
    }
  }

  print('Ratings list: $ratings'); 
  print('Calculated Average: $average'); 

  return average;
}
Future<void> _getNearbyDrivers() async {
   List<Map<String, dynamic>> result = await findNearbyDrivers();
    setState(() {
       result;
    });
  }

  // ...



String convertToStars(double rating) {
  if (rating == null) return ''; 

  int fullStars = rating.floor();
  bool hasHalfStar = (rating - fullStars) >= 0.5;

  String stars = '★' * fullStars; // Add full stars

  if (hasHalfStar) {
    stars += '½'; // Add a half star
  }

  stars = stars.padRight(5, '☆'); // Pad with empty stars up to 5 stars

  return stars;
}
  





  Future<void> searchPlace() async {
    final apiKey = "AIzaSyC7ckSip1a_oVGM1y7nPSWGUdTEPbkANIA"; // Replace with your own API key

    try {
      Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: apiKey,
        radius: 10000000,
        types: [],
        strictbounds: false,
        mode: Mode.overlay
,        language: "fr",
        
        components: [Component(Component.country, "tn"),
         ],
      );
      
      
      displayPrediction (p! ,homeScaffoldKey.currentState);

      if (p != null) {
        // Handle the selected prediction
        print("Selected: ${p.description}");
        setState(() {
        destinationChosen = true; // Step 2: Set destinationChosen to true
      });
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }
   

  Future displayPrediction (Prediction p, ScaffoldState? currentState) async {
GoogleMapsPlaces places = GoogleMapsPlaces (
apiKey: "AIzaSyC7ckSip1a_oVGM1y7nPSWGUdTEPbkANIA",
apiHeaders: await const GoogleApiHeaders().getHeaders ()
); //GoogleMapsPlaces
PlacesDetailsResponse detail = await places.getDetailsByPlaceId (p.placeId!);
final lat = detail.result.geometry!.location. lat;
final lng = detail.result.geometry!.location. lng;

  _destinationposition=LatLng(lat,lng);
  List<Placemark> placemarks = await placemarkFromCoordinates(_currentPosition!.latitude, _currentPosition!.longitude);
Placemark firstPlacemark = placemarks.first;
String? placeName = firstPlacemark.name;

  String dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
 



markersList.add (Marker (markerId: const MarkerId ("1"), position: LatLng (lat, lng)));

 if (_currentPosition != null) {
  

  getPolyline(_currentPosition!.latitude, _currentPosition!.longitude, lat, lng);

  double  dis =Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, _destinationposition!.latitude, _destinationposition!.longitude)
;
  
  findNearbyDrivers();
  setState(() {
    _loadNearbyDrivers();
  });
 

  
}      

setState (() {

destinationChosen=true;
});
_mapController?.animateCamera (CameraUpdate.newLatLngZoom (LatLng (lat, lng), 14.0));



 }
   Set<Polyline> polylineSet = {};
List<LatLng> polylineCo = [];
PolylinePoints polylinePoints = PolylinePoints();

 Future<void> getPolyline(lat, long, destLat, destLong) async {
  String url =
      "https://maps.googleapis.com/maps/api/directions/json?origin=$lat,$long&destination=$destLat,$destLong&key=$apiKey";
  var response = await http.get(Uri.parse(url));
  var responseBody = jsonDecode(response.body);

  var point = responseBody['routes'][0]['overview_polyline']['points'];
  List<PointLatLng> result = polylinePoints.decodePolyline(point);

  if (result.isNotEmpty) {
    result.forEach((PointLatLng pointLatLng) {
      polylineCo.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
    });
  }

  Polyline polyline = Polyline(
    polylineId: PolylineId("polyline"),
    color: Color(0xff3498db),
    width: 5,
    points: polylineCo,
    
    
  );
  polylineSet.add(polyline);

  // Ajouter le marqueur de durée
  if (polylineCo.length > 1) {
    var durationText =
responseBody['routes'][0]['legs'][0]['duration']['text'];
    Marker durationMarker = Marker(
      markerId: MarkerId("1"),
    position: LatLng(_destinationposition!.latitude, _destinationposition!.longitude),
      infoWindow: InfoWindow(
        title: 'Duration',
        snippet: durationText,
      ),
    );

// Before creating durationMarker
print('Duration Text: $durationText');
         setState(() {
        markersList.add(durationMarker);
        // Mettre à jour la liste des marqueurs sur la carte
        markersList = Set<Marker>.of(markersList);
        polylineSet = Set<Polyline>.of(polylineSet); // Ensure polyline set is updated
      });
    
    setState(() {
          markersList.add(durationMarker);

    });
      setState(() {});


  }
}

 static Future<void>makePayment(int amount,String currency)async{
    try {
      String clientSecret=await _getClientSecret((amount*100).toString(), currency);
      await _initializePaymentSheet(clientSecret);
      await Stripe.instance.presentPaymentSheet();
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  static Future<void>_initializePaymentSheet(String clientSecret)async{
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: "arij",
      ),
    );
  }

  static Future<String> _getClientSecret(String amount,String currency)async{
    Dio dio=Dio();
    var response= await dio.post(
      'https://api.stripe.com/v1/payment_intents',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${ApiKeys.secretkey}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      ),
      data: {
        'amount': amount,
        'currency': currency,
      },
    );
    return response.data["client_secret"];
  }


 }