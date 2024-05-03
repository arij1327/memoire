import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:app/getpointpolyline.dart';
import 'package:app/location_search_screen.dart';
import 'package:app/user/profileuser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_address_from_latlng/flutter_address_from_latlng.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:app/constant.dart';






class InterfacePage extends StatefulWidget {
  const InterfacePage({Key? key}) : super(key: key);

  @override
  _InterfacePageState createState() => _InterfacePageState();
}

class _InterfacePageState extends State<InterfacePage> {



 
double searchwidth=400;
 
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
   int currentDriverIndex = 0;

bool destinationChosen = false; 
  LatLng? l;
  LatLng? _currentPositionchauff;
  final double radiusInKm = 0.1;
  double  _slidervalue=20.0;
 int changechauff=0;
   // LatLng? _currentPositionchauff;
   bool selected= false;
    int selectedMethodePayment = 1;

  
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
 // late Location _locationController;
  

  @override
  void initState() {
  
    //getnotification();
    _determinePosition();

    super.initState();
  
    
    //_locationController = Location();
    /*getLocationUpdates();*/
 
  FirebaseMessaging.onMessage.listen((message) {
    print("refuse");
     if (message.notification!.body=="Le chauffeur a refusé votre course"){

 
       setState(() {
                  currentDriverIndex = currentDriverIndex+1;

       });
    }
   });
   FirebaseMessaging.onMessageOpenedApp.listen((message) { 
    
    if (message.notification!.body=="Le chauffeur a refusé votre course"){
        
        setState(() {
                   currentDriverIndex = currentDriverIndex+1;

        });
      
    }
 
    
  });
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
       if(message.notification!.body=="Le chauffeur a accepté votre course"){
      showDialog(context: context, builder: (context){
        return Container(
          
          child: AlertDialog(
            title: Text("Chisissez votre payment"),
            content: Column(
              children: [
            RadioListTile(value: 1, groupValue: selectedMethodePayment, onChanged: (val){
              setState(() {
                selectedMethodePayment = val!;
              });
            },
            title: Text("Espèce"),
            subtitle: Text("Payez en espèces au lieu de déspose"),
              
              
             
            ),
            RadioListTile(value: 2, groupValue: selectedMethodePayment, onChanged: (val){
              setState(() {
                selectedMethodePayment = val!;
              });
            },
            title: Text("Paypal"),
            subtitle: Text("Payez avec Paypal"),)
              ],
            ),
            actions: [TextButton(onPressed: (){
          
            }, child: Text("Confirmer"))],),
        );
          
      }
      );
    }
  });
    FirebaseMessaging.onMessage.listen((message) {
       if(message.notification!.body=="Le chauffeur a accepté votre course"){
      showDialog(context: context, builder: (context){
        return Container(
          
          child: AlertDialog(
            title: Text("Chisissez votre payment"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            RadioListTile(value: 1, groupValue: selectedMethodePayment, onChanged: (val){
              setState(() {
                selectedMethodePayment=val!;
              });
            },
            title: Text("Espèce"),
            subtitle: Text("Payez en espèces au lieu de déspose"),
              
              
             
            ),
            RadioListTile(value: 2, groupValue: selectedMethodePayment, onChanged: (val){
              setState(() {
                selectedMethodePayment=val!;
              });
            },
            title: Text("Paypal"),
            subtitle: Text("Payez avec Paypal"),)
              ],
            ),
            actions: [TextButton(onPressed: (){
              if(selectedMethodePayment==2){

              }
          
            }, child: Text("Confirmer"))],),
        );
          
      }
      );
    }
  });
  
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
      
      drawer: Drawer( child:Column(children: [ ListTile(
        leading: CircleAvatar(
          child: Icon(Icons.person),
        ),
          title: Text("Votre Profile ",style: TextStyle(fontSize: 18),),

          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileUser()));

          },
          
        ), ListTile(
          title: Text("Historique",style: TextStyle(fontSize: 18),),
          onTap: (){
          },
          
        )],),),
      body: Stack(
        children: [
 GoogleMap(
              
              markers:  markersList,
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
            
            
             GestureDetector(
               onTap:(){
        if(!draweropen){
          homeScaffoldKey.currentState!.openDrawer();     
        }  else{
          setState(() {
            polylineSet.clear();
            markersList.clear();
      
        destinationChosen = !destinationChosen;
        
      });
      
        }        } ,
               child: Positioned(
                  top: 0,
                  left: 30,
                  bottom: 11,
                  
                  child: Container(
                    
                    decoration:BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(22.0),
                    boxShadow: [
                      BoxShadow(color: Colors.black,blurRadius: 6.0,spreadRadius: 0.5,offset: Offset(0.7, 0.7))
                    ]),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon((!destinationChosen)?Icons.menu:
                      Icons.close,),
                 
                      
                    ),
                    
                  ),
                ),
             ),
            

            (!destinationChosen)?
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 160),
                child: Container(
                  width: 400,
                 
                  decoration: BoxDecoration(
                    color:  Colors.white,
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
                    padding: EdgeInsets.symmetric(vertical: 18.0, horizontal:24 ),
           child: 
                        TextField(
                          controller: destinationController,
                          onTap: () async {
                       searchPlace();
                          },
                          decoration: InputDecoration(
                            hintText: 'Enter destination',
                            suffixIcon: Icon(Icons.search),
                          ),
                        )
                        
                       
                  ))))
                    
              

          :
