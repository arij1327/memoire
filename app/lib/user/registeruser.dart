import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'loginuser.dart';

class SignupUserPage extends StatefulWidget {
  const SignupUserPage({Key? key}) : super(key: key);

  @override
  State<SignupUserPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupUserPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _prenomController = TextEditingController();
  TextEditingController _userController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController usernumController = TextEditingController();
  TextEditingController userphoneController = TextEditingController();
  TextEditingController usermatController = TextEditingController();
  final List<String> models = ["Fiat", "Ford", "Hyundai", "KIA", "Peugeot", "Renault"];
  String? choosevalue;
  String? choosevalue1;
  String? _taxiNumberError;

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

  Future<String> checkTaxiNumberExists(String taxiNumber) async {
    print("Vérification du numéro de taxi: $taxiNumber");
    try {
      DatabaseReference reff = FirebaseDatabase.instance.ref().child('position');
      Query queryRef = reff.orderByChild('Numéro du taxi').equalTo(taxiNumber);
      DatabaseEvent event = await queryRef.once();
      DataSnapshot snapshot = event.snapshot;

      print("Snapshot value: ${snapshot.value}");

      if (snapshot.exists) {
        print("Le numéro de taxi existe déjà");
        return 'Ce numéro de taxi existe déjà.';
      } else {
        print("Le numéro de taxi n'existe pas");
        return 'valid';
      }
    } catch (e) {
      print('Erreur lors de la vérification du numéro de taxi: $e');
      return 'error';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("asset/registrer.jpeg"), fit: BoxFit.fill)
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(45.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(padding: EdgeInsets.only(top: 30)),
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre prénom';
                              }
                              return null;
                            },
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer votre nom';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Adresse Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      validator: (email) {
                        if (email == null || email.isEmpty) {
                          return 'Veuillez entrer votre adresse email';
                        }
                        String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                        RegExp regex = RegExp(pattern);
                        if (!regex.hasMatch(email)) {
                          return 'Veuillez entrer une adresse email valide';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      validator: (password) {
                        if (password == null || password.isEmpty) {
                          return 'Veuillez entrer un mot de passe';
                        }
                        if (password.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: choosevalue,
                      onChanged: (newValue) {
                        setState(() {
                          choosevalue = newValue;
                        });
                      },
                      items: ['utilisateur', 'chauffeur'].map((valueItem) {
                        return DropdownMenuItem<String>(
                          value: valueItem,
                          child: Text(valueItem),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Statut',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner un statut';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    if (choosevalue == 'chauffeur') ...[
                      TextFormField(
                        controller: usernumController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Numéro du Taxi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          errorText: _taxiNumberError,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le numéro du taxi';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: usermatController,
                        decoration: InputDecoration(
                          labelText: 'Matricule',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer le matricule';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: choosevalue1,
                        onChanged: (newValue) {
                          setState(() {
                            choosevalue1 = newValue;
                          });
                        },
                        items: models.map((valueItem) {
                          return DropdownMenuItem<String>(
                            value: valueItem,
                            child: Text(valueItem),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          labelText: 'Modèle',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez sélectionner un modèle';
                          }
                          return null;
                        },
                      ),
                    ],
                    SizedBox(height: 12),
                    TextFormField(
                      controller: userphoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Numéro de téléphone',
                        prefixIcon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: GestureDetector(
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
                            child: Text(
                              "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (choosevalue == 'chauffeur') {
                            String result = await checkTaxiNumberExists(usernumController.text);
                            if (result != 'valid') {
                              setState(() {
                                _taxiNumberError = result;
                              });
                              return;
                            } else {
                              setState(() {
                                _taxiNumberError = null;
                              });
                            }
                          }

                          try {
                            UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            
                            if (choosevalue == "chauffeur") {
                              String? token = await FirebaseMessaging.instance.getToken();
                              await FirebaseDatabase.instance.ref('position').child(userCredential.user!.uid).set({
                                'email': _emailController.text,
                                'Nom': _userController.text,
                                'Prénom': _prenomController.text,
                                'statut': choosevalue,
                                'Numéro du taxi': usernumController.text,
                                'Matricule': usermatController.text,
                                'Modèle': choosevalue1,
                                'token': token,
                                'phone':userphoneController.text
                              });
                            } else {
                              await FirebaseDatabase.instance.ref('user').child(userCredential.user!.uid).set({
                                'email': _emailController.text,
                                'Nom': _userController.text,
                                'Prénom': _prenomController.text,
                                'statut': choosevalue,
                                                                'phone':userphoneController.text

                              });
                            }
                            
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginuserPage()));
                          } on FirebaseAuthException catch (e) {
                            String message;
                            if (e.code == 'weak-password') {
                              message = 'Le mot de passe fourni est trop faible.';
                            } else if (e.code == 'email-already-in-use') {
                              message = 'Un compte existe déjà pour cet email.';
                            } else {
                              message = 'Une erreur s\'est produite. Veuillez réessayer.';
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(message)),
                            );
                          } catch (e) {
                            print(e);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Une erreur s\'est produite. Veuillez réessayer.')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.white60,
                      ),
                      child: Text("S'inscrire", style: TextStyle(color: Colors.black)),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Vous avez déjà un compte?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginuserPage()));
                          },
                          child: Text(
                            "Se connecter",
                            style: TextStyle(
                              color: Colors.black,
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
        ),
      ],
    );
  }
}