import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'loginuser.dart'; // Importez le fichier contenant la page de connexion utilisateur

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
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ajout des champs pour le prénom et le nom
              TextField(
                controller: _prenomController,
                decoration: InputDecoration(labelText: 'Prénom'),
              ),
              TextField(
                controller: _userController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              // Ajout du champ pour l'adresse email
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Adresse Email'),
              ),
              // Ajout des champs pour le mot de passe et sa confirmation
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Mot de passe'),
              ),
              TextField(
                controller: _confirmpasswordController,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Confirmez le mot de passe'),
              ),
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
              ),
              // Condition pour afficher les champs supplémentaires si le type d'utilisateur est "chauffeur"
              if (choosevalue == 'chauffeur') ...[
                // Champ pour le numéro de taxi
                TextField(
                  controller: usernumController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Numéro du Taxi'),
                  
                ),
                // Champ pour le matricule
                TextField(
                  controller: usermatController,
                  decoration: InputDecoration(labelText: 'Matricule'),
                ),
              ],
              // Champs pour le numéro de téléphone
              TextField(
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
                ),
              ),
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
                child: Text("S'inscrire"),
              ),

               Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account?"),
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
                                    color:Color(0xFF53bcbd),
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
    );
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
}
