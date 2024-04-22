import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app/constant.dart';


   Future<double> getEstimatedPrice( startLat,  startLng,  destLat, destLng) async {
   
    String url = "https://api.taxiservice.com/estimate_price?start_lat=$startLat&start_lng=$startLng&dest_lat=$destLat&dest_lng=$destLng&api_key=$apiKey";
    
    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        double estimatedPrice = data['estimated_price'];
        return estimatedPrice;
      } else {
        throw Exception('Failed to load estimated price');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }



