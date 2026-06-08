import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/user_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/home/home_screen.dart';
import 'package:test_flutter/routes/app_routes.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordFocusNode = FocusNode();
  final apiController = ApiController();

  var isPasswordHidden = true.obs;
  var isLoading = false.obs;

  final Rx<UserModels?> user = Rxn<UserModels?>(null);

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Login failed', 'Please enter your email and password.');
      return;
    }

    try {
      isLoading.value = true;
      final result = await apiController.login(email, password);

      if (result.isSuccess && result.token != null) {
        user.value = result;
        Get.offAllNamed(AppRoutes.home);
        return;
      }

      Get.snackbar(
        'Login failed',
        result.message ?? 'Invalid email or password.',
      );
    } on DioException catch (e) {
      final responseData = e.response?.data;
      final serverMessage = responseData is Map<String, dynamic>
          ? responseData['message']?.toString()
          : null;

      Get.snackbar(
        'Connection failed',
        serverMessage ??
            e.message ??
            'Could not connect to the server. Check Laravel is running on 192.168.1.4:8000.',
      );
    } catch (e) {
      Get.snackbar(
        'Login failed',
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }
}
