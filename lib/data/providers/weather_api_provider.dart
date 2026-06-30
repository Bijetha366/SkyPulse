import 'package:dio/dio.dart';
import '../models/weather_model.dart';

class WeatherApiProvider {
  final Dio _dio;

  WeatherApiProvider({required Dio dio}) : _dio = dio;

  /// Fetches weather and forecast for given coordinates
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
    required String cityName,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'current_weather': true,
          'hourly': 'relative_humidity_2m',
          'daily': 'temperature_2m_max,temperature_2m_min,weathercode',
          'timezone': 'auto',
        },
        cancelToken: cancelToken,
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return WeatherModel.fromJson(response.data, cityName);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch weather: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Re-throw clean message or error
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred while fetching weather data: $e');
    }
  }

  /// Resolve a city name to coordinates using Open-Meteo Geocoding API as fallback
  Future<Map<String, double>> getCoordinatesFromCityName(
    String cityName, {
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        'https://geocoding-api.open-meteo.com/v1/search',
        queryParameters: {
          'name': cityName,
          'count': 1,
          'language': 'en',
          'format': 'json',
        },
        cancelToken: cancelToken,
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final results = response.data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          final first = results[0];
          final lat = (first['latitude'] as num).toDouble();
          final lon = (first['longitude'] as num).toDouble();
          return {'latitude': lat, 'longitude': lon};
        }
        throw Exception('City not found: $cityName');
      } else {
        throw Exception('Failed to geocode city: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred during geocoding: $e');
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timed out. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        return Exception('Server error ($status). Please try again later.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please verify your network.');
      default:
        return Exception('Network error occurred: ${error.message}');
    }
  }
}
