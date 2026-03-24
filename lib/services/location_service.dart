import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String? city;
  final String? area;

  LocationResult({
    required this.latitude,
    required this.longitude,
    this.city,
    this.area,
  });

  String get displayName {
    if (area != null && city != null) return '$area, $city';
    return city ?? area ?? '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
  }
}

class LocationService {
  static Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  static Future<LocationResult?> getCurrentLocation() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      String? city;
      String? area;
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          city = placemarks.first.locality;
          area = placemarks.first.subLocality ?? placemarks.first.subAdministrativeArea;
        }
      } catch (_) {
        // Geocoding failed, use coordinates only
      }

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        city: city,
        area: area,
      );
    } catch (_) {
      return null;
    }
  }
}
