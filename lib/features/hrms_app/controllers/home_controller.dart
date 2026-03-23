import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  late ScrollController scrollController;
  final isCollapsed = false.obs;
  final bottomCurveHeight = 20.0;
  final expandedHeight = 110.0;
  double get totalExpandedHeight => expandedHeight + bottomCurveHeight;
  final currentTime = ''.obs;
  final currentDate = ''.obs;
  Timer? _timer;

  final isPunchedIn = false.obs;
  final checkInTime = ''.obs;
  final checkOutTime = ''.obs;
  final timeWorking = ''.obs;
  DateTime? _checkInDateTime;
  Timer? _workingTimer;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    _startClock();
  }

  void _onScroll() {
    final collapsed =
        scrollController.offset > (expandedHeight - kToolbarHeight - 20);
    if (collapsed != isCollapsed.value) {
      isCollapsed.value = collapsed;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
    _timer?.cancel();
    _workingTimer?.cancel();
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    currentTime.value = DateFormat('h:mm a').format(now);
    currentDate.value = DateFormat('EEE d MMM yyyy').format(now);
  }

  void onPunchTap() {
    if (!isPunchedIn.value) {
      _punchIn();
    } else {
      _punchOut();
    }
  }

  void _punchIn() {
    _checkInDateTime = DateTime.now();
    checkInTime.value = DateFormat('h:mm a').format(_checkInDateTime!);
    checkOutTime.value = '--:--';
    timeWorking.value = '00:00';
    isPunchedIn.value = true;

    // Start working time counter
    _workingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final diff = DateTime.now().difference(_checkInDateTime!);
      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
      timeWorking.value = '$hours:$minutes:$seconds';
    });
  }

  void _punchOut() {
    _workingTimer?.cancel();
    final now = DateTime.now();
    checkOutTime.value = DateFormat('h:mm a').format(now);
    isPunchedIn.value = false;
  }
}
