import 'dart:convert';

import 'package:app/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

Set<Polyline> polylineSet = {};
List<LatLng> polylineCo = [];
PolylinePoints polylinePoints = PolylinePoints();
Set<Marker> markers = {};

Future<void> getPolyline(lat, long, destLat, destLong) async {
  String url =
      "https://maps.googleapis.com/maps/api/directions/json?origin=$lat,$long&destination=$destLat,$destLong&key=$apiKey";
  var response = await http.get(Uri.parse(url));
  var responseBody = jsonDecode(response.body);

  var point = responseBody['routes'][0]['overview_polyline']['points'];
  List<PointLatLng> result = polylinePoints.decodePolyline(point);

  if (result.isNotEmpty) {
    result.forEach((PointLatLng pointLatLng) {
      polylineCo.add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
    });
  }

  Polyline polyline = Polyline(
    polylineId: PolylineId("polyline"),
    color: Color(0xff3498db),
    width: 5,
    points: polylineCo,
  );
  polylineSet.add(polyline);

  // Ajouter le marqueur de durée
  if (polylineCo.length > 1) {
    var midPointIndex = (polylineCo.length / 2).round();
    var midPoint = polylineCo[midPointIndex];
    var durationText =
        responseBody['routes'][0]['legs'][0]['duration']['text'];

    Marker durationMarker = Marker(
      markerId: MarkerId("duration"),
      position: midPoint,
      infoWindow: InfoWindow(
        title: 'Duration',
        snippet: durationText,
      ),
    );
    
;
    // Ajouter le marqueur à la liste des marqueurs
    markers.add(durationMarker);
  }
}
