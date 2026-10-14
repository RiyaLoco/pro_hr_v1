import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/services/app_url_service.dart';

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
    Key? key,
    required String title,
    required String subtitle,
    String? image,
    VoidCallback? onNotificationTap,
    bool isShowProfile = true,
    VoidCallback? onBackTap,
  }) {
    return AppBarContent(
      key: key,
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
      nameFontSize: 22,
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
      nameFontSize: 17,
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
    final imageProvider = _imageProvider(image);

    return GestureDetector(
      onTap: () => Get.toNamed('/profile'),
      child: SafeArea(
        child: Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              if (isShowProfile)
                CircleAvatar(
                  radius: avatarRadius + 2,
                  backgroundColor: Colors.white.withValues(alpha: 0.3),
                  child: CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    backgroundImage: imageProvider,
                    onBackgroundImageError: imageProvider != null
                        ? (exception, stackTrace) {
                            debugPrint('Avatar failed to load: $exception');
                          }
                        : null,
                    child: imageProvider == null
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
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
      ),
    );
  }

  ImageProvider? _imageProvider(String? image) {
    if (image == null || image.trim().isEmpty) return null;

    final path = image.trim();
    if (path.startsWith('assets/')) return AssetImage(path);

    return NetworkImage(AppUrlService.fileUrl(path));
  }
}
