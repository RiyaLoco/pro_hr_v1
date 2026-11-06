import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/punch_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';
import 'package:test_flutter/data/services/location_service.dart';
import 'package:test_flutter/features/hrms_app/screens/home/widgets/qr_screen.dart';

/// Today's attendance for the home card.
///
/// Check in: scan the office QR code and submit the phone's GPS position.
/// Check out: require the same QR and submit a fresh GPS position.
/// The server decides whether the position is inside the allowed radius.
class PunchController extends GetxController {
  PunchController({ApiController? api}) : _api = api ?? ApiController();

  final RxBool isCheckedIn = false.obs;
  final RxBool isCheckedOut = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPunching = false.obs;

  /// Formatted for the card ('' means "not yet").
  final RxString checkInTime = ''.obs;
  final RxString checkOutTime = ''.obs;
  final RxString timeWorking = ''.obs;

  final ApiController _api;
  final LocationService _location = LocationService();

  int? _checkInSeconds;
  int? _checkOutSeconds;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    fetchToday();
    // Keeps "Times Working" ticking while the user is checked in.
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _refreshWorking(),
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  Future<void> fetchToday() async {
    isLoading.value = true;
    try {
      final today = await _api.fetchTodayAttendance();

      isCheckedIn.value = today.checkedIn;
      isCheckedOut.value = today.checkedOut;

      _checkInSeconds = _toSeconds(today.checkInTime);
      _checkOutSeconds = _toSeconds(today.checkOutTime);
      checkInTime.value = _checkInSeconds == null
          ? ''
          : _clock(_checkInSeconds!);
      checkOutTime.value = _checkOutSeconds == null
          ? ''
          : _clock(_checkOutSeconds!);
      _refreshWorking();
    } on ApiException catch (e) {
      Get.snackbar('Attendance', e.displayMessage);
    } catch (_) {
      // Quiet on the home screen when offline; the card keeps its last state.
    } finally {
      isLoading.value = false;
    }
  }

  /// What the round button does depends on today's state.
  Future<void> onButtonTap() async {
    if (isPunching.value || isLoading.value) return;

    if (isCheckedOut.value) {
      Get.snackbar('Done', "You have already completed today's attendance.");
    } else if (isCheckedIn.value) {
      await scanAndCheckOut();
    } else {
      await scanAndCheckIn();
    }
  }

  Future<void> scanAndCheckIn() => _scanAndPunch(isCheckIn: true);

  Future<void> scanAndCheckOut() => _scanAndPunch(isCheckIn: false);

  Future<void> _scanAndPunch({required bool isCheckIn}) async {
    if (isPunching.value || isLoading.value) return;
    isPunching.value = true;
    try {
      // Validate the type and location permission before opening the camera.
      final typeId = await _typeIdFor(isCheckIn);
      await _location.ensurePermission();
      final qr = await Get.to<String>(() => QrScanScreen(isCheckIn: isCheckIn));
      if (qr == null || qr.trim().isEmpty) return;

      await _punch(
        isCheckIn: isCheckIn,
        attendanceTypeId: typeId,
        qrCode: qr.trim(),
      );
    } on LocationException catch (e) {
      _showLocationProblem(e);
    } on ApiException catch (e) {
      Get.snackbar('Could not check attendance', e.displayMessage);
    } catch (_) {
      Get.snackbar(
        'Could not check attendance',
        'Check your connection and try again.',
      );
    } finally {
      isPunching.value = false;
    }
  }

  Future<void> _punch({
    required bool isCheckIn,
    required int attendanceTypeId,
    required String qrCode,
  }) async {
    try {
      final position = await _location.getCurrentPosition();
      final result = await _api.recordAttendance(
        isCheckIn: isCheckIn,
        attendanceTypeId: attendanceTypeId,
        latitude: position.latitude,
        longitude: position.longitude,
        qrCode: qrCode,
      );

      // Reload verified records after either outcome to clear stale card state.
      await fetchToday();
      if (result.success) {
        Get.snackbar(result.outcomeTitle(isCheckIn: isCheckIn), result.message);
      } else {
        Get.snackbar('Outside the allowed area', result.outOfRangeMessage);
      }
    } on LocationException catch (e) {
      _showLocationProblem(e);
    } on ApiException catch (e) {
      // e.g. "You have already checked in today." / "Check in before checking out."
      Get.snackbar('Could not check attendance', e.displayMessage);
    } catch (_) {
      Get.snackbar(
        'Could not check attendance',
        'Check your connection and try again.',
      );
    }
  }

  /// Reload types for each scan so deleted or changed IDs are not reused.
  Future<int> _typeIdFor(bool isCheckIn) async {
    final types = await _api.fetchAttendanceTypes();
    try {
      return PunchType.forDirection(types, isCheckIn: isCheckIn).id;
    } on StateError catch (e) {
      throw ApiException(e.message);
    }
  }

  void _showLocationProblem(LocationException e) {
    Get.dialog(
      AlertDialog(
        title: const Text('Location needed'),
        content: Text(e.message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          if (e.canOpenAppSettings)
            TextButton(
              onPressed: () {
                Get.back();
                _location.openAppSettings();
              },
              child: const Text('Open settings'),
            ),
          if (e.canOpenLocationSettings)
            TextButton(
              onPressed: () {
                Get.back();
                _location.openLocationSettings();
              },
              child: const Text('Turn on GPS'),
            ),
        ],
      ),
    );
  }

  // ---- Time helpers ('HH:mm:ss' from the server) ----

  int? _toSeconds(String? hms) {
    if (hms == null || hms.isEmpty) return null;
    final parts = hms.split(':');
    if (parts.length < 2) return null;

    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final s = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    if (h == null || m == null) return null;
    return h * 3600 + m * 60 + s;
  }

  /// 32700 -> '9:05 AM'
  String _clock(int seconds) {
    final hour24 = (seconds ~/ 3600) % 24;
    final minute = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    return '$hour12:$minute ${hour24 < 12 ? 'AM' : 'PM'}';
  }

  /// Checked in -> from check-in until check-out (or until now).
  void _refreshWorking() {
    final start = _checkInSeconds;
    if (start == null) {
      timeWorking.value = '';
      return;
    }

    final now = DateTime.now();
    final nowSeconds = now.hour * 3600 + now.minute * 60 + now.second;
    final end = _checkOutSeconds ?? nowSeconds;

    final worked = end - start;
    if (worked < 0) {
      timeWorking.value = '';
      return;
    }

    final hours = worked ~/ 3600;
    final minutes = ((worked % 3600) ~/ 60).toString().padLeft(2, '0');
    timeWorking.value = '${hours}h ${minutes}m';
  }
}
