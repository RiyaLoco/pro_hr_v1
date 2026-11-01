import 'package:flutter/material.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/helpers/distant_helpers.dart';


/// UI-only stand-in for the map. Swap the painted background for a real map
/// later (e.g. flutter_map or google_maps_flutter) and keep the distance chip.
///
/// Give it the user's and the office's "latitude,longitude" and it shows how
/// far apart they are, and whether that is inside [allowedRadiusMeters].
/// This is a preview only: the Laravel API makes the real decision.
class LocationHelpers extends StatelessWidget {
  final String? userLatLong;
  final String? officeLatLong;
  final double allowedRadiusMeters;

  const LocationHelpers({
    super.key,
    this.userLatLong,
    this.officeLatLong,
    this.allowedRadiusMeters = 100,
  });

  /// Distance in meters, or null if a location is missing or invalid.
  double? get _distanceMeters {
    final user = userLatLong;
    final office = officeLatLong;
    if (user == null || office == null) return null;
    try {
      return calculateDistance(user, office);
    } on ArgumentError {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final distance = _distanceMeters;

    return Stack(
      fit: StackFit.expand,
      children: [
        CustomPaint(painter: _RoadsPainter()),
        // Current-location pin, a little above the centre so the bottom
        // card doesn't cover it.
        Align(
          alignment: const Alignment(0, -0.3),
          child: Icon(Icons.location_on, size: 52, color: PColor.primary),
        ),
        if (distance != null)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: _DistanceChip(
                distanceMeters: distance,
                inRange: distance <= allowedRadiusMeters,
              ),
            ),
          ),
      ],
    );
  }
}

class _DistanceChip extends StatelessWidget {
  final double distanceMeters;
  final bool inRange;

  const _DistanceChip({required this.distanceMeters, required this.inRange});

  static const Color _outColor = Color(0xFFD9534F);

  String get _distanceText => distanceMeters < 1000
      ? '${distanceMeters.round()} m'
      : '${(distanceMeters / 1000).toStringAsFixed(2)} km';

  @override
  Widget build(BuildContext context) {
    final color = inRange ? PColor.primary : _outColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(inRange ? Icons.check_circle : Icons.warning_amber_rounded, size: 18, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              inRange
                  ? 'You are $_distanceText from the office'
                  : '$_distanceText from the office, outside the allowed area',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadsPainter extends CustomPainter {
  // Each road is (x1, y1, x2, y2) as a fraction of the width / height.
  static const List<List<double>> _minorRoads = [
    [0.00, 0.12, 1.00, 0.08],
    [0.00, 0.30, 1.00, 0.34],
    [0.00, 0.52, 1.00, 0.48],
    [0.00, 0.72, 1.00, 0.76],
    [0.15, 0.00, 0.10, 1.00],
    [0.38, 0.00, 0.42, 1.00],
    [0.62, 0.00, 0.58, 1.00],
    [0.85, 0.00, 0.90, 1.00],
  ];

  static const List<List<double>> _majorRoads = [
    [0.00, 0.95, 1.00, 0.20],
    [0.50, 0.00, 0.46, 1.00],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFD9D4C8));

    final minor = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final major = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    void drawRoads(List<List<double>> roads, Paint paint) {
      for (final r in roads) {
        canvas.drawLine(
          Offset(size.width * r[0], size.height * r[1]),
          Offset(size.width * r[2], size.height * r[3]),
          paint,
        );
      }
    }

    drawRoads(_minorRoads, minor);
    drawRoads(_majorRoads, major);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}