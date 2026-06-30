import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/news_model.dart';

class NewsApiProvider {
  final Dio _dio;

  NewsApiProvider({required Dio dio}) : _dio = dio;

  /// Fetches top headlines from NewsAPI.org with pagination support
  Future<List<NewsModel>> fetchTopHeadlines({
    required int page,
    required int pageSize,
  }) async {
    final apiKey = dotenv.env['NEWS_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_NEWS_API_KEY_HERE') {
      throw Exception('API Key is missing. Please configure NEWS_API_KEY in your .env file.');
    }

    try {
      final response = await _dio.get(
        'https://newsapi.org/v2/top-headlines',
        queryParameters: {
          'country': 'us',
          'category': 'general',
          'page': page,
          'pageSize': pageSize,
          'apiKey': apiKey,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 'ok') {
          final articles = response.data['articles'] as List? ?? [];
          return articles.map((article) => NewsModel.fromJson(article)).toList();
        } else {
          final message = response.data['message'] ?? 'Failed to fetch news';
          throw Exception(message);
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: 'Failed to fetch news: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('An unexpected error occurred while loading news: $e');
    }
  }

  Exception _handleDioError(DioException error) {
    if (error.response?.statusCode == 429) {
      return Exception('News API rate limit exceeded. Please try again later.');
    }
    if (error.response?.statusCode == 401) {
      return Exception('Invalid API Key. Please verify your NEWS_API_KEY in the .env file.');
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timed out. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error';
        return Exception('Server error ($status): $message');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please verify your network.');
      default:
        return Exception('Network error: ${error.message}');
    }
  }
}
