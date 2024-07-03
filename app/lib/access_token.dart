import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
class PushNotificationService {
 
static String? _accessToken;

static Future<String> getAccessToken() async {
  // Vérifier si nous avons déjà un jeton d'accès valide en mémoire
  if (_accessToken != null) {
    return _accessToken!;
  }

  // Obtenir un nouveau jeton d'accès
  final serviceAccountJson = {
    "type": "service_account",
    "project_id": "apptaxi-89d1b",
    "private_key_id": "2c6aeee8ecbd561ec229e9a3c0b63a20e6404a15",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDBcTLwC5uxqeyE\nTh+nYh20ie5lozVugmBkp1RihZXgV5+E+rKh3WTU2q7FnD99pUHnRzY/f+6tEc64\n6/gCmMnU+yrVKGgSa6IAEjnHUtmoRYZ92cwViArk306IUzG66jV/7J7MI1wLBDvf\nubx8b64LxTlKbIvqjxdUGNe2XYl+9gyIghs3uqERVqvBLtua5ArJXpxVf1Vvw93B\nccfNRRrVybqs5MZxSsxAsaQM30xEUbPMIricEVjmi22TY/KTTh/p1kMLDPc1lQqh\nc8YQmCI8LnnyXudmGQeDxQo40aH/w3w4xRkIVOmvqGomMO+Bhejq+adv8G+6w6+l\nOFqBZ54ZAgMBAAECggEAM9FSb0n0wXE+yawxv4FBatC9+xzunbUwBBZsvN2C6e8e\n7JzJSCHJtlkEEyxJN6uSjVUem4D2GwdXpGKVc4ChJDvJ3AKwairJ4RIAxzuS0Yga\nQFEc4bGpFWkaHNuISUUe4q8sVIuuRscyELqs2nqCGWYR9DVCf6kn+x+SfSfuQoNH\n8AafCL62S9xSIVGWIsKZcB8L16IWTJF00YYKPxcffEOPa9ZFxMevBytNpRYvBt15\nsjqPh6oggtfGRcngtTruYrPrPWQ9Ex2LxkyZ1ZrnEanMETgH78pdfmWU8MfFHjv0\ne2Ds3+/CdS+Rs7fiGPE77hFSKM4bcI2stoKNwL99HwKBgQDyEw1jtkfnS+kQBpjV\n+6rHB1pFT089NPtEJN09s/wDpIT76Pw5hyzWGqJ4Tkrh8YSBgsqF7fTOvoO1VnQS\nim54efvwIiE0cxY4s82smL4ufEOKObrnYgcQe2ZUZGVTfAD6XtC8uM4hfrWvhQ9W\nZRmlMJ6nFTvO31y8M1+J0IMdgwKBgQDMkfTK4VaCHeAjVcwQkXgY1sDU445OA6bB\nkUfvP0Y9F/P01ojUnXN/N6Xjou8lF9hdl9DIYQUNYhXkWx7He9ay5Yyz9xwfoSEX\n/6cLnocMkV2YB7vVJX7ppG3MTZs9y8YGlQZ1+kEfr5pAnWs2XLCOMgslL/uW9Atr\nzfWnu2y/MwKBgQDa8NRpXNHHpmaSsgTFdKtO+51vln2qdCLVzSm0xvamLMSCOoT1\nWwb4VnqfqOAdXp1jrXGSlFeYLcNd3WV5525m1J1C4Pt7PqPYgPcCpdtMm+NSP0iG\nQaj2BUXWCj+CtGMGD39nURZOQRX+O7BViXcaatDzeUbwoiBzr1s3gDk2FQKBgQCf\n+ihYHB5dxOVKXMcn0cr8ibzk/0uDAOIAkA+ULoRMNJYoSzlYJAV1YFxPh1TDSkF+\n98FjYlPkImeCXCvWzqaY4mDFQCLzLTvHG7tTn9Z24psx0CJ4zkjQiDEBS1Ny4Q9s\niFA0JM+W6umTTEfSjGvZ15LVsw9p/lGMLdXFJRIm9wKBgQCFFl3whWaIxsmwbbWn\n4WUkTeGuPNIDXxdPc8WNk3NQvf3eKlMCjM9uUNsADb3HDV3qGYMZe9JQEjnH8wFd\nLnnKeOqObFRBInLtAtyCOC/QxshPB5Xn8kR8APv1JZ3q1pU3VHbzJUnykyfs/8Jp\nQFrDHrWkwOqLjVM2nKtwd0KKfw==\n-----END PRIVATE KEY-----\n",
    "client_email": "apptaxi-89d1b@appspot.gserviceaccount.com",
    "client_id": "106201903903504776927",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/apptaxi-89d1b%40appspot.gserviceaccount.com",
    "universe_domain": "googleapis.com"
  };

  List<String> scopes = [
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/firebase.database",
    "https://www.googleapis.com/auth/firebase.messaging"
  ];

  http.Client client = await auth.clientViaServiceAccount(
    auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
    scopes,
  );

  // Obtenir le jeton d'accès
  auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
    auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
    scopes,
    client
  );

  // Fermer le client HTTP
  client.close();

  // Retourner le jeton d'accès
  _accessToken = credentials.accessToken.data;
  print(_accessToken);
  return _accessToken!;
}static Future<void> sendFCMMessage(
  title,
  body,
  targetDeviceToken

) async {
  final String serverKey = await getAccessToken();
    String? token1 = await FirebaseMessaging.instance.getToken();
String  id=FirebaseAuth.instance.currentUser!.uid;
  final String fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/apptaxi-89d1b/messages:send';
  final currentFCMToken = await FirebaseMessaging.instance.getToken();print(currentFCMToken);


  final Map<String, dynamic> message = {
    'message': {
      'token': targetDeviceToken,
      'notification': {
        'body': body,
        'title': title
      },
      "data":{
      'id':id,
'tok':token1

    }
    }
  };

  try {
    final http.Response response = await http.post(
      Uri.parse(fcmEndpoint),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverKey',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('FCM message sent successfully');
    } else {
      print('Failed to send FCM message: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  } catch (e) {
    print('Error sending FCM message: $e');
  }
}
}