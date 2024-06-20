import 'package:app/stripe_payment/payment_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rating_dialog/rating_dialog.dart';

class PaymentStripe extends StatefulWidget {
  PaymentStripe({Key? key}) : super(key: key);

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
          .ref()
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
          Container(
            width: 50,
            decoration: BoxDecoration(
              
              image: DecorationImage(
                image: AssetImage("asset/payment.png") 
                ,
                
              ),
            ),
          ),
          ElevatedButton(
            onPressed: price1 != null
                ? () async {
                    bool paymentSuccess = await PaymentManager.makePayment(price1!, "USD", context);
                    if (paymentSuccess) {
                      _showRatingDialog(context);
                    } else {
                      // Handle payment failure
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Payment failed. Please try again.')),
                      );
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
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;
    if (arguments == null || !arguments.containsKey('id')) {
      print("Invalid arguments for rating dialog.");
      return;
    }
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
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
           
            image: Image.asset("asset/raiting.png",width: 20,),
            submitButtonText: 'Submit',
            commentHint: 'Set your custom comment hint',
            onCancelled: () => print('cancelled'),
            onSubmitted: (response) {
              print('rating: ${response.rating}, comment: ${response.comment}');
              // Call your submitRating function here
              submitRating(response.rating, response.comment, id);
            },
          ),
        );
      },
    );
  }

  static Future<void> submitRating(double rating, String comment, dynamic id) async {
    try {
      // Enregistrer la notation dans Firebase Database
      await FirebaseDatabase.instance
          .ref('rating')
          .child(id.toString())
          .push()
          .set({
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