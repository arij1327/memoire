import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isAvailable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: Text('Chauffeur Profile'),
        
        actions: [Switch(
              value: _isAvailable,
              onChanged: (newValue) {
                setState(() {
                  _isAvailable = newValue;
                  _updateAvailability(newValue);
                });
              },
              activeColor: Colors.blue,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[300],
            )],
   
      ),
     
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            SizedBox(height: 20.0),
           
          ],
        ),
      ),
    );
  }
  

  void _updateAvailability(bool isAvailable) async {
  // Simulating user authentication, you should replace this with your actual user ID
  var currentUser = await FirebaseAuth.instance.currentUser;
  String userId = await  currentUser!.uid;
  print( "===================current user ==========================${userId}");
  // Reference to the document in Firestore
  DocumentReference docRef =
      FirebaseFirestore.instance.collection('position').doc(userId);

  try {
    // Check if the document exists
    DocumentSnapshot docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      // If the document exists, update it
      await docRef.update({'isAvailable': isAvailable});
      print("User availability updated successfully!");
    } else {
      // If the document doesn't exist, create it
      await docRef.set({'isAvailable': isAvailable});
      print("New document created with availability!");
    }
  } catch (error) {
    print("Failed to update user availability: $error");
  }
}


  @override
  void initState() {
    super.initState();
    _fetchAvailability();
  }

  void _fetchAvailability() async {
  // Simulating user authentication, you should replace this with your actual user ID
    var currentUser = await FirebaseAuth.instance.currentUser;
  String userId = await  currentUser!.uid;

  // Fetch availability status from Firestore
  try {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('users')  // Correct collection name here
        .doc(userId)
        .get();

    if (documentSnapshot.exists) {
         setState(() {
_isAvailable = documentSnapshot.exists ? 
    ((documentSnapshot.data() as Map<String, dynamic>)?['isAvailable'] ?? false) 
    : false;




        });
    } else {
      print('Document does not exist on the database');
    }
  } catch (error) {
    print('Failed to get document: $error');
  }
}

}
