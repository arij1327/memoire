import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:app/getpointpolyline.dart';
import 'package:app/homepage.dart';
import 'package:app/location_search_screen.dart';
import 'package:app/paymentpaypal.dart';
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
import 'package:googleapis_auth/auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:app/constant.dart';
import 'package:rating_dialog/rating_dialog.dart';






class InterfacePage extends StatefulWidget {
  const InterfacePage({Key? key}) : super(key: key);

  @override
  _InterfacePageState createState() => _InterfacePageState();
}

class _InterfacePageState extends State<InterfacePage> {
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
  double  _slidervalue=20.0;
 int changechauff=0;
   // LatLng? _currentPositionchauff;
   bool selected= false;
    String ?selectedMethodePayment='';
 int? courcePrice;
 List datauser= [];
  
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
 // late Location _locationController;
  

  @override
  void initState() {
     FirebaseMessaging.onMessage.listen((message) {
       if(message.notification!.body == "Le chauffeur a accepté votre course"){
    
    }
  });
  
    //getnotification();
    _determinePosition();
    getDataUser();
   // getDataofUser();
   

    super.initState();
  
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.notification?.body == "Le chauffeur a refusé votre course") {
       setState(() {
          handleDriverRefusal();
       });
      }
    });
    //_locationController = Location();
    /*getLocationUpdates();*/
 
  FirebaseMessaging.onMessage.listen((message) {
    print("refuse");
     if (message.notification!.body=="Le chauffeur a refusé votre course"){

 
       setState(() {
handleDriverRefusal();
       });
    }
   });












  
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.notification?.body == "couce terminé") {
        // showDialog(
        //   context: context,
        //   builder: (context) {
        //     return AlertDialog(
             
        //       content: RatingDialog(
        //         initialRating: 1.0,
        //         title: Text(
        //           'Quel est votre avis sur le service du taxi ',
        //           textAlign: TextAlign.center,
        //           style: const TextStyle(
        //             fontSize: 25,
        //             fontWeight: FontWeight.bold,
        //           ),
        //         ),
        //         message: Text(
        //           'Tap a star to set your rating. Add more description here if you want.',
        //           textAlign: TextAlign.center,
        //           style: const TextStyle(fontSize: 15),
        //         ),
        //         image: const FlutterLogo(size: 100),
        //         submitButtonText: 'Submit',
        //         commentHint: 'Set your custom comment hint',
        //         onCancelled: () => print('cancelled'),
        //         onSubmitted: (response) {
        //           print('rating: ${response.rating}, comment: ${response.comment}');
        //           submitRating(response.rating, response.comment,message.data['identifiant']);
        //         },
        //       ),
        //     );
        //   },
        // );

         Navigator.pushNamed(context, '/payment', arguments: {
                          'id': message.data['identifiant']
                          
                        });
                //  Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentStripe()));

      }
    });

  }
     

