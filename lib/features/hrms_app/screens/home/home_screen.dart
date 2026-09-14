import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/data/services/app_url_service.dart';
import 'package:test_flutter/features/authentication/controllers/login_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/home_controller.dart';
import 'package:test_flutter/features/hrms_app/screens/home/widgets/attendance_card.dart';
import 'package:test_flutter/features/hrms_app/screens/home/widgets/home_menu_grid.dart';
import 'package:test_flutter/features/hrms_app/screens/home/widgets/recruitment_section.dart';
import 'package:test_flutter/utils/constants/image_string.dart';
import 'package:test_flutter/utils/constants/size.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final loginController = Get.find<LoginController>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Obx(() {
        final user = loginController.user.value;
        final userName = user?.user?.name ?? user?.user?.name ?? 'Guest';
        final userAvatar = user?.user?.avatarUrl;
          return CustomScrollView(
            controller: controller.scrollController,
            slivers: [
               CustomSliverAppBar(
                title: 'Hello, $userName',
                subtitle: 'Mobile Developer',
                image: userAvatar != null ? AppUrlService.fileUrl(userAvatar) : ImageString.profile1,
                isShowProfile: true,
              ),
              // Obx(() => SliverAppBar(
              //       backgroundColor: PColor.primary,
              //       expandedHeight: controller.expandedHeight,
              //       floating: false,
              //       pinned: true,
              //       automaticallyImplyLeading: false,
          
              //       title: controller.isCollapsed.value
              //           ? CollapsedTitle()
              //           : null,
              //       flexibleSpace: FlexibleSpaceBar(
              //         titlePadding: EdgeInsets.zero,
              //         background: ExpandedAppBar(),
              //       ),
              //       bottom: PreferredSize(
              //         preferredSize: Size.fromHeight(controller.bottomCurveHeight),
              //         child: Container(
              //           height: controller.bottomCurveHeight,
              //           width: double.infinity,
              //           decoration: BoxDecoration(
              //             color: Colors.grey[100],
              //             borderRadius: const BorderRadius.only(
              //               topLeft: Radius.circular(30),
              //               topRight: Radius.circular(30),
              //             ),
              //           ),
              //         ),
              //       ),
              //     )),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AttendanceCard(),
                      const SizedBox(height: Sizes.spaceBtwItems),
                      const MenuGrid(),
                      const SizedBox(height: Sizes.spaceBtwItems),
                      const RecruitmentSection(),
                      const SizedBox(height: Sizes.spaceBtwItems),
                      const RecruitmentSection(),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}
