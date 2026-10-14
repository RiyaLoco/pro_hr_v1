 
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:test_flutter/routes/app_pages.dart';
import 'package:test_flutter/routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      // home: OnboardingScreen(),
      initialRoute: AppRoutes.onboarding,
      getPages: AppPages.pages,
      
    );
  }
}

