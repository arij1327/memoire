import 'package:app/authentification/login.dart';
import 'package:app/authentification/sign_in.dart';
import 'package:app/connectivity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Chauff extends StatefulWidget {
  const Chauff({Key? key}) : super(key: key);

  @override
  State<Chauff> createState() => _ChauffState();
}

class _ChauffState extends State<Chauff> {
  final TextEditingController usernomController = TextEditingController();
  final TextEditingController userpreController = TextEditingController();
  final TextEditingController usernumController = TextEditingController();
  final TextEditingController usermatController = TextEditingController();
  final TextEditingController usertypController = TextEditingController();
  late DatabaseReference dbRef;
    CollectionReference chauf = FirebaseFirestore.instance.collection('chauffeur');


  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('Chauffeur');


  }

  @override
  void dispose() {
    usernomController.dispose();
    userpreController.dispose();
    usernumController.dispose();
    usermatController.dispose();
    usertypController.dispose();
    super.dispose();
  }

  String? choosevalue;
  final List<String> models = ["Fiat", "Ford", "Hyundai", "KIA", "Peugeot", "Renault"];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(actions: [ElevatedButton(onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>signuppage()));

      }, child: Text("login"))],),
       drawer: Drawer(
        child: ListTile(
          title: Text("Profile Chauffeur"),
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>UserProfilePage()));
          },
        ),
        
        
      ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: usernomController,
                      decoration: InputDecoration(
                        labelText: 'Nom',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: userpreController,
                      decoration: InputDecoration(
                        labelText: 'Prénom',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: usernumController,
                      decoration: InputDecoration(
                        labelText: 'Numéro du Taxi',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 179, 197, 77),
                          ),
                        ),
                      ),
                      onTap: () {
                        String key = usernumController.text;

  dbRef.child(key).onValue.listen((event) {
if (event.snapshot.exists && key.isNotEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Numéro du taxi existe déjà"),
            duration: Duration(seconds: 2),
          ),
        );
      }else {
      print("Numéro du taxi n'existe pas");
    }
  
  });}
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: usermatController,
                      decoration: InputDecoration(
                        labelText: 'Matricule',
                        labelStyle: TextStyle(color: Colors.black),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: choosevalue ?? models.first,
                      onChanged: (newValue) {
                        setState(() {
                          choosevalue = newValue;
                        });
                      },
                      items: models.map((valueItem) {
                        return DropdownMenuItem<String>(
                          child: Text(valueItem),
                          value: valueItem,
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: () {

                 addUser();
  /*  Map<String, dynamic> chauffeur = {
      'Nom': usernomController.text,
      'Prénom': userpreController.text,
      'Numéro du taxi': usernumController.text,
      'Matricule': usermatController.text,
      'Modèle': choosevalue
    };
    dbRef.push().set(chauffeur);
    */
                      },
                      style: ElevatedButton.styleFrom(
                
                      ),
                      child: Text('Enregistrer'),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
  Future<void> addUser() async {

  

      
      await chauf.add({
         'Nom': usernomController.text,
      'Prénom': userpreController.text,
      'Numéro du taxi': usernumController.text,
      'Matricule': usermatController.text,
      'Modèle': choosevalue
       
       
       

      });
      print("User Added");
  
}

  void checkExistingTaxiNumber() {
          String key = usernumController.text;

  dbRef.child(key).onValue.listen((event) {
    if (event.snapshot.exists && key.isNotEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Numéro du taxi existe déjà"),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      print("Numéro du taxi n'existe pas");
    }
  
  }

                     );
    
  }

}

class ChauffImage extends StatelessWidget {
  const ChauffImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("asset/chauff.jpeg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
