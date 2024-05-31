import 'package:app/stripe_payment/payment_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:rating_dialog/rating_dialog.dart';

class PaymentStripe extends StatefulWidget {
  PaymentStripe({super.key});

  @override
  _PaymentStripeState createState() => _PaymentStripeState();
}

class _PaymentStripeState extends State<PaymentStripe> {
  int? price1;

  @override
  void initState() {
    super.initState();
    getDataUser();
  }

  Future<void> getDataUser() async {
    try {
      DatabaseReference ref = FirebaseDatabase.instance
          .reference()
          .child("user")
          .child(FirebaseAuth.instance.currentUser!.uid);
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        dynamic data1 = snapshot.value;
        setState(() {
          price1 = data1['prix'];
        });
      } else {
        print("Document does not exist");
      }
    } catch (e) {
      print("An error occurred: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stripe Payment'),
      ),
      body: Column(
        children: [
        ElevatedButton(
  onPressed: price1 != null
    ? () async {
        bool paymentSuccess = await PaymentManager.makePayment(price1!, "EGP", context);
        if (paymentSuccess) {
          _showRatingDialog(context);
        } else {
          // Handle payment failure
        }
      }
    : null,
  child: Text("Payment"),
),

        
        ],
      ),
    );
  }
  
static void _showRatingDialog(BuildContext context) {
   final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>;
    dynamic id = arguments['id'];


 

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: RatingDialog(
            initialRating: 1.0,
            title: Text(
              'Quel est votre avis sur le service du taxi',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            message: Text(
              'Tap a star to set your rating. Add more description here if you want.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
            image: const FlutterLogo(size: 100),
            submitButtonText: 'Submit',
            commentHint: 'Set your custom comment hint',
            onCancelled: () => print('cancelled'),
            onSubmitted: (response) {
              print('rating: ${response.rating}, comment: ${response.comment}');
              // Call your submitRating function here
              submitRating(response.rating, response.comment,id);
            },
          ),
        );
      },
    );
  
}
  static Future<void> submitRating(double rating, String comment, id) async {
    try {
      // Enregistrer la notation dans Firebase Database
      await FirebaseDatabase.instance
          .ref('rating')
         .child(id.toString())
          .push()
          .set({
        // ID de l'utilisateur actuel
        'rating': rating.toString(),
        'comment': comment.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      print('Notation soumise avec succès !');
    } catch (e) {
      print('Échec de la soumission de la notation : $e');
    }
  }
}
