import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:test_flutter/features/hrms_app/screens/home/home_screen.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/image_string.dart';
import 'package:test_flutter/utils/constants/size.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: 80, horizontal: Sizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image(
                height: 100,
                width: 250,
                image: AssetImage(ImageString.logo),
              ),
              SizedBox(height: Sizes.spaceBtwItems,),
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
                  color: PColor.primary.withOpacity(0.7),
                ),
              ),
              SizedBox(
                height: Sizes.spaceBtwSections,
              ),
              SizedBox(
                height: 80,
                child: TextFormField(
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
                      labelStyle:
                          TextStyle(fontSize: 16, color: PColor.subTitleColor)),
                ),
              ),
              SizedBox(
                height: 80,
                child: TextFormField(
                  decoration: InputDecoration(
                      filled: true,
                      fillColor: PColor.textFormFileColor,
                      prefixIcon: Icon(
                        Iconsax.lock,
                        color: PColor.subTitleColor,
                      ),
                      suffixIcon: Icon(Iconsax.eye_slash, color: PColor.subTitleColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      labelText: 'Password',
                      labelStyle:
                          TextStyle(fontSize: 16, color: PColor.subTitleColor)),
                ),
              ),
              SizedBox(
                height: Sizes.spaceBtwItems,
              ),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: ()=> Get.off(HomeScreen()),
                  child: Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
