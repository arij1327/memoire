import 'dart:convert';

import 'package:app/components/network_utilities.dart';
import 'package:app/constant.dart';
import 'package:app/models/autocomplate_prediction.dart';
import 'package:app/models/place_auto_complate_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

import 'components/location_list_tile.dart';



class SearchLocationScreen extends StatefulWidget {
  const SearchLocationScreen({Key? key}) : super(key: key);

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  List<AutocompletePrediction> placePredictions = [];
  final TextEditingController _searchController = TextEditingController();
   double latitude = 0.0;
  double longitude = 0.0;
    GoogleMapController? _mapController;

  placeAutoComplete(String query) async {
    Uri uri =
        Uri.https("maps.googleapis.com", "maps/api/place/autocomplete/json", {
      "input": query,
      "key": apiKey,
    });
    String? response = await NetworkUtils.fetchUrl(uri);
    String? placeId;

    if (response != null) {
      PlaceAutocompleteResponse result =
          PlaceAutocompleteResponse.parseAutocompleteResult(response);
      if (result.predictions != null && result.predictions!.isNotEmpty) {
        // Assuming you want to use the first prediction's place ID
        placeId = result.predictions![0].placeId;
      }

      if (result.predictions != null) {
        setState(() {
          placePredictions = result.predictions!;
        });
      }
    }

    return {'response': response, 'placeId': placeId};
  }

   placeGetLngLat(String placeId) async {
    Uri uri = Uri.https("maps.googleapis.com", "maps/api/place/details/json", {
      "place_id": placeId,
      "key": apiKey,
      
    });
    String? response = await NetworkUtils.fetchUrl(uri);

    if (response != null) {
      // Process the response to get longitude and latitude
      // For example:
      debugPrint(response);
       PlaceDetailResponse result = PlaceDetailResponse.fromJson(json.decode(response));
      double latitude = result.geometry.location.lat;
       double longitude = result.geometry.location.lng;
    }
  return {'longitude': longitude, 'latitude': latitude};
  }
  void goToPlaceOnMap(double latitude, double longitude) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(latitude, longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Column(
        children: <Widget>[
          Form(
            child: Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: TextFormField(
                controller: _searchController,
                onChanged: (value) {
                  placeAutoComplete(value);
                  goToPlaceOnMap(latitude, longitude);

                },
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search your location",
                 
                ),
              ),
            ),
            
          ),
          const Divider(
            height: 4,
            thickness: 4,
            color: secondaryColor5LightTheme,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: placePredictions.length,
              itemBuilder: (context, index) => LocationListTile(
                location: placePredictions[index].description!,
             onTap: () {
  setState(() {
    _searchController.text = placePredictions[index].description!;
    placePredictions.clear(); // Clear predictions after selection
  });
})))]));
  }
}
            

// LocationListTile widget
class LocationListTile extends StatelessWidget {
  final String location;
  final VoidCallback onTap;

  const LocationListTile({
    Key? key,
    required this.location,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(location),
      onTap: onTap,
    );
  }
}

class PlaceDetailResponse {
  final Geometry geometry;

  PlaceDetailResponse({required this.geometry});

  factory PlaceDetailResponse.fromJson(Map<String, dynamic> json) {
    return PlaceDetailResponse(
      geometry: Geometry.fromJson(json['geometry']),
    );
  }
}

class Geometry {
  final Location location;

  Geometry({required this.location});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      location: Location.fromJson(json['location']),
    );
  }
}

class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
