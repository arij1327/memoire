import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rating_dialog/rating_dialog.dart';
final _dialog = RatingDialog(
      initialRating: 1.0,
      // your app's name?
      title: Text(
        'Rating Dialog',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      // encourage your user to leave a high rating?
      message: Text(
        'Tap a star to set your rating. Add more description here if you want.',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15),
      ),
      // your app's logo?
      image: const FlutterLogo(size: 100),
      submitButtonText: 'Submit',
      commentHint: 'Set your custom comment hint',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        print('rating: ${response.rating}, comment: ${response.comment}');

      // submitRating(response.rating, response.comment);
    
      },
     
    );
     void showDialogRating(BuildContext context){
       showDialog(
      context: context,
      barrierDismissible: true, 
      builder: (context) => _dialog,
    );
      

     }
      void submitRating(double rating, String comment) async {
    try {
      // Enregistrer la notation dans Firestore
      await FirebaseDatabase.instance.ref('driver_ratings').set({
        'driverId':  FirebaseAuth.instance.currentUser!.uid,
        'userId': FirebaseAuth.instance.currentUser!.uid, // ID de l'utilisateur actuel
        'rating': rating,
        'comment': comment,
        'timestamp': Timestamp.now(),
      });
      print('Notation soumise avec succès !');
    } catch (e) {
      print('Échec de la soumission de la notation : $e');
    }
  }


    

    

   