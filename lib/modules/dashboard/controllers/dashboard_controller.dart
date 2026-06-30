import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';
import '../../../data/models/weather_model.dart';
import '../../../data/models/news_model.dart';
import '../../../data/repositories/weather_repository.dart';
import '../../../data/repositories/news_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/storage_service.dart';

class DashboardController extends GetxController {
  final WeatherRepository _weatherRepository;
  final NewsRepository _newsRepository;
  final LocationService _locationService;

  DashboardController({
    required WeatherRepository weatherRepository,
    required NewsRepository newsRepository,
    required LocationService locationService,
  })  : _weatherRepository = weatherRepository,
        _newsRepository = newsRepository,
        _locationService = locationService;

  // --- Tab Navigation ---
  final RxInt tabIndex = 0.obs;

  // --- Weather States ---
  final RxBool isLoadingWeather = false.obs;
  final Rxn<WeatherModel> weather = Rxn<WeatherModel>();
  final RxnString weatherError = RxnString();
  final RxnString weatherOfflineMessage = RxnString();
  final RxString currentSearchCity = ''.obs;

  // --- News States ---
  final RxBool isLoadingNews = false.obs;
  final RxBool isLoadingMoreNews = false.obs;
  final RxList<NewsModel> newsList = <NewsModel>[].obs;
  final RxnString newsError = RxnString();
  final RxnString newsOfflineMessage = RxnString();
  
  int _currentNewsPage = 1;
  static const int _pageSize = 10;
  final RxBool hasMoreNews = true.obs;

  // --- Search & Cancel Tokens ---
  final RxString searchQuery = ''.obs;
  CancelToken? _weatherCancelToken;

  // --- Scroll Controller for News Pagination ---
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    // Setup debounce worker for city search
    debounce(
      searchQuery,
      (String query) {
        final cleanQuery = query.trim();
        if (cleanQuery.isNotEmpty) {
          fetchWeatherByCity(cleanQuery);
        }
      },
      time: const Duration(milliseconds: 500),
    );

