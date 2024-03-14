import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;




class InterfacePage extends StatefulWidget {
  const InterfacePage({Key? key}) : super(key: key);

  @override
  _InterfacePageState createState() => _InterfacePageState();
}

class _InterfacePageState extends State<InterfacePage> {

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
 
  
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    markersList.add (Marker (markerId: const MarkerId ("0"), position: LatLng (_currentPosition!.latitude,_currentPosition!.longitude)));

    print(_currentPosition);
        
}

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
Set<Marker> markersList = {
  
};

  static const LatLng _initialPosition = LatLng(37.7749, -122.4194);
  final TextEditingController destinationController = TextEditingController();
  GoogleMapController? _mapController;
  static const LatLng sourceLocation = LatLng(37.33500926, -122.03272188);
  LatLng? _currentPosition;
  LatLng? l;
  LatLng? _currentPositionchauff;
  final double radiusInKm = 0.1;
   // LatLng? _currentPositionchauff;
   

  
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
 // late Location _locationController;
  

  @override
  void initState() {
    _determinePosition();
    //getnotification();

    super.initState();
    
    //_locationController = Location();
    /*getLocationUpdates();*/
    
  }

  @override
  void dispose() {
   // _locationController.dispose(); // Dispose location controller
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key:homeScaffoldKey,
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              markers:  markersList,
              
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
          ),
  
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: destinationController,
              onTap: () async {
                // Navigate to search location screen
                searchPlace();
               
              },
              decoration: InputDecoration(
                hintText: 'Enter destination',
              ),
            ),
            
          ),
        
       ]));
        
      
    
  }
    void _requestPermissions() {
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
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
    "body":messagee 
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

 findNearbyDrivers(double userLatitude, double userLongitude, double radiusInKm) async {
  var collection = FirebaseFirestore.instance.collection('position');
  var snapshots = await collection.get();
  List<Map<String,dynamic>> nearbyDrivers = [];

  snapshots.docs.forEach((doc) {
    var lat = doc.data()['latitude']; // Access fields directly from doc
    var lng = doc.data()['longitude'];
    var gmail=doc.data()['gmail'];
    var tokench=doc.data()["token"];

  if (lat != null && lng != null) {
    double distance = Geolocator.distanceBetween(userLatitude, userLongitude, lat, lng);
    print("8888888888888888888888888888888888888888");
  print(distance);
      print("8888888888888888888888888888888888888888");
      
    nearbyDrivers.add({
      'driverGmail': gmail ,
      'distance': distance,
      'token':tokench

});
 double minDistance = double.infinity;

var min =nearbyDrivers.reduce((value, element) => minDistance < value['distance'] ? value : element );
if(distance<minDistance){
 sendnotification("your notification","hello",tokench);
}

  

 
print("22222222222222222222222222222222");
print(min);

print("22222222222222222222222222222222");
  
    

  }
 });
  




  print("5555555555555555555555555555555555555555");
  print(nearbyDrivers);
  
    print("5555555555555555555555555555555555555555");

  return nearbyDrivers!; 
    
 
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
        mode: Mode.overlay,
        language: "fr",
        decoration: InputDecoration(
          hintText: 'Search',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.white,
            ),
          ),
        ),
        components: [Component(Component.country, "tn")],
      );
      displayPrediction (p! ,homeScaffoldKey.currentState);

      if (p != null) {
        // Handle the selected prediction
        print("Selected: ${p.description}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  Future<void> displayPrediction (Prediction p, ScaffoldState? currentState) async {
GoogleMapsPlaces places = GoogleMapsPlaces (
apiKey: "AIzaSyC7ckSip1a_oVGM1y7nPSWGUdTEPbkANIA",
apiHeaders: await const GoogleApiHeaders().getHeaders ()
); //GoogleMapsPlaces
PlacesDetailsResponse detail = await places.getDetailsByPlaceId (p.placeId!);
final lat = detail.result.geometry!.location. lat;
final lng = detail.result.geometry!.location. lng;
markersList.clear();
markersList.add (Marker (markerId: const MarkerId ("0"), position: LatLng (lat, lng)));
 if (_currentPosition != null) {findNearbyDrivers(_currentPosition!.latitude, _currentPosition!.longitude, radiusInKm)
;
  print("Current position or radius is null");
}      

setState (() {});
_mapController?.animateCamera (CameraUpdate.newLatLngZoom (LatLng (lat, lng), 14.0));
 }

}

