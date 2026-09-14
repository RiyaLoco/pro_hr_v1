import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/routes/app_routes.dart';

class OnboardingController extends GetxController {
  static OnboardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentIndex = 0.obs;

  void updatePageIndicator(int index) => currentIndex.value = index;

  void dotNavigationClick(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  void nextPage() {
    if (currentIndex.value == 2) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      int page = currentIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  void skipPage() {
    // currentIndex.value = 2;
    // pageController.jumpToPage(2);
    Get.offAllNamed(AppRoutes.login);
  }
}
