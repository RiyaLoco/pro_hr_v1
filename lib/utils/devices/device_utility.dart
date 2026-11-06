import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DeviceUtils {
  static const double tabletBreakpoint = 600;
  static const double desktopBreakpoint = 1024;

  static BuildContext _resolveContext(BuildContext? context) {
    final resolvedContext = context ?? Get.context;
    if (resolvedContext == null) {
      throw FlutterError(
        'DeviceUtils needs a BuildContext below a MediaQuery. '
        'Pass the current widget context when reading device dimensions.',
      );
    }
    return resolvedContext;
  }

  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static Future<void> setStatusBarColor(Color color) async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: color),
    );
  }

  static bool isLandscapeOrientation(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  static bool isPortraitOrientation(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.portrait;
  }

  static void setFullScreen(bool enable) {
    SystemChrome.setEnabledSystemUIMode(
      enable ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  static Size getScreenSize([BuildContext? context]) {
    return MediaQuery.sizeOf(_resolveContext(context));
  }

  static double getScreenHeight([BuildContext? context]) {
    return getScreenSize(context).height;
  }

  static double getScreenWidth([BuildContext? context]) {
    return getScreenSize(context).width;
  }

  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) < tabletBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return getScreenWidth(context) >= desktopBreakpoint;
  }

  static double getPixelRatio([BuildContext? context]) {
    return MediaQuery.devicePixelRatioOf(_resolveContext(context));
  }

  static double getStatusBarHeight([BuildContext? context]) {
    return MediaQuery.paddingOf(_resolveContext(context)).top;
  }

  static double getBottomNavigationBarHeight() {
    return kBottomNavigationBarHeight;
  }

  static double getAppBarHeight() {
    return kToolbarHeight;
  }

  static double getKeyboardHeight([BuildContext? context]) {
    return MediaQuery.viewInsetsOf(_resolveContext(context)).bottom;
  }

  static Future<bool> isKeyboardVisible([BuildContext? context]) async {
    return getKeyboardHeight(context) > 0;
  }

  static Future<bool> isPhysicalDevice() async {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static void vibrated(Duration duration) {
    HapticFeedback.vibrate();
    Future.delayed(duration, () => HapticFeedback.vibrate());
  }

  static Future<void> setPreferredOrientations(
    List<DeviceOrientation> orientations,
  ) async {
    await SystemChrome.setPreferredOrientations(orientations);
  }

  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  static void showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
  }

  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static bool isIos() {
    return Platform.isIOS;
  }

  static bool isAndroid() {
    return Platform.isAndroid;
  }

  static void launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
