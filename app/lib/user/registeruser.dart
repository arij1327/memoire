import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'loginuser.dart'; // Importez le fichier contenant la page de connexion utilisateur

Future<String> checkTaxiNumberExists(String taxiNumber) async {
    try {
      DatabaseReference reff = FirebaseDatabase.instance.ref('position');
      Query queryRef = reff.orderByChild('Numéro du taxi').equalTo(taxiNumber);
      DatabaseEvent event = await queryRef.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists) {
        return 'Ce numéro de taxi existe déjà.';
      } else {
        return 'valide';
      }
    } catch (e) {
      print('Erreur lors de la vérification du numéro de taxi: $e');
      return 'erreur';
    }
  }

  // Fonction de validateur personnalisé pour le TextFormField
  String? validateTaxiNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer un numéro de taxi';
    }
    }

class SignupUserPage extends StatefulWidget {
  const SignupUserPage({Key? key}) : super(key: key);

  @override
  State<SignupUserPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupUserPage> {
  // Déclarations des variables et contrôleurs de texte
  TextEditingController _prenomController = TextEditingController();
  TextEditingController _userController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmpasswordController = TextEditingController();
  TextEditingController usernumController = TextEditingController();
  TextEditingController userphoneController = TextEditingController();
  TextEditingController usermatController = TextEditingController();
  final List<String> models = ["Fiat", "Ford", "Hyundai", "KIA", "Peugeot", "Renault"];
  String? choosevalue;
  String? choosevalue1;

 Future<String> checkTaxiNumberExists(String taxiNumber) async {
  print("check taxi");
  try {
    DatabaseReference reff = FirebaseDatabase.instance.ref().child('position');

    Query queryRef = reff.orderByChild('Numéro du taxi').equalTo(taxiNumber);

    DatabaseEvent event = await queryRef.once();

    DataSnapshot snapshot = event.snapshot;

    if (snapshot.exists) {
      print("exist");
      print("Snapshot value: ${snapshot.value}");
      return 'Ce numéro de taxi existe déjà.';
    } else {
      print("non");
      return 'valid';
    }
  } catch (e) {
    print('Error checking taxi number: $e');
    return 'error';
  }
}
  

    // Appel de la fonction checkTaxiNumberExists pour vérifier si le numéro de taxi existe déjà

  
     Future<void> addUser() async {

  

      
        await FirebaseDatabase.instance.ref('position').child(FirebaseAuth.instance.currentUser!.uid).update({
       'Prénom': _prenomController.text.toString(),
       'Numéro du taxi': usernumController.text.toString(),
       'Matricule': usermatController.text.toString(),
       'Modèle': choosevalue1.toString(),

       

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
    name: "Tunisia",
    example: "Tunisia",
    displayName: "Tunisia",
    displayNameNoCountryCode: "TN",
    e164Key: "",
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
         Container(decoration: BoxDecoration(
    image: DecorationImage(image: AssetImage("asset/registrer.jpeg"),fit: BoxFit.fill)
  ),),
        Scaffold(
              backgroundColor: Colors.transparent,

          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(45.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Padding(padding: EdgeInsets.only(top :30)),
                  // Ajout des champs pour le prénom et le nom
                Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _prenomController,
                          decoration: InputDecoration(
                            labelText: 'Prénom',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _userController,
                          decoration: InputDecoration(
                            labelText: 'Nom',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                                    SizedBox(height: 12,),

                  // Ajout du champ pour l'adresse email
                  TextFormField(
                        validator: (email) {
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
                  },
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Adresse Email',
                      border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(20),
                         ),),
                  ),
                                    SizedBox(height: 12,),

                  // Ajout des champs pour le mot de passe et sa confirmation
                  TextFormField(
                                   validator: (password) {
                             if (password == null || password.isEmpty) {                                 return 'Veuillez entrer un mot de passe.';
                              }

                              // Vérifier la longueur du mot de passe
                              if (password.length < 6) {
                                 return 'Le mot de passe doit contenir au moin 6 caractères.';                               }

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
                                 return 'Le mot de passe doit contenir au moins un chiffre.';                               }

                             // Vérifier la présence d'au moins un caractère spécial
                             if (!password.contains(
                                  RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                              return 'Le mot de passe doit contenir au moins un caractère spécial.';
                             }

                              return null;
                           },
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Mot de passe',
                     border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(20),
                         ),
                    ),
                  ),
                                 SizedBox(height: 12,),

                  // Dropdown pour sélectionner le type d'utilisateur (utilisateur ou chauffeur)
                  DropdownButtonFormField<String>(
                    value: choosevalue ?? 'utilisateur',
                    onChanged: (newValue) {
                      setState(() {
                        choosevalue = newValue;
                      });
                    },
                    items: ['utilisateur', 'chauffeur'].map((valueItem) {
                      return DropdownMenuItem<String>(
                        child: Text(valueItem),
                        value: valueItem,
                      );
                    }).toList(),

                    decoration: InputDecoration(
                                labelText: 'Statut ',
                                labelStyle: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                  ),
                                    SizedBox(height: 12,),

                  // Condition pour afficher les champs supplémentaires si le type d'utilisateur est "chauffeur"
                  if (choosevalue == 'chauffeur') ...[
                    // Champ pour le numéro de taxi
                    TextFormField(
  controller: usernumController,
  keyboardType: TextInputType.number,
  decoration: InputDecoration(
    labelText: 'Numéro du Taxi',
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  validator: validateTaxiNumber, // Utilisation du validateur personnalisé
),
                                      SizedBox(height: 12,),

                    // Champ pour le matricule
                    TextFormField(
                      controller: usermatController,
                      decoration: InputDecoration(labelText: 'Matricule',
                       border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(20),
                         ),),
                    ),
                  ],
                                    SizedBox(height: 12,),

                  // Champs pour le numéro de téléphone
                  TextFormField(
                    controller: userphoneController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Numéro de téléphone',
                      prefixIcon: GestureDetector(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            onSelect: (value) {
                              setState(() {
                                selectedCountry = value;
                              });
                            },
                          );
                        },
                        child: Text("${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}", style: TextStyle(fontSize: 20)),
                      ),
                        border: OutlineInputBorder(
                               borderRadius: BorderRadius.circular(20),
                         )
                    ),
                  ),
                                    SizedBox(height: 12,),

                  // Dropdown pour sélectionner le modèle de voiture (uniquement pour les chauffeurs)
                  if (choosevalue == 'chauffeur') ...[
                    DropdownButtonFormField<String>(
                      value: choosevalue1 ?? models.first,
                      onChanged: (newValue) {
                        setState(() {
                          choosevalue1 = newValue;
                        });
                      },
                      items: models.map((valueItem) {
                        return DropdownMenuItem<String>(
                          child: Text(valueItem),
                          value: valueItem,
                        );
                      }).toList(),
                    ),
                  ],
                                    SizedBox(height: 30,),

                  // Bouton pour s'inscrire
                  ElevatedButton(
                    onPressed: () async {
                      // Logique pour s'inscrire selon le type d'utilisateur sélectionné
                      try {
                        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                        if (choosevalue == "chauffeur") {
                           String? token = await FirebaseMessaging.instance.getToken();
        
                            await FirebaseDatabase.instance.ref('position').child(credential.user!.uid).set({
                                           'email': _emailController.text,
                                                   
                                           'Nom': _userController.text,
                                           'statut':choosevalue,
                                             "token":token
                                           
                                             // Add more f+ields as needed
                                           });
                                           addUser();
                          // Logique pour les chauffeurs
                          // Ajoutez ici le code pour sauvegarder les données du chauffeur dans la base de données
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginuserPage()));
                        } else {
                             await FirebaseDatabase.instance.ref('user').child(credential.user!.uid).set({
                                           'email': _emailController.text,
                                                   
                                           'Nom': _userController.text,
                                           
                                           'statut':choosevalue,
                                          
        
                                             // Add more f+ields as needed
                                           });
                          // Logique pour les utilisateurs
                          // Ajoutez ici le code pour sauvegarder les données de l'utilisateur dans la base de données
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginuserPage()));
                        }
                      } on FirebaseAuthException catch (e) {
                        // Gestion des erreurs d'authentification
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
                              content: Text("The account already exists for that email"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        print(e);
                      }
                      
                    },
                     style: ElevatedButton.styleFrom(
             minimumSize: Size(250, 50),
               backgroundColor: Colors.white60,
                       ),
                       
                    child: Text("S'inscrire",style: TextStyle(color: Colors.black),),
                  ),
        SizedBox(height: 50,),
                   Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("Avez vous un compte?"),
                                  SizedBox(width: 5),
                                  GestureDetector(
                                    onTap: () {
                                     Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => LoginuserPage()),
                                        (route) => false,
                                      );
                                    },
                                    child: Text(
                                      "Enregistrer",
                                      style: TextStyle(
                                        color:Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ), 
                  ],
                  
                
              
              ),
            ),
          ),
        ),
      ],
    );
  }
  

  
}