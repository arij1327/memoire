/*import 'dart:io';

import 'package:app/authentification/login.dart';
import 'package:app/authentification/sign_in.dart';
import 'package:app/chauffeur/profilechauffeur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:path/path.dart';


class Chauff extends StatefulWidget {
  const Chauff({Key? key}) : super(key: key);

  @override
  State<Chauff> createState() => _ChauffState();
}

class _ChauffState extends State<Chauff> {
  Country selectedCountry = Country(
phoneCode: "216", 
countryCode: "TN",
e164Sc: 0,
geographic: true,
level: 1,
name: "tunisia",
example: "tunisia",
displayName: "tunisia",
displayNameNoCountryCode: "TN",
e164Key: "",
);
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
  File? _image;
  String ? url;
   getimage()async{
    final  ImagePicker picker = ImagePicker();
    final XFile?  image = await picker.pickImage(source:ImageSource.gallery);
     
     
     
      if (image != null) {
        _image = File(image.path);
        var imagename= basename(image!.path);
        var refstorage =  FirebaseStorage.instance.ref(imagename);
         
         await refstorage.putFile(_image!);
          url= await refstorage.getDownloadURL();
      } else {
        print('No image selected.');
      }
    
    
     setState(() {
    
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
     
       drawer: Drawer(
        child: Column(
          children: [
            ListTile(
              title: Text("Profile Chauffeur"),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>UserProfilePage()));
              },
              
            ),
            ListTile(
              title: Text("Se déconnecter"),
              subtitle: Icon(Icons.exit_to_app),
              onTap: (){
              
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      
              },
              
            ),
          ],
        ),
        
        
      ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(onTap: () {
                      getimage();
                    },
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        backgroundImage: url!=null?FileImage(_image!):null,
                        child: _image==null?Icon(Icons.camera_alt,size: 40,color: Colors.grey[400],):null
                      ),
                    ),
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
                        checkExistingTaxiNumber();

                    }
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
                 TextFormField(
                      controller: usernumController,
                      
                      decoration: InputDecoration(
                        prefixIcon: Container(
                          padding: EdgeInsets.all(8.0),
                          child: InkWell(onTap: () {
                            showCountryPicker(context: context, onSelect: (value){
                              setState(() {
                                selectedCountry = value;
                              });
                            });
                            
                          },
                          child: Text("${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",style:TextStyle(fontSize:20),),
                        ),),
                        labelText: 'Num',
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
 

 void checkExistingTaxiNumber() {
  String taxiNumber = usernumController.text;

  FirebaseFirestore.instance
      .collection('chauffeur')
      .where('Numéro du taxi', isEqualTo: taxiNumber)
      .get()
      .then((QuerySnapshot querySnapshot) {
    if (querySnapshot.docs.isNotEmpty) {
      // Le numéro de taxi existe déjà
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(
          content: Text("Numéro du taxi existe déjà"),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Le numéro de taxi n'existe pas encore
      print("Numéro du taxi n'existe pas");
    }
  }).catchError((error) {
    print("Erreur lors de la recherche du numéro de taxi: $error");
  });
}
  Future<void> addUser() async {

  

      
       await FirebaseFirestore.instance.collection('chauffeur').doc(FirebaseAuth.instance.currentUser!.uid).set({
   'Nom': usernomController.text,
      'Prénom': userpreController.text,
      'Numéro du taxi': usernumController.text,
      'Matricule': usermatController.text,
      'Modèle': choosevalue,
      'image':url
       

      // Add more fields as needed
    });
      print("User Added");
  
}



}


*/