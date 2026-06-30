import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/services/storage_service.dart';

class SettingsController extends GetxController {
  final StorageService _storageService;

  SettingsController({required StorageService storageService})
      : _storageService = storageService;

  final RxBool isDarkMode = false.obs;
  final RxString defaultCity = ''.obs;
  final RxString appVersion = '1.0.0'.obs;
  final RxString buildNumber = '1'.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storageService.isDarkMode();
    defaultCity.value = _storageService.getDefaultCity() ?? '';
    _loadAppInfo();
  }

  /// Loads application metadata using package_info_plus
  Future<void> _loadAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion.value = info.version;
      buildNumber.value = info.buildNumber;
    } catch (e) {
      debugPrint('Failed to load package info: $e');
    }
  }

  /// Toggles theme mode between light and dark
  Future<void> toggleThemeMode(bool isDark) async {
    isDarkMode.value = isDark;
    await _storageService.setDarkMode(isDark);
    
    // Dynamically switch the GetX app theme
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  /// Saves the default city for weather forecasts
  Future<void> updateDefaultCity(String city) async {
    final cleanCity = city.trim();
    defaultCity.value = cleanCity;
    await _storageService.setDefaultCity(cleanCity);
  }
}
