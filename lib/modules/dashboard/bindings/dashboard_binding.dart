import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../data/repositories/weather_repository.dart';
import '../../../data/repositories/news_repository.dart';
import '../../../data/providers/weather_api_provider.dart';
import '../../../data/providers/news_api_provider.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // API Providers
    Get.lazyPut<WeatherApiProvider>(() => WeatherApiProvider(dio: Get.find()));
    Get.lazyPut<NewsApiProvider>(() => NewsApiProvider(dio: Get.find()));

    // Repositories
    Get.lazyPut<WeatherRepository>(
      () => WeatherRepository(
        apiProvider: Get.find(),
        storageService: Get.find(),
      ),
    );
    Get.lazyPut<NewsRepository>(
      () => NewsRepository(
        apiProvider: Get.find(),
        storageService: Get.find(),
      ),
    );

    // Controller
    Get.lazyPut<DashboardController>(
      () => DashboardController(
        weatherRepository: Get.find(),
        newsRepository: Get.find(),
        locationService: Get.find(),
      ),
    );
  }
}
