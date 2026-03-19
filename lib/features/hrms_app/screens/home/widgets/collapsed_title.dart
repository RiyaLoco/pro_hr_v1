import 'package:flutter/material.dart';
import 'package:test_flutter/utils/constants/image_string.dart';


class CollapsedTitle extends StatelessWidget {
  const CollapsedTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.white.withOpacity(0.3),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(ImageString.profile1),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Hello, Riya !',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text('Mobile Developer',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.85), fontSize: 11)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: Colors.white, size: 24),
          onPressed: () {},
        ),
      ],
    );
  }
}