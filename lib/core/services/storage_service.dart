import 'package:hive_flutter/hive_flutter.dart';
import 'package:get/get.dart';
import '../../data/models/weather_model.dart';
import '../../data/models/forecast_model.dart';
import '../../data/models/news_model.dart';
import '../../data/models/bookmark_model.dart';

class StorageService extends GetxService {
  late Box<WeatherModel> weatherBox;
  late Box<NewsModel> newsBox;
  late Box<BookmarkModel> bookmarksBox;
  late Box<dynamic> settingsBox;

  Future<StorageService> init() async {
    await Hive.initFlutter();

    // Register Type Adapters
    Hive.registerAdapter(WeatherModelAdapter());
    Hive.registerAdapter(ForecastModelAdapter());
    Hive.registerAdapter(NewsModelAdapter());
    Hive.registerAdapter(BookmarkModelAdapter());

    // Open Boxes
    weatherBox = await Hive.openBox<WeatherModel>('weather_box');
    newsBox = await Hive.openBox<NewsModel>('news_box');
    bookmarksBox = await Hive.openBox<BookmarkModel>('bookmarks_box');
    settingsBox = await Hive.openBox('settings_box');

    return this;
  }

  // --- Weather Cache Helper ---
  Future<void> cacheWeather(WeatherModel weather) async {
    await weatherBox.put('current_weather', weather);
    await settingsBox.put('weather_cache_time', DateTime.now().toIso8601String());
  }

  WeatherModel? getCachedWeather() {
    return weatherBox.get('current_weather');
  }

  DateTime? getWeatherCacheTime() {
    final timeStr = settingsBox.get('weather_cache_time');
    return timeStr != null ? DateTime.tryParse(timeStr) : null;
  }

  // --- News Cache Helper ---
  Future<void> cacheNews(List<NewsModel> newsList) async {
    await newsBox.clear();
    await newsBox.addAll(newsList);
    await settingsBox.put('news_cache_time', DateTime.now().toIso8601String());
  }

  List<NewsModel> getCachedNews() {
    return newsBox.values.toList();
  }

  DateTime? getNewsCacheTime() {
    final timeStr = settingsBox.get('news_cache_time');
    return timeStr != null ? DateTime.tryParse(timeStr) : null;
  }

  // --- Settings Helper ---
  bool isDarkMode() {
    return settingsBox.get('dark_mode', defaultValue: false) as bool;
  }

  Future<void> setDarkMode(bool value) async {
    await settingsBox.put('dark_mode', value);
  }

  String? getDefaultCity() {
    return settingsBox.get('default_city') as String?;
  }

  Future<void> setDefaultCity(String city) async {
    await settingsBox.put('default_city', city);
  }
}
