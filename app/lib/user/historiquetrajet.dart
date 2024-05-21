import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geocoding/geocoding.dart';


class Historique extends StatefulWidget {
  const Historique({super.key});

  @override
  State<Historique> createState() => _HistoriqueState();
}

class _HistoriqueState extends State<Historique> {
  List datatrajet =[];
  
   DatabaseReference _databaseReference = FirebaseDatabase.instance.ref().child('trajets').child(FirebaseAuth.instance.currentUser!.uid);

void initState(){
  super.initState();
  gettrajet();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Historique de votre trajet"),
      ),
      body: StreamBuilder(
      stream: _databaseReference.onValue,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Loading...');
        }
       
      


        return ListView.builder(
          itemCount: datatrajet.length,
          itemBuilder: (context, index) {
            
          if(index<datatrajet.length){
              return ListTile(
                leading: Icon(Icons.taxi_alert),
              title: Text(datatrajet[index]['position_depart'].toString()),
              subtitle: Text(datatrajet[index]['date_debut'].toString()),
            );
          }
          },
        );
      },
    ));
  }
  Future<void> gettrajet() async {
  DatabaseReference ref = FirebaseDatabase.instance.reference().child("trajets").child(FirebaseAuth.instance.currentUser!.uid);

  // Fetch data once
  DataSnapshot snapshot = await ref.get();

  if (snapshot.value != null) {
    // Data exists, add it to your list or use it as needed
    dynamic data1 = snapshot.value;
datatrajet=data1.values.toList(); 

    setState(() {
      // Update the UI with the retrieved data if necessary
    });
  } else {
    print("Document does not exist");
  }
}
    
    
    
    
    
    
}
