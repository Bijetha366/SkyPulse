import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/storage_service.dart';
import 'core/services/location_service.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'data/repositories/bookmark_repository.dart';
import 'modules/bookmarks/controllers/bookmarks_controller.dart';
import 'modules/settings/controllers/settings_controller.dart';

void main() async {
  // Ensure that Flutter widget binding is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (.env file)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Fail gracefully if .env is missing (e.g. print error)
    debugPrint('Warning: Could not load .env file. Please ensure it exists: $e');
  }

  // Initialize and register global storage service (Hive)
  final storageService = StorageService();
  await storageService.init();
  Get.put<StorageService>(storageService, permanent: true);

  // Initialize and register global location service
  Get.put<LocationService>(LocationService(), permanent: true);

  // Initialize and register global Dio networking client
  Get.put<Dio>(Dio(), permanent: true);

  // Initialize and register global bookmark repository & controller
  final bookmarkRepository = BookmarkRepository(storageService: storageService);
  Get.put<BookmarkRepository>(bookmarkRepository, permanent: true);
  Get.put<BookmarksController>(
    BookmarksController(bookmarkRepository: bookmarkRepository),
    permanent: true,
  );

  // Initialize and register global settings controller
  Get.put<SettingsController>(
    SettingsController(storageService: storageService),
    permanent: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();
    final isDark = storageService.isDarkMode();

    return GetMaterialApp(
      title: 'SkyPulse',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppPages.initial,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
