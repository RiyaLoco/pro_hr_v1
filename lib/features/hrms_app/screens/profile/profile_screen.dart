import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:test_flutter/common/widgets/app_container.dart';
import 'package:test_flutter/common/widgets/custom_sliver_appbar.dart';
import 'package:test_flutter/data/services/app_url_service.dart';
import 'package:test_flutter/features/hrms_app/controllers/profile_controller.dart';
import 'package:test_flutter/utils/constants/colors.dart';
import 'package:test_flutter/utils/constants/image_string.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: PColor.primary,
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            title: 'My Profile',
            subtitle: 'View your profile information',
            isShowProfile: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(controller, context),
                  const SizedBox(height: 24),
                  _buildLogoutButton(controller),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, ProfileController controller) {
    return Center(
      child: Column(
        children: [
          Obx(
            () => Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.white,
                  backgroundImage: controller.profileImage.value != null
                      ? FileImage(controller.profileImage.value!) as ImageProvider
                      : controller.avatarUrl.value != null &&
                              controller.avatarUrl.value!.trim().isNotEmpty
                          ? NetworkImage(AppUrlService.fileUrl(controller.avatarUrl.value!))
                          : const AssetImage(ImageString.profile1),
                ),
                if (controller.isUploading.value)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black38),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Material(
                    color: PColor.primary,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => controller.changeProfilePicture(context),
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () => Text(
              controller.name.value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: PColor.primary),
            ),
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              controller.position.value,
              style: TextStyle(fontSize: 14, color: PColor.textColor),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Info card ----
  Widget _buildInfoCard(ProfileController controller, BuildContext context) {
    return AppContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 16),
      child: Obx(
        () => Column(
          children: [
            _buildAvatarSection(context, controller),
            const SizedBox(height: 20),
            _InfoRow(icon: Icons.badge_outlined, label: 'Employee ID', value: controller.employeeId.value),
            Divider(color: Colors.grey[200], height: 1),
            _InfoRow(icon: Icons.email_outlined, label: 'Email', value: controller.email.value),
            Divider(color: Colors.grey[200], height: 1),
            _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: controller.phone.value),
            Divider(color: Colors.grey[200], height: 1),
            _InfoRow(icon: Icons.apartment_outlined, label: 'Department', value: controller.department.value),
            Divider(color: Colors.grey[200], height: 1),
            _InfoRow(icon: Icons.calendar_today_outlined, label: 'Joined', value: controller.joinDate.value),
          ],
        ),
      ),
    );
  }

  // ---- Logout ----
  Widget _buildLogoutButton(ProfileController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.logout,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.logout, color: Colors.white, size: 18),
        label: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 16, color: PColor.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 13, color: PColor.textColor)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: PColor.primary))),
        ],
      ),
    );
  }
}
