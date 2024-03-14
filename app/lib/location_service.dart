import 'dart:convert' as convert;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class location_service {
  String key = 'AIzaSyC7ckSip1a_oVGM1y7nPSWGUdTEPbkANIA';

  Future<String> getId(String input) async {
    final String url =
        "https://maps.googleapis.com/maps/api/place/details/json?input=$input&inputtype=textquery&key=$key";
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var json = convert.jsonDecode(response.body);
      var placeId = json['result']['place_id'] as String?;
      if (placeId != null) {
        print(placeId);
        return placeId;
      } else {
        throw Exception('Place ID not found');
      }
    } else {
      throw Exception('Failed to fetch place ID');
    }
  }
  Future<Map<String,dynamic>>getplace(String input)async{
    final placeId= await(input);
    final String url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key";
        var response = await http.get(Uri.parse(url));

      var json = convert.jsonDecode(response.body);
      var results = json ['result'] as Map<String, dynamic>;
print (results);
return results;
  }

}