LayoutBuilder(
  builder: (BuildContext context, BoxConstraints constraints) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: findNearbyDrivers(),
      builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
       
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
    (BuildContext context, int currentDriverIndex) {
      if (currentDriverIndex < nearbyDrivers.length) {
        Map<String, dynamic> driver = nearbyDrivers[currentDriverIndex];
        return ListTile(
          leading: Image.asset("asset/logotaxi.jpg",width: 80,),
          title: Text(driver['driverGmail']),
          subtitle: Text('Prix: ${driver['prix']} DT'),
          trailing: ElevatedButton(
            onPressed: () {
              sendnotification("hello", "notification", driver['token']);
            },
            child: Text('Confirmer'),
          ),
        );
      } else {
        return null; // Return null if index exceeds the length of nearbyDrivers
      }
    },
    // Set childCount to the length of nearbyDrivers
    childCount: 1,
  ),
),

                   
                  ],
                ),
              );
            },
          );
        }
        

    );
  },
),

      
         ] ),
    
  
          
        
      );
  

          
           
        
             
         
        
   
        
      
    
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
   "adress": formattedAddress

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
  List<Map<String,dynamic>> nearbyDrivers = [];
  dynamic data = snapshots.value;

  data.forEach((key, value) async {
  var lat = value['lat']; 
  var lng = value['long'];
  var gmail = value['email'];
  var availibility = value["isAvailable"];
  var tokench = value['token']; 
  var nom= value['Nom'];
  var prenom= value['Prénom'];

  if (lat != null && lng != null) {
    double distance = Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, lat, lng);
    print("8888888888888888888888888888888888888888");
  print(distance);
      print("8888888888888888888888888888888888888888");
    double  dis =Geolocator.distanceBetween(_currentPosition!.latitude, _currentPosition!.longitude, _destinationposition!.latitude, _destinationposition!.longitude);
 double prix= (distance+dis)/1000;
 double prixcource =prix*900;
 int courceprice=prixcource.toInt();
    nearbyDrivers.add({
      'driverGmail': nom ,
      'prix':courceprice,
      'token':tokench
   

});
nearbyDrivers.sort((a, b)=> a['distance'].compareTo(b['distance']));




  
  

 

  
   

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
        mode: Mode.overlay
,        language: "fr",
        
        components: [Component(Component.country, "tn")],
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
    
      infoWindow: InfoWindow(
        title: 'Duration',
        snippet: durationText,
      ),
    );

// Before creating durationMarker
print('Duration Text: $durationText');
;
    // Ajouter le marqueur à la liste des marqueurs
    // Mettre à jour la liste des marqueurs sur la carte
   /* setState(() {
    markersList = Set<Marker>.of(markersList);
    });*/
    setState(() {
          markersList.add(durationMarker);

    });
  }
}


 }
