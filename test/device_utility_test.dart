import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_flutter/utils/devices/device_utility.dart';
import 'package:test_flutter/utils/helpers/helper_function.dart';

void main() {
  testWidgets('orientation is independent of keyboard visibility', (
    tester,
  ) async {
    for (final size in [const Size(390, 844), const Size(844, 390)]) {
      for (final keyboardHeight in [0.0, 280.0]) {
        late BuildContext deviceContext;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: size,
                devicePixelRatio: 3,
                padding: const EdgeInsets.only(top: 24),
                viewInsets: EdgeInsets.only(bottom: keyboardHeight),
              ),
              child: Builder(
                builder: (context) {
                  deviceContext = context;
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        expect(
          DeviceUtils.isPortraitOrientation(deviceContext),
          size.height > size.width,
        );
        expect(
          DeviceUtils.isLandscapeOrientation(deviceContext),
          size.width > size.height,
        );
        expect(DeviceUtils.getKeyboardHeight(deviceContext), keyboardHeight);
        expect(
          await DeviceUtils.isKeyboardVisible(deviceContext),
          keyboardHeight > 0,
        );
        expect(DeviceUtils.getPixelRatio(deviceContext), 3);
        expect(DeviceUtils.getStatusBarHeight(deviceContext), 24);
      }
    }
  });

  testWidgets('dimensions and breakpoints use the supplied local context', (
    tester,
  ) async {
    for (final width in [320.0, 599.0, 600.0, 1023.0, 1024.0, 1440.0]) {
      late BuildContext deviceContext;
      final size = Size(width, 900);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: Builder(
              builder: (context) {
                deviceContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(DeviceUtils.getScreenSize(deviceContext), size);
      expect(DeviceUtils.getScreenWidth(deviceContext), width);
      expect(DeviceUtils.getScreenHeight(deviceContext), 900);
      expect(HelperFunctions.screenSize(deviceContext), size);
      expect(HelperFunctions.screenWidth(deviceContext), width);
      expect(HelperFunctions.screenHeight(deviceContext), 900);
      expect(DeviceUtils.isMobile(deviceContext), width < 600);
      expect(DeviceUtils.isTablet(deviceContext), width >= 600 && width < 1024);
      expect(DeviceUtils.isDesktop(deviceContext), width >= 1024);
    }
  });

  testWidgets('widgets update device dimensions after a window resize', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Text(
            '${DeviceUtils.getScreenWidth(context)} / '
            '${DeviceUtils.isLandscapeOrientation(context)}',
          ),
        ),
      ),
    );
    expect(find.text('390.0 / false'), findsOneWidget);

    tester.view.physicalSize = const Size(844, 390);
    await tester.pump();
    expect(find.text('844.0 / true'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
