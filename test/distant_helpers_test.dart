import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/utils/helpers/distant_helpers.dart';

void main() {
  test('compares latitude,longitude pairs in meters', () {
    expect(calculateDistanceMeters('0,0', '0,0'), 0);
    expect(
      calculateDistanceMeters('0,0', '0.01,0'),
      closeTo(1111.949267, 0.001),
    );
    expect(
      calculateDistanceMeters(
        '11.547273130564294, 104.90898218012883',
        '11.54732899907136,104.9089653152003',
      ),
      closeTo(6.48, 0.01),
    );
  });

  test(
    'radius checks keep precision while display distances remain rounded',
    () {
      const point = '0.000899325203212,0';
      expect(calculateDistance('0,0', point), 100);
      expect(calculateDistanceMeters('0,0', point), greaterThan(100));
      expect(calculateDistance('0,0', '0.01,0', unit: 'km'), 1.112);
    },
  );

  test('invalid coordinates cannot produce an acceptable distance', () {
    for (final location in [
      'NaN,104.9',
      '11.5,Infinity',
      '91,0',
      '0,-181',
      '104.9,11.5',
      '11.5',
      '11.5,104.9,1',
      'invalid',
    ]) {
      expect(
        () => calculateDistanceMeters(location, '11.5,104.9'),
        throwsArgumentError,
        reason: location,
      );
    }
  });
}
