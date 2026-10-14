import 'package:get/get.dart';
import 'package:test_flutter/features/authentication/screens/login/login_binding.dart';
import 'package:test_flutter/features/authentication/screens/login/login_screen.dart';
import 'package:test_flutter/features/authentication/screens/onboarding/onboarding.dart';
import 'package:test_flutter/features/hrms_app/screens/attend/attendance_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/home/home_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/leave_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/payroll/payroll_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/profile/profile_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/reports/report_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/overtime/overtime_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/schedule/schedule_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingScreen()),
    GetPage(name: AppRoutes.login, page: () => const LoginScreen(), binding: LoginBinding()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.attendance, page: () => const AttendanceScreen()),
    GetPage(name: AppRoutes.leave, page: () => const LeaveScreen()),
    GetPage(name: AppRoutes.schedule, page: () => const ScheduleScreen()),
    GetPage(name: AppRoutes.overtime, page: () => const OvertimeScreen()),
    GetPage(name: AppRoutes.payroll, page: () => const PayrollScreen()),
    GetPage(name: AppRoutes.reports, page: () => const ReportScreen()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
  ];
}
