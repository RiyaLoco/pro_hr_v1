import 'dart:async';

import 'package:geolocator/geolocator.dart';


class LocationException implements Exception {
  final String message;
  final bool canOpenAppSettings;
  final bool canOpenLocationSettings;

  const LocationException(
    this.message, {
    this.canOpenAppSettings = false,
    this.canOpenLocationSettings = false,
  });

  @override
  String toString() => message;
}

class LocationService {
  Future<void> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(
        'Location services are turned off. Please turn on GPS and try again.',
        canOpenLocationSettings: true,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationException(
        'Location permission is needed to check in and out.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Location permission is blocked. Please allow it in the app settings.',
        canOpenAppSettings: true,
      );
    }
  }

  /// The phone's current position. Refuses mock / fake GPS.
  Future<Position> getCurrentPosition() async {
    await ensurePermission();

    final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      throw const LocationException(
        'Could not get your location. Move to an open area and try again.',
      );
    }

    if (position.isMocked) {
      throw const LocationException(
        'A fake (mock) location was detected. Turn it off and try again.',
      );
    }
    return position;
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();
}