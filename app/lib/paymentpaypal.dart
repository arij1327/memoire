import 'package:app/stripe_payment/payment_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rating_dialog/rating_dialog.dart';

class PaymentStripe extends StatefulWidget {
  const PaymentStripe({Key? key}) : super(key: key);

  @override
  _PaymentStripeState createState() => _PaymentStripeState();
}

class _PaymentStripeState extends State<PaymentStripe> {
  int? price1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDataUser();
  }

  Future<void> getDataUser() async {
    setState(() {
      isLoading = true;
    });
    try {
      DatabaseReference ref = FirebaseDatabase.instance
          .ref()
          .child("user")
          .child(FirebaseAuth.instance.currentUser!.uid);
      DataSnapshot snapshot = await ref.get();

      if (snapshot.exists && snapshot.value != null) {
        Map<String, dynamic> data1 = Map<String, dynamic>.from(snapshot.value as Map);
        if (data1.containsKey('prix')) {
          setState(() {
            price1 = data1['prix'] is int ? data1['prix'] : int.tryParse(data1['prix'].toString());
          });
        } else {
          print("Prix field does not exist in the document");
        }
      } else {
        print("Document does not exist");
      }
    } catch (e) {
      print("An error occurred: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load price data. Please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: isLoading
        ? Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "asset/payy.jpeg",
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 550),
                    ElevatedButton(
                      onPressed: price1 != null
                          ? () async {
                              try {
                                bool paymentSuccess = await PaymentManager.makePayment(
                                    price1!, "EGP", context);
                                if (paymentSuccess) {
                                  _showRatingDialog(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Payment failed. Please try again.')),
                                  );
                                }
                              } catch (e) {
                                print("Payment error: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('An error occurred. Please try again.')),
                                );
                              }
                            }
                          : null,
                      child: Text("Pay ${price1 ?? 0} "),
                      style: ElevatedButton.styleFrom(
                       backgroundColor: Color.fromARGB(-4, 251, 251,131),
                           minimumSize: Size(250, 50)
                           
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
  );
}


  void _showRatingDialog(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;
    if (arguments == null || !arguments.containsKey('id')) {
      print("Invalid arguments for rating dialog.");
      return;
    }
    dynamic id = arguments['id'];

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return RatingDialog(
          initialRating: 1.0,
          title: Text(
            'Quel est votre avis sur le service du taxi',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          message: Text(
            'Tap a star to set your rating. Add more description here if you want.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15),
          ),
          image: Image.asset("asset/raiting.png", width: 100, height: 100),
          submitButtonText: 'Submit',
          commentHint: 'Set your custom comment hint',
          onCancelled: () => print('cancelled'),
          onSubmitted: (response) {
            print('rating: ${response.rating}, comment: ${response.comment}');
            submitRating(response.rating, response.comment, id);
          },
        );
      },
    );
  }

  Future<void> submitRating(double rating, String comment, dynamic id) async {
    try {
      await FirebaseDatabase.instance
          .ref('rating')
          .child(id.toString())
          .push()
          .set({
        'rating': rating.toString(),
        'comment': comment,
        'timestamp': DateTime.now().toIso8601String(),
      });
      print('Rating submitted successfully!');
    } catch (e) {
      print('Failed to submit rating: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating. Please try again.')),
      );
    }
  }
}