import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/app_contents.dart';
import 'package:test_flutter/features/hrms_app/controllers/home_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? image;
  final bool isShowProfile;
  final Color? backgroundColor;
  final Color? curveColor;
  final double? expandedHeight;
  final double? bottomCurveHeight;
  final double curveRadius;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onBackTap;

  const CustomSliverAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.image,
    this.isShowProfile = true,
    this.backgroundColor,
    this.curveColor,
    this.expandedHeight,
    this.bottomCurveHeight,
    this.curveRadius = 30,
    this.onNotificationTap,
    this.onBackTap,
  });
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final resolvedExpandedHeight = expandedHeight ?? controller.expandedHeight;

    // Detail screen — no expand/collapse, simple fixed appbar
    if (!isShowProfile) {
      return SliverAppBar(
        backgroundColor: backgroundColor ?? PColor.primary,
        pinned: true,
        floating: false,
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        title: AppBarContent.detail(
          title: title ?? '',
          subtitle: subtitle ?? '',
          onBackTap: onBackTap,
        ),
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(resolvedCurveHeight),
        //   child: Container(
        //     height: resolvedCurveHeight,
        //     width: double.infinity,
        //     decoration: BoxDecoration(
        //       color: curveColor ?? Colors.grey[100],
        //       borderRadius: BorderRadius.only(
        //         topLeft: Radius.circular(curveRadius),
        //         topRight: Radius.circular(curveRadius),
        //       ),
        //     ),
        //   ),
        // ),
      );
    }

    // Home screen — expandable with profile avatar
    return SliverAppBar(
      backgroundColor: backgroundColor ?? PColor.primary,
      expandedHeight: resolvedExpandedHeight,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight,
      title: Obx(
        () => controller.isCollapsed.value
            ? AppBarContent.collapsed(
                title: title ?? '',
                subtitle: subtitle ?? '',
                image: image,
                isShowProfile: isShowProfile,
                onNotificationTap: onNotificationTap,
                onBackTap: onBackTap,
              )
            : const SizedBox.shrink(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.zero,
        collapseMode: CollapseMode.parallax,
        background: AppBarContent.expanded(
          title: title ?? '',
          subtitle: subtitle ?? '',
          image: image,
          isShowProfile: isShowProfile,
          onNotificationTap: onNotificationTap,
          onBackTap: onBackTap,
        ),
      ),
      // bottom: PreferredSize(
      //   preferredSize: Size.fromHeight(resolvedCurveHeight),
      //   child: Container(
      //     height: resolvedCurveHeight,
      //     width: double.infinity,
      //     decoration: BoxDecoration(
      //       color: curveColor ?? Colors.grey[100],
      //       borderRadius: BorderRadius.only(
      //         topLeft: Radius.circular(curveRadius),
      //         topRight: Radius.circular(curveRadius),
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
