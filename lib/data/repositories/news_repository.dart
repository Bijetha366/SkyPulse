import 'dart:async';
import 'package:intl/intl.dart';
import '../models/news_model.dart';
import '../providers/news_api_provider.dart';
import '../../core/services/storage_service.dart';
import 'weather_repository.dart'; // Reuse RepoResult

class NewsRepository {
  final NewsApiProvider _apiProvider;
  final StorageService _storageService;

  NewsRepository({
    required NewsApiProvider apiProvider,
    required StorageService storageService,
  })  : _apiProvider = apiProvider,
        _storageService = storageService;

  /// Fetches paginated news with retry, backoff, and local cache fallback
  Future<RepoResult<List<NewsModel>>> getNews({
    required int page,
    required int pageSize,
  }) async {
    const int maxAttempts = 3;
    Duration delay = const Duration(seconds: 1);
    dynamic lastError;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final news = await _apiProvider.fetchTopHeadlines(
          page: page,
          pageSize: pageSize,
        );

        // Only cache the first page to serve as the offline headlines cache
        if (page == 1 && news.isNotEmpty) {
          await _storageService.cacheNews(news);
        }

        return RepoResult(data: news, isOffline: false);
      } catch (e) {
        lastError = e;
        if (attempt < maxAttempts) {
          // Automatic retry with exponential backoff
          await Future.delayed(delay);
          delay = delay * 2;
        }
      }
    }

    // Fallback to cache for the first page
    if (page == 1) {
      final cachedNews = _storageService.getCachedNews();
      if (cachedNews.isNotEmpty) {
        final cacheTime = _storageService.getNewsCacheTime() ?? DateTime.now();
        final formattedTime = DateFormat('hh:mm a').format(cacheTime);
        return RepoResult(
          data: cachedNews,
          isOffline: true,
          offlineMessage: 'Showing offline data from $formattedTime',
        );
      }
    }

    throw lastError ?? Exception('Failed to fetch news articles.');
  }
}