Future handleDriverRefusal() async {
  List<Map<String, dynamic>> drivers = await findNearbyDrivers();
print("list initial $drivers");
  setState(() {
    if (currentDriverIndex < drivers.length) {
      drivers.removeAt(currentDriverIndex);
      currentDriverIndex++;
    } else {
      print("No more drivers to remove. Current index: $currentDriverIndex, List length: ${drivers.length}");
    }
    
  });

  print("Updated driver list: $drivers");
  return drivers;
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
          title: Text("Historique", style: TextStyle(fontSize: 18)),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Historique()));
          },
        ),
        ListTile(
          title: Text("Déconnecter", style: TextStyle(fontSize: 18)),
          onTap: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (context) => homepage()));
          },
        ),
      ],
    ),
  ),
  body: Stack(
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
          :LayoutBuilder(
  builder: (BuildContext context, BoxConstraints constraints) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: findNearbyDrivers(),
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
 {
          List<Map<String, dynamic>> nearbyDrivers = snapshot.data ?? [];
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
                          if (index < nearbyDrivers.length) {
                            Map<String, dynamic> driver = nearbyDrivers[index];
                         return ListTile(

                              leading: Image.asset("asset/logotaxi.jpg", width: 80),
                              title: Text(driver['nom']),
                              subtitle: Text('Prix: ${driver['prix']} DT'),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Container(
                                        width: 150,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(18),
                                            topRight: Radius.circular(18),
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
                                        child: AlertDialog(
                                          title: Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                icon: Icon(Icons.arrow_back),
                                              ),
                                              Text("Choisissez votre mode de paiement",
                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                                    selectedMethodePayment = val;
                                                  });
                                                },
                                                title: Text("Espèce"),
                                                subtitle: Text("Payez en espèces au lieu de déposer"),
                                              ),
                                              RadioListTile(
                                                value: "Paypal",
                                                groupValue: selectedMethodePayment,
                                                onChanged: (val) {
                                                  setState(() {
                                                    selectedMethodePayment = val;
                                                  });
                                                },
                                                title: Text("Paypal"),
                                                subtitle: Text("Payez avec Paypal"),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                sendnotification("hello", "notification", driver['token']);
                                                // Mettre à jour l'interface utilisateur après l'envoi de la notification
                                                
                                                Navigator.pop(context);
                                              },
                                              child: Text("Confirmer"),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text('Envoyer Notification'),
                              ),
                            );
                          } else {
                            return null;
                          }
                        },
                        childCount: 1,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  },
),

        ],
      ),
    );
  }
