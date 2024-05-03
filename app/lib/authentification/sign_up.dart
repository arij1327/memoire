

import 'package:app/authentification/login.dart';
import 'package:app/chauffeur/profilechauffeur.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

class signuppage extends StatefulWidget {
  const signuppage({super.key});

  @override
  State<signuppage> createState() => _signuppageState();
}

class _signuppageState extends State<signuppage> {
  Future<void> addUser() async {

  

      
       await FirebaseDatabase.instance.ref('position').child(FirebaseAuth.instance.currentUser!.uid).update({
   'Nom': _userController.text.toString(),
      'Prénom': _prenomController.text.toString(),
      'Numéro du taxi': usernumController.text.toString(),
      'Matricule': usermatController.text.toString(),
      'Modèle': choosevalue.toString(),
     // 'image':url
       

      // Add more fields as needed
    });
      print("User Added");
  
}
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
   bool _isSigningIn = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    TextEditingController _userController = TextEditingController();
        TextEditingController _prenomController = TextEditingController();


  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmpasswordController = TextEditingController();
   final TextEditingController usernumController = TextEditingController();
      final TextEditingController userphoneController = TextEditingController();


  final TextEditingController usermatController = TextEditingController();
  final TextEditingController usertypController = TextEditingController();
  bool ischecked= false;
   String? choosevalue;
  final List<String> models = ["Fiat", "Ford", "Hyundai", "KIA", "Peugeot", "Renault"];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
 Future checkTaxiNumberExists(String taxiNumber) async {
  try {
    // Get a reference to the 'chauffeur' collection
    DatabaseReference reff = FirebaseDatabase.instance.ref().child('chauffeur');
    
    // Query the database to check if the taxi number exists
    DatabaseEvent snapshot = await reff.orderByChild('Numéro du taxi').equalTo(taxiNumber).once();
DataSnapshot dataSnapshot = snapshot.snapshot;
    // Check if the snapshot contains any data
    if (dataSnapshot.exists) {
      // Taxi number exists
       return 'Ce numéro de taxi existe déjà.';
    } else {
      // Taxi number does not exist
        return 'valid';
    }
  } catch (e) {
    // Handle any errors
    print('Error checking taxi number: $e');
    return false; // Assuming no taxi number exists if there's an error
  }
}
 /* Future<void> checkTaxiNumber(String taxiNumber) async {
  DatabaseReference ref = FirebaseDatabase.instance.reference().child("chauffeur");

  // Recherche dans la base de données pour vérifier si le numéro de taxi existe
  ref.orderByChild("taxi_number").equalTo(taxiNumber).once().then((DataSnapshot snapshot) {
    if (snapshot.value != null) {
      // Le numéro de taxi existe
      setState(() {
        taxiNumberExists = true;
      });
    } else {
      // Le numéro de taxi n'existe pas
      setState(() {
        taxiNumberExists = false;
      });
    }
  }).catchError((error) {
    print("Error checking taxi number: $error");
  });
}*/

// Utili

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        
        child: ListView(
          
          children: [
           
            Column(mainAxisAlignment: MainAxisAlignment.center,
            
              children: [
                Padding(padding: EdgeInsets.only(top :30)),
                 Row(children: [Image.asset("asset/logo.png",height: 50,), SizedBox(width: 250,),IconButton(onPressed: (){}, icon: Icon(Icons.close),)],),
                Text("S'inscrire",style: TextStyle(fontSize:40 ),),
                Padding(padding:EdgeInsets.all(20)),
                Row(children: [Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                                  labelText: 'Prenom',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                    controller: _userController,
                  ),
                ),SizedBox(width: 12,),Expanded(
                  child: TextField(
                    controller: _prenomController,
                   decoration: InputDecoration(
                                  labelText: 'Nom',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                  ),
                )],),Padding(padding:EdgeInsets.all(8)),
                TextFormField(
                /*  validator: (email) {
                       String pattern =
                                  r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                              RegExp regex = RegExp(pattern);
                              if (email!.isEmpty) {
                                return 'Ce champ est obligatoire';
                              }
                              if (!regex.hasMatch(email)) {
                                return 'S"il vous plaît, mettez une adresse email valide';
                              } else {
                                return null;
                              }
                  },*/
                  controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Adress Email',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              
                ),
                Padding(padding:EdgeInsets.all(8)),
                 TextFormField(
                  /*  validator: (password) {
                              if (password == null || password.isEmpty) {
                                return 'Veuillez entrer un mot de passe.';
                              }

                              // Vérifier la longueur du mot de passe
                              if (password.length < 6) {
                                return 'Le mot de passe doit contenir au moin 6 caractères.';
                              }

                              // Vérifier la présence d'au moins une minuscule
                              if (!password.contains(RegExp(r'[a-z]'))) {
                                return 'Le mot de passe doit contenir au moins une lettre minuscule.';
                              }

                              // Vérifier la présence d'au moins une majuscule
                              if (!password.contains(RegExp(r'[A-Z]'))) {
                                return 'Le mot de passe doit contenir au moins une lettre majuscule.';
                              }

                              // Vérifier la présence d'au moins un chiffre
                              if (!password.contains(RegExp(r'[0-9]'))) {
                                return 'Le mot de passe doit contenir au moins un chiffre.';
                              }

                              // Vérifier la présence d'au moins un caractère spécial
                              if (!password.contains(
                                  RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                                return 'Le mot de passe doit contenir au moins un caractère spécial.';
                              }

                              return null;
                            },*/
                  controller: _passwordController,
                  obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                 ),
                 Padding(padding:EdgeInsets.all(8)),
                 TextFormField(
                  validator: (value) {
                    if (_passwordController.text!=_confirmpasswordController.text)return "verifier votre password";
                     return null;
                  },
                  controller: _confirmpasswordController,
                  obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Confirmz le Mot de passe',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                 ),
                    Padding(padding:EdgeInsets.all(8)),
                 TextFormField(
                  onFieldSubmitted: (value)async {
        checkTaxiNumberExists(value);
                  },keyboardType: TextInputType.number,
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
                      
                    ),
                       Padding(padding:EdgeInsets.all(8)),
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
                  keyboardType: TextInputType.number,
                      controller: userphoneController,
                      
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
                
            
                ElevatedButton(onPressed: ()async{try {
              final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text,
                
            
              );
              
                                            
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
            } on FirebaseAuthException catch (e) {
              if (e.code == 'weak-password') {
                print('The password provided is too weak.');
                 ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("The password provided is too weak."),
                  duration: Duration(seconds: 2),
                ),
              );
              } else if (e.code == 'email-already-in-use') {
                print('The account already exists for that email.');
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("the account already exists for that email"),
                  duration: Duration(seconds: 2),
                ),
              );
              }
            } catch (e) {
              print(e);
            }
            addUser();
            
                }, child: Text("Sinscrire")),
                 const SizedBox(height:230),
               Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account?"),
                              SizedBox(width: 5),
                              GestureDetector(
                                onTap: () {
                                 Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => LoginPage()),
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  "Enregistrer",
                                  style: TextStyle(
                                    color:Color(0xFF53bcbd),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ), 
              ],
              
            ),
            
          ],
          
        ),
        
      ),
    );
  }
 }