import 'package:flutter/material.dart';
import 'package:test_flutter/features/authentication/controllers/onboarding_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/size.dart';
import 'package:test_flutter/utils/devices/device_utility.dart';

class OnboardingSkip extends StatelessWidget {
  const OnboardingSkip({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: DeviceUtils.getAppBarHeight(),
      right: Sizes.defaultSpace,
      child: TextButton(
        onPressed: () => OnboardingController.instance.skipPage(),
        child: Text(
          "Skip",
          style: TextStyle(color: PColor.primary),
        ),
      ),
    );
  }
}
