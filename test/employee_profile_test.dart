import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/user_models.dart';
import 'package:test_flutter/features/authentication/controllers/login_controller.dart';
import 'package:test_flutter/features/hrms_app/controllers/profile_controller.dart';

void main() {
  tearDown(() => Get.reset());

  test('profile displays the linked employee from the login response', () {
    final result = UserModels.fromJson({
      'user': {
        'id': 4,
        'name': 'ACCOUNT NAME',
        'email': 'employee@example.com',
        'avatar_url': 'https://example.com/avatar.jpg',
        'employee': {
          'id': 1,
          'employee_code': '0001',
          'f_name': 'Him',
          'l_name': 'Riya',
          'hire_date': '2026-09-15',
          'avatar': null,
          'department': {'id': 1, 'name': 'Sales & Marketing'},
          'position': {'id': 1, 'name': 'Senior Accountant Officer'},
        },
      },
    });
    final login = Get.put(LoginController());
    login.user.value = result;
    final profile = Get.put(ProfileController());

    expect(result.user?.employeeId, 1);
    expect(profile.employeeId.value, '0001');
    expect(profile.name.value, 'Him Riya');
    expect(profile.position.value, 'Senior Accountant Officer');
    expect(profile.department.value, 'Sales & Marketing');
    expect(profile.joinDate.value, '15 Sep 2026');
    expect(profile.email.value, 'employee@example.com');
    expect(profile.avatarUrl.value, 'https://example.com/avatar.jpg');
    expect(profile.phone.value, '—');

    login.user.value = UserModels.fromJson({
      'user': {'name': 'Next Account', 'role': 'Admin'},
    });
    expect(profile.name.value, 'Next Account');
    expect(profile.department.value, '—');
    expect(profile.position.value, '—');
    expect(profile.employeeId.value, '—');
    expect(profile.joinDate.value, '—');
    expect(profile.avatarUrl.value, isNull);
  });
}
