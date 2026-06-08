import 'package:get/get.dart';
import 'package:test_flutter/features/authentication/controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginController(), permanent: true);
  }
}