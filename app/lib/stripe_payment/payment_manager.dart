import 'package:app/stripe_payment/stripe_keys.dart';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:rating_dialog/rating_dialog.dart'; // Make sure to add this dependency

abstract class PaymentManager {
 static  makePayment(int amount, String currency, BuildContext context) async {
  try {
    String clientSecret = await _getClientSecret((amount * 100).toString(), currency);
    await _initializePaymentSheet(clientSecret);
    await Stripe.instance.presentPaymentSheet();
    return true; // Payment successful
  } catch (error) {
    print("Payment error: $error");
    return false; // Payment failed
  }
}


  static Future<void> _initializePaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: "arij",
      ),
    );
  }

  static Future<String> _getClientSecret(String amount, String currency) async {
    Dio dio = Dio();
    var response = await dio.post(
      'https://api.stripe.com/v1/payment_intents',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${ApiKeys.secretkey}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
      ),
      data: {
        'amount': amount,
        'currency': currency,
      },
    );
    return response.data["client_secret"];
  }

}
