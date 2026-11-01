import 'dart:math' as math;

/// Dart port of the Laravel `calculateDistance()` helper (Haversine formula),
/// with the same inputs, units, validation rules and 3-decimal rounding.
///
/// Locations are "latitude,longitude" strings, e.g. '11.5564,104.9282'.
/// Units: meter (default), km, mile, foot, yard (same aliases as the PHP one).
///
/// IMPORTANT: use this only to PREVIEW the distance in the UI. The server
/// stays the authority on whether a punch is allowed.
double calculateDistance(
  String latlong1,
  String latlong2, {
  String unit = 'meter',
}) {
  final a = _parseLatLong(latlong1);
  final b = _parseLatLong(latlong2);
  return distanceBetween(a.$1, a.$2, b.$1, b.$2, unit: unit);
}

/// Same calculation for numbers you already have (e.g. a GPS position),
/// so you don't have to build a string just to parse it again.
double distanceBetween(
  double lat1,
  double lon1,
  double lat2,
  double lon2, {
  String unit = 'meter',
}) {
  if (lat1.abs() > 90 || lat2.abs() > 90 || lon1.abs() > 180 || lon2.abs() > 180) {
    throw ArgumentError('Latitude or longitude is out of range.');
  }

  const earthRadius = 6371000.0; // meters
  final phi1 = lat1 * math.pi / 180;
  final phi2 = lat2 * math.pi / 180;
  final deltaLat = phi2 - phi1;
  final deltaLon = (lon2 - lon1) * math.pi / 180;

  final sinLat = math.sin(deltaLat / 2);
  final sinLon = math.sin(deltaLon / 2);
  final a = (sinLat * sinLat + math.cos(phi1) * math.cos(phi2) * sinLon * sinLon)
      .clamp(0.0, 1.0)
      .toDouble();

  final meters = earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

  final distance = switch (unit.trim().toLowerCase()) {
    'km' || 'kilometer' || 'kilometers' => meters / 1000,
    'mi' || 'mile' || 'miles' => meters / 1609.344,
    'ft' || 'foot' || 'feet' => meters * 3.280839895,
    'yd' || 'yard' || 'yards' => meters * 1.093613298,
    'm' || 'meter' || 'meters' => meters,
    _ => throw ArgumentError('Unsupported distance unit: $unit'),
  };

  return double.parse(distance.toStringAsFixed(3));
}

(double, double) _parseLatLong(String value) {
  final parts = value.split(',').map((p) => p.trim()).toList();
  if (parts.length != 2) {
    throw ArgumentError('Invalid location format. Expected latitude,longitude.');
  }

  final lat = double.tryParse(parts[0]);
  final lon = double.tryParse(parts[1]);
  if (lat == null || lon == null) {
    throw ArgumentError('Invalid location format. Expected latitude,longitude.');
  }
  return (lat, lon);
}