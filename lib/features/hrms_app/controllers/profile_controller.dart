import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/user_models.dart';
import 'package:intl/intl.dart';
import 'package:test_flutter/features/authentication/controllers/login_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/widgets/selection_bottom_sheet.dart';
import 'package:test_flutter/routes/app_routes.dart';

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
  late final Worker _accountWorker;

  @override
  void onInit() {
    super.onInit();
    final login = Get.find<LoginController>();
    _applyAccount(login.user.value?.user);
    _accountWorker = ever(login.user, (value) {
      profileImage.value = null;
      _applyAccount(value?.user);
    });
  }

  void _applyAccount(User? account) {
    final employee = account?.employee;
    name.value = _firstValue([
      employee?.name,
      account?.name,
      account?.username,
    ]);
    position.value = _firstValue([employee?.position]);
    employeeId.value = _firstValue([
      employee?.code,
      employee?.id?.toString(),
      account?.employeeId?.toString(),
    ]);
    email.value = _firstValue([employee?.email, account?.email]);
    phone.value = _firstValue([employee?.phone, account?.phone]);
    department.value = _firstValue([employee?.department]);
    final rawDate = employee?.joinDate;
    final date = rawDate == null ? null : DateTime.tryParse(rawDate);
    joinDate.value = date == null
        ? _firstValue([rawDate])
        : DateFormat('dd MMM yyyy').format(date);
    final avatar = _firstValue([
      employee?.avatarUrl,
      account?.avatarUrl,
      account?.avatar,
    ]);
    avatarUrl.value = avatar == '—' ? null : avatar;
  }

  String _firstValue(List<String?> values) => values
      .whereType<String>()
      .map((value) => value.trim())
      .firstWhere((value) => value.isNotEmpty, orElse: () => '—');

  @override
  void onClose() {
    _accountWorker.dispose();
    super.onClose();
  }

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
