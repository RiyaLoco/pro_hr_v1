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
  }


  void _startClock() {
    _updateTime(); // set immediately on init
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    currentTime.value = DateFormat('h:mm a').format(now);   // 9:00 AM
    currentDate.value = DateFormat('EEE d MMM yyyy').format(now); // Wed 25 Feb 2026
  }
}
