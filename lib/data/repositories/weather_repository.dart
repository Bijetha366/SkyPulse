import 'dart:async';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../providers/weather_api_provider.dart';
import '../../core/services/storage_service.dart';

class RepoResult<T> {
  final T data;
  final String? offlineMessage;
  final bool isOffline;

  RepoResult({
    required this.data,
    this.offlineMessage,
    this.isOffline = false,
  });
}

class WeatherRepository {
  final WeatherApiProvider _apiProvider;
  final StorageService _storageService;

  WeatherRepository({
    required WeatherApiProvider apiProvider,
    required StorageService storageService,
  })  : _apiProvider = apiProvider,
        _storageService = storageService;

  /// Fetches weather with automatic retry, backoff, and local cache fallback
  Future<RepoResult<WeatherModel>> getWeather({
    required double latitude,
    required double longitude,
    required String cityName,
    CancelToken? cancelToken,
  }) async {
    const int maxAttempts = 3;
    Duration delay = const Duration(seconds: 1);
    dynamic lastError;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final weather = await _apiProvider.fetchWeather(
          latitude: latitude,
          longitude: longitude,
          cityName: cityName,
          cancelToken: cancelToken,
        );
        // Save to local cache on success
        await _storageService.cacheWeather(weather);
        return RepoResult(data: weather, isOffline: false);
      } catch (e) {
        lastError = e;
        if (e is DioException && DioExceptionType.cancel == e.type) {
          // If request was explicitly cancelled, don't retry, re-throw cancellation
          throw e;
        }
        if (attempt < maxAttempts) {
          // Automatic retry with exponential backoff
          await Future.delayed(delay);
          delay = delay * 2;
        }
      }
    }

    // Fallback to cache if all attempts fail
    final cachedWeather = _storageService.getCachedWeather();
    if (cachedWeather != null) {
      final cacheTime = _storageService.getWeatherCacheTime() ?? DateTime.now();
      final formattedTime = DateFormat('hh:mm a').format(cacheTime);
      return RepoResult(
        data: cachedWeather,
        isOffline: true,
        offlineMessage: 'Showing offline data from $formattedTime',
      );
    }

    // If no cache, throw the network error
    throw lastError ?? Exception('Failed to fetch weather data.');
  }

  /// Delegates geocoding to API provider
  Future<Map<String, double>> getCoordinates(String cityName, {CancelToken? cancelToken}) async {
    return await _apiProvider.getCoordinatesFromCityName(cityName, cancelToken: cancelToken);
  }
}
