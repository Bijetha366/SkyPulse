import '../models/news_model.dart';
import '../models/bookmark_model.dart';
import '../../core/services/storage_service.dart';

class BookmarkRepository {
  final StorageService _storageService;

  BookmarkRepository({required StorageService storageService})
      : _storageService = storageService;

  /// Retrieves all bookmarks, sorted by most recently bookmarked
  List<BookmarkModel> getBookmarks() {
    final bookmarks = _storageService.bookmarksBox.values.toList();
    bookmarks.sort((a, b) => b.bookmarkedAt.compareTo(a.bookmarkedAt));
    return bookmarks;
  }

  /// Adds an article to bookmarks
  Future<void> addBookmark(NewsModel news) async {
    final bookmark = BookmarkModel.fromNewsModel(news);
    // Use the URL as the unique key to prevent duplicates
    await _storageService.bookmarksBox.put(news.url, bookmark);
  }

  /// Removes an article from bookmarks using its URL
  Future<void> removeBookmark(String url) async {
    await _storageService.bookmarksBox.delete(url);
  }

  /// Checks if a news article is already bookmarked
  bool isBookmarked(String url) {
    return _storageService.bookmarksBox.containsKey(url);
  }
}
