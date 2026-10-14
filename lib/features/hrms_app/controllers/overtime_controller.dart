import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

enum OvertimeStatus { pending, reject, approved }

extension OvertimeStatusLabel on OvertimeStatus {
  String get label {
    switch (this) {
      case OvertimeStatus.pending:
        return 'Pending';
      case OvertimeStatus.reject:
        return 'Reject';
      case OvertimeStatus.approved:
        return 'Approved';
    }
  }
}

/// Model for a single overtime entry shown under "Recent Entries".
class OvertimeEntry {
  final String date; // display string, e.g. 'July 13, 2026'
  final String title;
  final String hoursLabel; // e.g. '6 Hours'
  final String personLabel; // e.g. 'Pending with : Sok Chankungkea'
  final OvertimeStatus status;

  const OvertimeEntry({
    required this.date,
    required this.title,
    required this.hoursLabel,
    required this.personLabel,
    required this.status,
  });
}

/// Controller for the Overtime screen — holds summary stats, the
/// search query, and the list of overtime entries.
class OvertimeController extends GetxController {
  final RxString totalApprovedHours = '00h'.obs;
  final RxString thisMonthHours = '00h'.obs;
  final RxString searchQuery = ''.obs;
  final RxList<OvertimeEntry> allEntries = <OvertimeEntry>[].obs;
  final RxBool isLoading = false.obs;

  /// Entries filtered by [searchQuery] against date and person label.
  List<OvertimeEntry> get filteredEntries {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return allEntries;
    return allEntries
        .where((entry) =>
            entry.date.toLowerCase().contains(query) ||
            entry.personLabel.toLowerCase().contains(query))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchEntries();
  }

  /// Loads overtime entries and summary stats. Replace the body with
  /// a real API / repository call when ready.
  Future<void> fetchEntries() async {
    isLoading.value = true;
    try {
      // TODO: replace with real data source (API, local DB, etc.)
      allEntries.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String value) => searchQuery.value = value;

  /// Adds a newly-submitted overtime request to the top of the list.
  void addEntry(OvertimeEntry entry) => allEntries.insert(0, entry);
}