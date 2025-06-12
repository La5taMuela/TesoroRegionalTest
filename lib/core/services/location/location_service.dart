import 'package:location/location.dart';
import 'dart:math';
class LocationService {
  final Location _location = Location();

  Future<LocationData> getCurrentPosition() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('Los servicios de ubicación están desactivados.');
      }
    }

    PermissionStatus permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await _location.requestPermission();
      if (permission == PermissionStatus.denied) {
        throw Exception('Permisos de ubicación denegados');
      }
    }

    if (permission == PermissionStatus.deniedForever) {
      throw Exception('Los permisos de ubicación están permanentemente denegados');
    }

    return await _location.getLocation();
  }

  Stream<LocationData> getPositionStream() {
    return _location.onLocationChanged;
  }

  static double calculateDistance(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
      ) {
    // Note: The location package doesn't have a built-in distance calculator
    // You might want to implement this manually or use another package
    // This is a simple implementation using the Haversine formula
    const double earthRadius = 6371000; // meters
    double dLat = _toRadians(endLatitude - startLatitude);
    double dLon = _toRadians(endLongitude - startLongitude);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(startLatitude)) *
            cos(_toRadians(endLatitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}