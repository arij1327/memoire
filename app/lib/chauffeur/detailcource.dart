import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class detailcource extends StatefulWidget {
  const detailcource({super.key});

  @override
  State<detailcource> createState() => _detailcourceState();
}

class _detailcourceState extends State<detailcource> {
  @override
  Widget build(BuildContext context) {
      final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>;
    dynamic adress=arguments['adress'];
    dynamic payment=arguments['payment'];
     dynamic prix=arguments['prix'];
     dynamic token=arguments['token'];
     dynamic firstname=arguments['firstname'];

    return Scaffold(
      body: Column(
        children: [
Text("$firstname"),
          Text("$adress"),
          Text("$payment"),
          Text("$prix"),
              
         TextButton(onPressed: (){
                                      

                  sendnotificationcource("Chauffeur arrivé", "Chauffeur arrivé", token);
                }, child: Text("Chauffeur arrivé")),

         TextButton(onPressed: (){
                                      

                  sendnotificationcource("couce terminé", "couce terminé", token);
                }, child: Text("cource terminé")),
                
        ],
      ),
    );
  }
   Future<void> sendnotificationcource(title,messagee,token) async{
 
  
  

  
  
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
}