import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class AppBarContent extends StatelessWidget {
  final double avatarRadius;
  final double nameFontSize;
  final double roleFontSize;
  final double iconSize;
  final String title;
  final String subtitle;
  final VoidCallback? onNotificationTap;
  final EdgeInsetsGeometry padding;
  final String? image;
  final bool isShowProfile;
  final VoidCallback? onBackTap;

  const AppBarContent({
    super.key,
    required this.avatarRadius,
    required this.nameFontSize,
    required this.roleFontSize,
    required this.iconSize,
    required this.title,
    required this.subtitle,
    this.onNotificationTap,
    this.padding = EdgeInsets.zero,
    this.image,
    this.isShowProfile = true,
    this.onBackTap,
  });

  factory AppBarContent.collapsed({
    required String title,
    required String subtitle,
    String? image,
    VoidCallback? onNotificationTap,
    bool isShowProfile = true,
    VoidCallback? onBackTap,
  }) {
    return AppBarContent(
      avatarRadius: 20,
      nameFontSize: 16,
      roleFontSize: 11,
      iconSize: 24,
      title: title,
      subtitle: subtitle,
      padding: EdgeInsets.zero,
      onNotificationTap: onNotificationTap,
      image: image,
      isShowProfile: isShowProfile,
      onBackTap: onBackTap,
    );
  }

  factory AppBarContent.expanded({
    required String title,
    required String subtitle,
    String? image,
    VoidCallback? onNotificationTap,
    bool isShowProfile = true,
    VoidCallback? onBackTap,
  }) {
    return AppBarContent(
      avatarRadius: 26,
      nameFontSize: 20,
      roleFontSize: 14,
      iconSize: 26,
      title: title,
      subtitle: subtitle,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      onNotificationTap: onNotificationTap,
      image: image,
      isShowProfile: isShowProfile,
      onBackTap: onBackTap,
    );
  }
  factory AppBarContent.detail({
    required String title,
    required String subtitle,
    VoidCallback? onBackTap,
  }) {
    return AppBarContent(
      avatarRadius: 0,
      nameFontSize: 22,
      roleFontSize: 14,
      iconSize: 0,
      title: title,
      subtitle: subtitle,
      isShowProfile: false,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      onBackTap: onBackTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            if (isShowProfile)
              CircleAvatar(
                radius: avatarRadius + 2,
                backgroundColor: Colors.white.withOpacity(0.3),
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundImage: image != null ? AssetImage(image!) : null,
                  child: image == null
                      ? Icon(
                          Icons.person,
                          color: Colors.white,
                          size: avatarRadius,
                        )
                      : null,
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: onBackTap ?? () => Get.back(),
              ),
            const SizedBox(width: 12),

            // Name + Role
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: roleFontSize,
                    ),
                  ),
                ],
              ),
            ),

            // Notification Icon
            IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: iconSize,
              ),
              onPressed: onNotificationTap ?? () {},
            ),
          ],
        ),
      ),
    );
  }
}