    // Setup scroll listener for news infinite scroll
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;
      final pos = scrollController.position;
      debugPrint('Scroll position: ${pos.pixels} / ${pos.maxScrollExtent}');
      if (pos.maxScrollExtent > 0 && pos.pixels > 0 && pos.pixels >= pos.maxScrollExtent - 200) {
        loadNextNewsPage();
      }
    });

    // Initial load: Weather + News
    loadInitialData();
  }

  @override
  void onClose() {
    _weatherCancelToken?.cancel('Controller closed');
    scrollController.dispose();
    super.onClose();
  }

  /// Initial load that attempts to fetch weather by current location and load first page of news.
  Future<void> loadInitialData() async {
    await Future.wait([
      fetchWeatherByLocation(),
      refreshNews(),
    ]);
  }

  /// Pull-to-refresh wrapper
  Future<void> refreshAll() async {
    // Clear offline/error states
    weatherError.value = null;
    weatherOfflineMessage.value = null;
    newsError.value = null;
    newsOfflineMessage.value = null;

    if (currentSearchCity.value.isNotEmpty) {
      await Future.wait([
        fetchWeatherByCity(currentSearchCity.value, isRefresh: true),
        refreshNews(),
      ]);
    } else {
      await Future.wait([
        fetchWeatherByLocation(isRefresh: true),
        refreshNews(),
      ]);
    }
  }

  // ==========================================
  // WEATHER FEATURES
  // ==========================================

  /// Fetches weather using the device's current location coordinates
  Future<void> fetchWeatherByLocation({bool isRefresh = false}) async {
    if (!isRefresh) isLoadingWeather.value = true;
    weatherError.value = null;
    weatherOfflineMessage.value = null;
    currentSearchCity.value = ''; // Reset city search name since we use GPS

    try {
      final locResult = await _locationService.getCurrentLocation();
      if (!locResult.success) {
        // Handle permission denied or disabled services by falling back to cache
        weatherError.value = locResult.error;
        _loadWeatherCacheFallback(locResult.error ?? 'Location unavailable');
        return;
      }

      // Perform reverse geocoding to retrieve user's actual city name
      String resolvedCity = 'My Location';
      try {
        final placemarks = await placemarkFromCoordinates(
          locResult.latitude!,
          locResult.longitude!,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          resolvedCity = place.locality ?? 
              place.subAdministrativeArea ?? 
              place.name ?? 
              'My Location';
        }
      } catch (e) {
        debugPrint('Reverse geocoding failed: $e');
      }

      final result = await _weatherRepository.getWeather(
        latitude: locResult.latitude!,
        longitude: locResult.longitude!,
        cityName: resolvedCity,
      );

      weather.value = result.data;
      weatherOfflineMessage.value = result.offlineMessage;
    } catch (e) {
      if (e is DioException && DioExceptionType.cancel == e.type) return;
      weatherError.value = e.toString().replaceAll('Exception: ', '');
      _loadWeatherCacheFallback(weatherError.value!);
    } finally {
      if (!isRefresh) isLoadingWeather.value = false;
    }
  }

  /// Fetches weather by performing geocoding lookup on the city name
  Future<void> fetchWeatherByCity(String cityName, {bool isRefresh = false}) async {
    // Cancel previous request if typing continues or is-flight
    _weatherCancelToken?.cancel('New search triggered');
    _weatherCancelToken = CancelToken();

    if (!isRefresh) isLoadingWeather.value = true;
    weatherError.value = null;
    weatherOfflineMessage.value = null;
    currentSearchCity.value = cityName;

    try {
      // 1. Resolve City Name to Coordinates
      final coords = await _weatherRepository.getCoordinates(
        cityName,
        cancelToken: _weatherCancelToken,
      );

      // 2. Fetch Weather using Coordinates
      final result = await _weatherRepository.getWeather(
        latitude: coords['latitude']!,
        longitude: coords['longitude']!,
        cityName: cityName.capitalizeFirst ?? cityName,
        cancelToken: _weatherCancelToken,
      );

      weather.value = result.data;
      weatherOfflineMessage.value = result.offlineMessage;
    } catch (e) {
      if (e is DioException && DioExceptionType.cancel == e.type) {
        // Request was cancelled; do not update states or load cache
        return;
      }
      final cleanErr = e.toString().replaceAll('Exception: ', '');
      weatherError.value = cleanErr;
      _loadWeatherCacheFallback(cleanErr);
    } finally {
      if (!isRefresh) isLoadingWeather.value = false;
    }
  }

  /// Helper to load weather cache
  void _loadWeatherCacheFallback(String primaryError) {
    final storage = Get.find<StorageService>();
    final cachedData = storage.getCachedWeather();
    final cacheTime = storage.getWeatherCacheTime();

    if (cachedData != null) {
      weather.value = cachedData;
      final formattedTime = cacheTime != null 
          ? DateFormat('hh:mm a').format(cacheTime) 
          : 'unknown';
      weatherOfflineMessage.value = 'Showing offline data from $formattedTime';
    }
  }

  // ==========================================
  // NEWS PAGINATION & INFINITE SCROLL
  // ==========================================

  /// Refreshes news list back to page 1
  Future<void> refreshNews() async {
    isLoadingNews.value = true;
    newsError.value = null;
    newsOfflineMessage.value = null;
    _currentNewsPage = 1;
    hasMoreNews.value = true;

    try {
      final result = await _newsRepository.getNews(
        page: _currentNewsPage,
        pageSize: _pageSize,
      );

      newsList.assignAll(result.data);
      newsOfflineMessage.value = result.offlineMessage;
      
      // If we got no items, we reached the end
      if (result.data.isEmpty) {
        hasMoreNews.value = false;
      }
    } catch (e) {
      newsError.value = e.toString().replaceAll('Exception: ', '');
      // Fallback is handled automatically inside repository getNews(page: 1)
      // but if the repository throws (e.g. no cache at page 1), we display the error.
    } finally {
      isLoadingNews.value = false;
    }
  }

  /// Loads subsequent pages of news (infinite scroll)
  Future<void> loadNextNewsPage() async {
    // Avoid double loading, pagination when offline, or if no more data
    if (isLoadingNews.value || isLoadingMoreNews.value || !hasMoreNews.value || newsOfflineMessage.value != null) {
      return;
    }

    isLoadingMoreNews.value = true;
    _currentNewsPage++;

    try {
      final result = await _newsRepository.getNews(
        page: _currentNewsPage,
        pageSize: _pageSize,
      );

      if (result.data.isEmpty) {
        hasMoreNews.value = false;
      } else {
        newsList.addAll(result.data);
      }
    } catch (e) {
      // Revert page counter on error so we can retry scrolling
      _currentNewsPage--;
      debugPrint('Error loading page $_currentNewsPage: $e');
      Get.rawSnackbar(
        message: 'Failed to load more news: ${e.toString().replaceAll('Exception: ', '')}',
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoadingMoreNews.value = false;
    }
  }
}
