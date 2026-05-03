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

enum LocationFailure {
  serviceDisabled,    // Device location services are off
  permissionDenied,   // User denied this time (can ask again)
  permissionForever,  // User permanently denied — must open settings
  fetchFailed,        // Permission OK but getting position failed (timeout, etc.)
}

class LocationFetchResult {
  final LocationResult? location;
  final LocationFailure? failure;

  const LocationFetchResult.success(LocationResult this.location) : failure = null;
  const LocationFetchResult.failed(LocationFailure this.failure) : location = null;

  bool get isSuccess => location != null;
}

class LocationService {
  /// Ensures location services are on and permission is granted.
  /// Triggers the native permission dialog when not yet decided.
  static Future<LocationFailure?> ensurePermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationFailure.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationFailure.permissionForever;
    }
    if (permission == LocationPermission.denied) {
      return LocationFailure.permissionDenied;
    }
    return null;
  }

  static Future<void> openAppSettings() => Geolocator.openAppSettings();
  static Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  static Future<LocationFetchResult> getCurrentLocation() async {
    final permFailure = await ensurePermission();
    if (permFailure != null) return LocationFetchResult.failed(permFailure);

    try {
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

      return LocationFetchResult.success(LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        city: city,
        area: area,
      ));
    } catch (_) {
      return const LocationFetchResult.failed(LocationFailure.fetchFailed);
    }
  }
}
