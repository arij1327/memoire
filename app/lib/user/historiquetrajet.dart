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
  List<Map<dynamic, dynamic>> datatrajet = [];
  DatabaseReference _databaseReference =
      FirebaseDatabase.instance.ref().child('trajets').child(FirebaseAuth.instance.currentUser!.uid);

  @override
  void initState() {
    super.initState();
    gettrajet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('asset/historique.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: Text("Historique de votre trajet"),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: _databaseReference.onValue,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return ListView.builder(
                      itemCount: datatrajet.length,
                      itemBuilder: (context, index) {
                        final trajet = datatrajet[index];
                        final latitude = trajet['latitude']?.toString() ?? '';
                        final dateDebut = trajet['date_debut']?.toString() ?? '';
                        final prix = trajet['prix']?.toString() ?? '';
                        return ListTile(
                          leading: Icon(Icons.taxi_alert),
                          title: Text(latitude),
                          subtitle: Text(dateDebut),
                          trailing: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 80),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(prix, overflow: TextOverflow.ellipsis),
                                ),
                                SizedBox(width: 4),
                                Text("TND"),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> gettrajet() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("trajets").child(FirebaseAuth.instance.currentUser!.uid);
    // Fetch data once
    DataSnapshot snapshot = await ref.get();
    if (snapshot.value != null) {
      // Data exists, add it to your list or use it as needed
      dynamic data1 = snapshot.value;
      setState(() {
        datatrajet = List<Map<dynamic, dynamic>>.from(
          data1.values.whereType<Map<dynamic, dynamic>>(),
        );
      });
    } else {
      print("Document does not exist");
    }
  }
}