Widget _buildUserList(){
  
  return ListView.builder(
    shrinkWrap: true,
    itemCount:datauser.length ,
    itemBuilder: (context,i){
    return ListTile(
      title: Text(
datauser[i]['Nom']      ),
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

  Future<void> sendnotification(title,messagee,token) async{
 var formattedAddress = await getAdress();
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
   "methode_payment":methodepayment.toString(),
   "prix":courcePrice.toString(),
   //"firstname":firstname

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
return formattedAddress;
}

 
 Future<List<Map<String, dynamic>>> findNearbyDrivers() async {
  var collection = FirebaseDatabase.instance.ref('position');
  var snapshots = await collection.get();
  List<Map<String, dynamic>> nearbyDrivers = [];
  dynamic data = snapshots.value;

  // Vérifiez que data n'est pas null et est bien un Map
  if (data != null && data is Map) {
    for (var entry in data.entries) {
      var value = entry.value;
      var lat = value['lat'];
      var lng = value['long'];
      var gmail = value['email'];
      var availability = value['isAvailable'];
      var tokench = value['token'];
      var nom = value['Nom'];
      var prenom = value['Prénom'];

      if (lat != null && lng != null && availability == true) {
        double distance = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            lat,
            lng);

        double dis = Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            _destinationposition!.latitude,
            _destinationposition!.longitude);

        double prix = (distance + dis) / 1000;
        double prixcource = prix * 900;
        int courcePrice = prixcource.toInt();

        nearbyDrivers.add({
          'driverGmail': gmail,
          'nom': nom,
          'prenom': prenom,
          'prix': courcePrice,
          'token': tokench,
          'distance': distance,
        });



        
      }
    }
  }

  // Tri des conducteurs par distance
  nearbyDrivers.sort((a, b) => a['distance'].compareTo(b['distance']));

  // Mettez à jour le prix de la course en dehors de cette fonction asynchrone
  if (nearbyDrivers.isNotEmpty) {
    setState(() {
      this.courcePrice = nearbyDrivers.first['prix'];
    });
     await FirebaseDatabase.instance.ref('user').child(FirebaseAuth.instance.currentUser!.uid).update({
                                    'prix':courcePrice       
                                           
                                             // Add more f+ields as needed
                                           });
  }
 
  

  print("ggggggggggggggggggggggggggggggggg");

  print(nearbyDrivers);
  print("ggggggggggggggggggggggggggggggggg");

  return nearbyDrivers;}

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

  print('Ratings list: $ratings'); // Debug print to see ratings
  print('Calculated Average: $average'); // Debug print to see the calculated average

  return average;
}

// Future<List<Map<String, dynamic>>> findNearbyDrivers() async {
//   double rate = await getAverageRating();
//   print('Average Rating: $rate'); // Debug print to check the average rating

//   var collection = FirebaseDatabase.instance.ref('position');
//   var snapshots = await collection.get();
//   List<Map<String, dynamic>> nearbyDrivers = [];
//   dynamic data = snapshots.value;

//   if (data != null && data is Map) {
//     print('Data from Firebase: $data'); // Debug print to see the data structure

//     for (var entry in data.entries) {
//       var value = entry.value;
//       var lat = value['lat'];
//       var lng = value['long'];
//       var gmail = value['email'];
//       var availability = value['isAvailable'];
//       var token = value['token'];
//       var nom = value['Nom'];
//       var prenom = value['Prénom'];

//       if (lat != null && lng != null && availability == true) {
//         double distance = Geolocator.distanceBetween(
//           _currentPosition!.latitude,
//           _currentPosition!.longitude,
//           lat,
//           lng,
//         );

//         double dis = Geolocator.distanceBetween(
//           _currentPosition!.latitude,
//           _currentPosition!.longitude,
//           _destinationposition!.latitude,
//           _destinationposition!.longitude,
//         );

//         double prix = (distance + dis) / 1000;
//         double prixCource = prix * 900;
//         int coursePrice = prixCource.toInt();

//         if (rate != null && rate > 2.0) {
//           String ratingStars = convertToStars(rate); // Convert rating to stars
//           nearbyDrivers.add({
//             'nom': nom,
//             'prenom': prenom,
//             'prix': coursePrice,
//             'token': token,
//             'distance': distance,
//             'rate': rate,
//             'ratingStars': ratingStars,
//           });
//         } else {
//           nearbyDrivers.add({
//             'nom': nom,
//             'prenom': prenom,
//             'prix': coursePrice,
//             'token': token,
//             'distance': distance,
//           });
//         }
//       }
//     }
//   } else {
//     print('No driver data found'); // Debug print if no driver data found
//   }

//   // Sort drivers by distance
//   nearbyDrivers.sort((a, b) => a['distance'].compareTo(b['distance']));

//   // Update the price of the course outside this asynchronous function
//   if (nearbyDrivers.isNotEmpty) {
//     setState(() {
//       this.courcePrice = nearbyDrivers.first['prix'];
//     });
//   }

//   return nearbyDrivers;
// }

String convertToStars(double rating) {
  if (rating == null) return ''; // Return empty string if rating is null

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
 
  FirebaseDatabase.instance.ref('trajets').child(FirebaseAuth.instance.currentUser!.uid).push().set({
  'date_debut': dateFormat,
 // 'date_fin': DateTime.now().toIso8601String(),
  'position_depart': {
  'latitude': placeName,
   //'longitude':_currentPosition!.longitude,
  },
  'position_arrivee': {
    'latitude': _destinationposition!.latitude,
    'longitude': _destinationposition!.longitude,
  },
  
  // Ajoutez d'autres détails du trajet si nécessaire
});


markersList.add (Marker (markerId: const MarkerId ("1"), position: LatLng (lat, lng)));

 if (_currentPosition != null) {
  

  getPolyline(_currentPosition!.latitude, _currentPosition!.longitude, lat, lng);

  double  dis =Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, _destinationposition!.latitude, _destinationposition!.longitude)
;
  
  findNearbyDrivers();
 

  print("Current position or radius is null");
  
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
      markerId: MarkerId("durationMarker"),
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

    });
    // Mettre à jour la liste des marqueurs sur la carte
    setState(() {
  markersList = Set<Marker>.of(markersList);
});
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
        merchantDisplayName: "Basel",
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