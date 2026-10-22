import 'package:get/get.dart';
import 'package:test_flutter/data/models/res/recruitment_models.dart';
import 'package:test_flutter/data/services/api_controller.dart';

class RecruitmentController extends GetxController{
  final RxList<Recruitment> recruitments = <Recruitment>[].obs;
  final RxBool isLoading  = false.obs;
  final RxBool hasError = false.obs;

  final ApiController _api = ApiController();

  @override
  void onInit() {
    super.onInit();
    fetchRecruitments();
  }

  Future<void> fetchRecruitments()async{
    isLoading.value = true;
    hasError.value = false;
    try{
      recruitments.assignAll(await _api.fetchRecruitments());
    }catch(_){
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
