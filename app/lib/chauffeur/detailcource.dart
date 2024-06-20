import 'dart:convert';
import 'package:app/chauffeur/profilechauffeur.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class detailcource extends StatefulWidget {
  const detailcource({super.key});

  @override
  State<detailcource> createState() => _detailcourceState();
}

class _detailcourceState extends State<detailcource> {
  bool _isOccupe = false;

  @override
  void initState() {
    super.initState();
    fetchAvailability();
    _updateAvailability(true);
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>;
    dynamic address = arguments['adress'];
    dynamic prix = arguments['prix'];
    dynamic token = arguments['token'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Course'),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("asset/detail.jpeg"),
          fit: BoxFit.fill)
          
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$address"),
                Text("$prix"),
                TextButton(
                  onPressed: () {
                    sendNotificationCourse("Chauffeur arrivé", "Chauffeur arrivé", token);
                  },
                  child: Text("Je suis arrivé"),
                ),
                TextButton(
                  onPressed: () {
                    sendNotificationCourse("Course terminé", "Course terminé", token);
                      _updateAvailability(false);
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>DriverProfilePage()));
                  },
                  child: Text("Course terminé"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> sendNotificationCourse(String title, String message, String token) async {
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
        "body": message,
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

  Future<void> _updateAvailability(bool occupee) async {
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

  Future<void> fetchAvailability() async {
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
