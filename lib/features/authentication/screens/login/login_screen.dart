import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:test_flutter/features/authentication/controllers/login_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/image_string.dart';
import 'package:test_flutter/utils/constants/size.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController(), permanent: true);
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: 80,
              horizontal: Sizes.defaultSpace,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image(
                  height: 100,
                  width: 250,
                  image: AssetImage(ImageString.logo),
                ),
                SizedBox(height: Sizes.spaceBtwItems),
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: PColor.primary,
                  ),
                ),
                Text(
                  "Enter your email and password",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: PColor.primary.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: Sizes.spaceBtwSections),
                SizedBox(
                  height: 80,
                  child: TextFormField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: PColor.textFormFileColor,
                      prefixIcon: Icon(
                        Iconsax.user,
                        color: PColor.subTitleColor,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        fontSize: 16,
                        color: PColor.subTitleColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: Obx(
                    () => TextFormField(
                      controller: controller.passwordController,
                      focusNode: controller.passwordFocusNode,
                      obscureText: controller.isPasswordHidden.value,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: PColor.textFormFileColor,
                        prefixIcon: Icon(
                          Iconsax.lock,
                          color: PColor.subTitleColor,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isPasswordHidden.value
                                ? Iconsax.eye_slash
                                : Iconsax.eye,
                            color: PColor.subTitleColor,
                          ),
                          onPressed: () {
                            controller.togglePasswordVisibility();
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          fontSize: 16,
                          color: PColor.subTitleColor,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: Sizes.spaceBtwItems),
                SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.login,
                      child: controller.isLoading.value
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
