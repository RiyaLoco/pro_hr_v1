import 'package:flutter/material.dart';
import 'package:test_flutter/common/widgets/app_contents.dart';
import 'package:test_flutter/utils/constants/image_string.dart';

class CollapsedTitle extends StatelessWidget {
  const CollapsedTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBarContent.collapsed(
      title: "Hello, Riya!",
      subtitle: "Mobile Developer",
      onNotificationTap: () {},
      image: ImageString.profile1,
    );
  }
}
