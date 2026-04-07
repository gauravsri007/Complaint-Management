import 'package:crm_app/utilities/user_local_storage.dart';
import 'package:get/get.dart';
import '../API/auth_api_service.dart';
import '../Model/complaints.dart';

class ComplaintController extends GetxController {
  final AuthApiService _authService = AuthApiService('https://dashboard.reachinternational.co.in/development/api');

  final isLoading = false.obs;
  ComplaintsResponse? complaintsResponse;
  String engineerId = '';
  String status = '';

  //
  // Future<void> getComplaints() async {
  //   try {
  //     isLoading.value = true;
  //     final user = await UserLocalStorage.getSavedUser();
  //     final res = await _authService.complaints(
  //       user_id: user!.userId,
  //       role_id: user.roleId
  //       page_start: pageNumeber,
  //     );
  //
  //     var loginResponse = res;
  //     print("complaints Response");
  //     print(res.data);
  //     if (res.status == true && res.data != null) {
  //       // Logged in
  //       // TODO: save user in local storage if needed
  //
  //       // Navigate to dashboard
  //       Get.offAllNamed('/dashboard');
  //     } else {
  //       Get.snackbar(
  //         'complaints Failed',
  //         res.message,
  //         snackPosition: SnackPosition.BOTTOM,
  //       );
  //     }
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Something went wrong: $e',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
}
