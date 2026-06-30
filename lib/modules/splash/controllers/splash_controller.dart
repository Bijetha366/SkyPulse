import 'dart:async';
import 'package:get/get.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _startTimer();
  }

  /// Start the 2.5 second delay before navigating to dashboard
  void _startTimer() {
    Timer(const Duration(milliseconds: 2500), () {
      Get.offNamed(AppRoutes.dashboard);
    });
  }
}
