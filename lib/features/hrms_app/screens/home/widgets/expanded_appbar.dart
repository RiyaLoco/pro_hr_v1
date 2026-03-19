import 'package:flutter/material.dart';
import 'package:test_flutter/utils/constants/image_string.dart';

class ExpandedAppBar extends StatelessWidget {
  const ExpandedAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.3),
              child: CircleAvatar(
                radius: 26,
                backgroundImage: AssetImage(ImageString.profile1),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, Riya !',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  
                  Text('Mobile Developer',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.white, size: 26),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}