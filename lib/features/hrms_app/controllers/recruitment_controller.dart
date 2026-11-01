import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/recruitment_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';

class RecruitmentController extends GetxController {
  final RxList<Recruitment> recruitments = <Recruitment>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = false.obs;
  final RxBool loadMoreFailed = false.obs;

  final ApiController _api = ApiController();
  static const _pageSize = 10;
  int _page = 1;

  @override
  void onInit() {
    super.onInit();
    fetchRecruitments();
  }

  Future<void> fetchRecruitments() async {
    if (isLoading.value || isLoadingMore.value) return;
    isLoading.value = true;
    hasError.value = false;
    loadMoreFailed.value = false;
    try {
      final items = await _api.fetchRecruitments(perPage: _pageSize);
      recruitments.assignAll(items);
      _page = 1;
      hasMore.value = items.length == _pageSize;
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    loadMoreFailed.value = false;
    try {
      final items = await _api.fetchRecruitments(
        page: _page + 1,
        perPage: _pageSize,
      );
      final knownIds = recruitments.map((item) => item.uuid).toSet();
      recruitments.addAll(items.where((item) => knownIds.add(item.uuid)));
      _page++;
      hasMore.value = items.length == _pageSize;
    } catch (_) {
      loadMoreFailed.value = true;
    } finally {
      isLoadingMore.value = false;
    }
  }
}
