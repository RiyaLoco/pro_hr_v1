import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:test_flutter/data/models/res/user_models.dart';
import 'package:test_flutter/data/services/app_url_service.dart';
import 'package:test_flutter/features/authentication/controllers/login_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/selection_bottom_sheet.dart';
import 'package:test_flutter/routes/app_routes.dart';

/// Controller for the user Profile screen — profile details plus
/// picking/uploading a new profile picture.
class ProfileController extends GetxController {
  final Rx<File?> profileImage = Rx<File?>(null);

  final RxString name = '—'.obs;
  final RxString position = '—'.obs;
  final RxString employeeId = '—'.obs;
  final RxString email = '—'.obs;
  final RxString phone = '—'.obs;
  final RxString department = '—'.obs;
  final RxString joinDate = '—'.obs;
  final RxnString avatarUrl = RxnString();

  final RxBool isUploading = false.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    final account = Get.find<LoginController>().user.value?.user;
    if (account != null) _applyAccount(account);
  }

  void _applyAccount(User account) {
    name.value = _valueOrFallback(account.name ?? account.username);
    position.value = _valueOrFallback(account.role);
    employeeId.value = account.employeeId?.toString() ?? '—';
    email.value = _valueOrFallback(account.email);
    avatarUrl.value = account.avatarUrl ?? account.avatar;
  }

  String _valueOrFallback(String? value) =>
      value == null || value.trim().isEmpty ? '—' : value.trim();

  void logout() {
    Get.find<LoginController>().user.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  /// Shows a Camera / Gallery choice, picks the image, then uploads it.
  Future<void> changeProfilePicture(BuildContext context) async {
    final source = await SelectionBottomSheet.show(
      context,
      title: 'Change Profile Picture',
      options: const [
        SelectionOption(value: 'camera', title: 'Take a Photo'),
        SelectionOption(value: 'gallery', title: 'Choose from Gallery'),
      ],
    );

    if (source == null) return;

    final pickedFile = await _picker.pickImage(
      source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (pickedFile == null) return;

    profileImage.value = File(pickedFile.path);
    await _uploadProfilePicture(profileImage.value!);
  }

  /// Hook up the real upload call (API / cloud storage) here.
  Future<void> _uploadProfilePicture(File file) async {
    isUploading.value = true;
    try {
      // TODO: upload `file` to your backend / storage and persist the URL.
    } finally {
      isUploading.value = false;
    }
  }
}
