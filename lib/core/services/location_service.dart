import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double? latitude;
  final double? longitude;
  final String? error;
  final bool success;

  LocationResult({
    this.latitude,
    this.longitude,
    this.error,
    this.success = false,
  });
}

class LocationService {
  /// Fetches the current location coordinates of the device.
  /// Handles permission status gracefully and returns a LocationResult.
  Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult(
          error: 'Location services are disabled on your device. Please enable them in settings.',
          success: false,
        );
      }

      // Check existing permissions.
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Request permissions.
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationResult(
            error: 'Location permissions were denied by the user.',
            success: false,
          );
        }
      }

      // Handle permanently denied permissions.
      if (permission == LocationPermission.deniedForever) {
        return LocationResult(
          error: 'Location permissions are permanently denied. Please enable them in your device settings.',
          success: false,
        );
      }

      // Fetch current coordinates.
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 8),
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        success: true,
      );
    } catch (e) {
      return LocationResult(
        error: 'Failed to retrieve location: $e',
        success: false,
      );
    }
  }
}
