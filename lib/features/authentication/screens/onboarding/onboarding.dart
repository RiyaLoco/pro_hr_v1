import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/features/authentication/controllers/onboarding_controller.dart';
import 'package:test_flutter/features/authentication/screens/onboarding/widgets/onboarding_dot_navigation.dart';
import 'package:test_flutter/features/authentication/screens/onboarding/widgets/onboarding_next_button.dart';
import 'package:test_flutter/features/authentication/screens/onboarding/widgets/onboarding_page.dart';
import 'package:test_flutter/features/authentication/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:test_flutter/utils/constants/image_string.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 150 ),
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.updatePageIndicator,
              children: [
                OnboardingPage(
                  image: ImageString.onboarding1,
                  title: 'Build Your Dream Team',
                  subtitle: 'Find, track, and onboard \n top-tier talent without the paperwork headache.',
                ),
                OnboardingPage(
                  image: ImageString.onboarding2,
                  title: 'Work Better Together',
                  subtitle: 'Empower your employees \n with tools designed for collaboration and clarity.',
                ),
                OnboardingPage(
                  image: ImageString.onboarding3,
                  title: 'Scale with Confidence',
                  subtitle: 'Comprehensive HR reporting \n that helps you plan for the future of your company.',
                ),
              ],
            ),
          ),
          OnboardingSkip(),
          OnboardingDotNavigation(),
          OnboardingNextButton(),
        ],
      ),
    );
  }
}


