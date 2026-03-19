
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/features/authentication/screens/login/login_screen.dart';

class OnboardingController extends GetxController{
  static OnboardingController get instance => Get.find();

  final pageController = PageController();
  Rx<int> currentIndex = 0.obs;

  void updatePageIndicator(index) => currentIndex.value = index;

   void dotNavigationClick(index){
    currentIndex.value = index;
    pageController.jumpTo(index);
  }
  void nextPage(){
    if(currentIndex.value == 2){
      Get.offAll(LoginScreen());
    }
    else{
      int page = currentIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }
  void skipPage(){
    currentIndex.value = 2;
    pageController.jumpToPage(2);
  }
}