import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
 
class AttendanceRecord {
  final String date;
  final String checkIn;
  final String checkOut;
  final String status;
 
  const AttendanceRecord({
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });
}

class AttendanceController extends GetxController {
  final RxDouble hoursWorked = 37.0.obs;
  final RxDouble weeklyGoalHours = 40.0.obs;
 
  double get progress =>
      weeklyGoalHours.value == 0 ? 0 : hoursWorked.value / weeklyGoalHours.value;
 
  String get hoursLabel =>
      '${hoursWorked.value.toStringAsFixed(0)}/${weeklyGoalHours.value.toStringAsFixed(0)}';
  final RxString totalHours = '120h'.obs;
  final RxString onTimePercent = '89%'.obs;
  final RxString leaveDays = '12d'.obs;
  final RxList<AttendanceRecord> records = <AttendanceRecord>[].obs;
  final RxBool isLoading = false.obs;
 
  @override
  void onInit() {
    super.onInit();
    fetchAttendanceHistory();
  }
  Future<void> fetchAttendanceHistory() async {
    isLoading.value = true;
    try {
      // TODO: replace with real data source (API, local DB, etc.)
      records.value = List.generate(
        6,
        (index) => const AttendanceRecord(
          date: '',
          checkIn: '',
          checkOut: '',
          status: '',
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
}