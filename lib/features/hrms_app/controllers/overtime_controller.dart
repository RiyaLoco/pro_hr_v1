// import 'package:get/get.dart';
// import 'package:flutter/material.dart';
// import 'package:test_flutter/data/models/res/overtime_models.dart';
// import 'package:test_flutter/data/preview/overtime_preview_data.dart';

// class OvertimeController extends GetxController {
//   OvertimeController({DateTime Function()? now}) : _now = now ?? DateTime.now;

//   final DateTime Function() _now;
//   final searchController = TextEditingController();
//   final RxString searchQuery = ''.obs;
//   final Rxn<OvertimeStatus> selectedStatus = Rxn<OvertimeStatus>();
//   final RxList<OtRequest> allEntries = <OtRequest>[].obs;
//   final RxBool isLoading = false.obs;
//   final List<OtRate> rates = overtimePreviewRates;
//   bool _loaded = false;

//   String get totalApprovedHours =>
//       '${formatOtNumber(allEntries.where((r) => r.status == OvertimeStatus.approved).fold<double>(0, (total, r) => total + r.hours))}h';

//   String get thisMonthHours {
//     final now = _now();
//     final hours = allEntries
//         .where((r) => r.date.year == now.year && r.date.month == now.month)
//         .fold<double>(0, (total, r) => total + r.hours);
//     return '${formatOtNumber(hours)}h';
//   }

//   int get pendingCount =>
//       allEntries.where((r) => r.status == OvertimeStatus.pending).length;

//   List<OtRequest> get filteredEntries {
//     final query = searchQuery.value.trim().toLowerCase();
//     final status = selectedStatus.value;
//     return allEntries.where((r) {
//       if (status != null && r.status != status) return false;
//       return query.isEmpty ||
//           [
//             r.dateLabel,
//             r.date.toIso8601String().split('T').first,
//             r.reason,
//             r.rateLabel,
//             r.approverName ?? '',
//             r.status.label,
//           ].any((value) => value.toLowerCase().contains(query));
//     }).toList()..sort((a, b) {
//       final dateOrder = b.date.compareTo(a.date);
//       return dateOrder == 0 ? b.id.compareTo(a.id) : dateOrder;
//     });
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     fetchEntries();
//   }

//   /// Loads the UI preview once; refresh preserves locally added preview requests.
//   Future<void> fetchEntries() async {
//     isLoading.value = true;
//     try {
//       if (!_loaded) {
//         allEntries.assignAll(overtimePreviewRequests(_now()));
//         _loaded = true;
//       }
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void updateSearch(String value) => searchQuery.value = value;
//   void resetFilters() {
//     searchController.clear();
//     searchQuery.value = '';
//     selectedStatus.value = null;
//   }

//   void addEntry(OtRequest entry) => allEntries.insert(0, entry);
//   int get nextPreviewId =>
//       allEntries.fold<int>(0, (id, r) => r.id > id ? r.id : id) + 1;

//   @override
//   void onClose() {
//     searchController.dispose();
//     super.onClose();
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/overtime_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';

/// Overtime history, rates and filters, loaded from the employee API.
class OvertimeController extends GetxController {
  OvertimeController({DateTime Function()? now, ApiController? api})
    : _now = now ?? DateTime.now,
      _api = api ?? ApiController();

  /// Safety cap: 10 pages of 100 requests.
  static const int _maxPages = 10;

  final DateTime Function() _now;
  final ApiController _api;

  final searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final Rxn<OvertimeStatus> selectedStatus = Rxn<OvertimeStatus>();
  final RxList<OtRequest> allEntries = <OtRequest>[].obs;
  final RxList<OtRate> rates = <OtRate>[].obs;
  final RxBool isLoading = false.obs;

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
    fetchRates();
  }

  /// Loads every page of the employee's overtime requests.
  Future<void> fetchEntries() async {
    isLoading.value = true;
    try {
      final entries = <OtRequest>[];
      var page = 1;
      var lastPage = 1;
      do {
        final result = await _api.fetchOvertimePage(page: page);
        entries.addAll(result.items);
        lastPage = result.lastPage;
        page++;
      } while (page <= lastPage && page <= _maxPages);

      allEntries.assignAll(entries);
    } on ApiException catch (e) {
      Get.snackbar('Overtime', e.displayMessage);
    } catch (_) {
      Get.snackbar('Overtime', 'Could not load your overtime. Check your connection.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRates() async {
    try {
      rates.assignAll(await _api.fetchOvertimeRates());
    } on ApiException catch (e) {
      Get.snackbar('Overtime rates', e.displayMessage);
    } catch (_) {
      Get.snackbar('Overtime rates', 'Could not load overtime rates. Check your connection.');
    }
  }

  /// The request form calls this before showing the rate list.
  Future<void> ensureRates() async {
    if (rates.isEmpty) await fetchRates();
  }

  void updateSearch(String value) => searchQuery.value = value;

  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedStatus.value = null;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}