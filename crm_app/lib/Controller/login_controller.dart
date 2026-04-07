import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../API/auth_api_service.dart';
import '../Model/login_models.dart';

class LoginController extends GetxController {
  final AuthApiService _authService = AuthApiService('https://dashboard.reachinternational.co.in/development/api');

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  LoginResponse? loginResponse;

  Future<void> login() async {
    final email = 'raghwendra@gmail.com';// emailController.text.trim();
    final password = 'Welcome12';//passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please fill email and password');
      return;
    }

    try {
      isLoading.value = true;

      final res = await _authService.login(
        email: email,
        password: password,
      );

      loginResponse = res;
      print("login Response");
      print(res.data);
      if (res.success == 1 && res.data != null) {
        // Logged in
        Get.snackbar(
          'Success',
          'Welcome ${res.data!.name}',
          snackPosition: SnackPosition.BOTTOM,
        );

        // TODO: save user in local storage if needed

        // Navigate to dashboard
        Get.offAllNamed('/dashboard');
      } else {
        Get.snackbar(
          'Login Failed',
          res.message,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
