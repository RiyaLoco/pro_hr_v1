import 'package:get/get.dart';
import 'package:test_flutter/features/authentication/screens/login/login_binding.dart';
import 'package:test_flutter/features/authentication/screens/login/login_screen.dart';
import 'package:test_flutter/features/authentication/screens/onboarding/onboarding.dart';
import 'package:test_flutter/features/hrms_app/screens/attend/attendance_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/home/home_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/leave/leave_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/missions/mission_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/reports/report_screen.dart';
import 'package:test_flutter/features/hrms_app/screens/request/request_screen.dart';
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
    GetPage(name: AppRoutes.request, page: () => const RequestScreen()),
    GetPage(name: AppRoutes.missions, page: () => const MissionScreen()),
    GetPage(name: AppRoutes.reports, page: () => const ReportScreen()),
  ];
}
