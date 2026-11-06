import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter/data/models/res/overtime_models.dart';
import 'package:test_flutter/data/preview/overtime_preview_data.dart';

class OvertimeController extends GetxController {
  OvertimeController({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final Rxn<OvertimeStatus> selectedStatus = Rxn<OvertimeStatus>();
  final RxList<OtRequest> allEntries = <OtRequest>[].obs;
  final RxBool isLoading = false.obs;
  final List<OtRate> rates = overtimePreviewRates;
  bool _loaded = false;

  String get totalApprovedHours =>
      '${formatOtNumber(allEntries.where((r) => r.status == OvertimeStatus.approved).fold<double>(0, (total, r) => total + r.hours))}h';

  String get thisMonthHours {
    final now = _now();
    final hours = allEntries
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .fold<double>(0, (total, r) => total + r.hours);
    return '${formatOtNumber(hours)}h';
  }

  int get pendingCount =>
      allEntries.where((r) => r.status == OvertimeStatus.pending).length;

  List<OtRequest> get filteredEntries {
    final query = searchQuery.value.trim().toLowerCase();
    final status = selectedStatus.value;
    return allEntries.where((r) {
      if (status != null && r.status != status) return false;
      return query.isEmpty ||
          [
            r.dateLabel,
            r.date.toIso8601String().split('T').first,
            r.reason,
            r.rateLabel,
            r.approverName ?? '',
            r.status.label,
          ].any((value) => value.toLowerCase().contains(query));
    }).toList()..sort((a, b) {
      final dateOrder = b.date.compareTo(a.date);
      return dateOrder == 0 ? b.id.compareTo(a.id) : dateOrder;
    });
  }

  @override
  void onInit() {
    super.onInit();
    fetchEntries();
  }

  /// Loads the UI preview once; refresh preserves locally added preview requests.
  Future<void> fetchEntries() async {
    isLoading.value = true;
    try {
      if (!_loaded) {
        allEntries.assignAll(overtimePreviewRequests(_now()));
        _loaded = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String value) => searchQuery.value = value;
  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedStatus.value = null;
  }

  void addEntry(OtRequest entry) => allEntries.insert(0, entry);
  int get nextPreviewId =>
      allEntries.fold<int>(0, (id, r) => r.id > id ? r.id : id) + 1;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
