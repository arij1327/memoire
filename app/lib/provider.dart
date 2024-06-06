import 'package:flutter/material.dart';

class DriverNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> _nearbyDrivers = [];
  int currentDriverIndex = 0;

  List<Map<String, dynamic>> get nearbyDrivers => _nearbyDrivers;

  void setNearbyDrivers(List<Map<String, dynamic>> drivers) {
    _nearbyDrivers = drivers;
    notifyListeners();
  }

  void removeDriverAtIndex(int index) {
    if (index < _nearbyDrivers.length) {
      _nearbyDrivers.removeAt(index);
      notifyListeners();
    }
  }
}
