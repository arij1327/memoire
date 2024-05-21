import 'package:app/stripe_payment/payment_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class paymentStripe extends StatelessWidget {
  const paymentStripe({super.key});
 

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: ()=>PaymentManager.makePayment(40, "EGP"), 
            child: Text("Payment"),
            )
        ],
      ),
    );;
  }
}