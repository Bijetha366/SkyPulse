import 'package:get/get.dart';
import '../../../data/models/news_model.dart';
import '../../../data/models/bookmark_model.dart';
import '../../../data/repositories/bookmark_repository.dart';

class BookmarksController extends GetxController {
  final BookmarkRepository _bookmarkRepository;

  BookmarksController({required BookmarkRepository bookmarkRepository})
      : _bookmarkRepository = bookmarkRepository;

  final RxList<BookmarkModel> bookmarkedArticles = <BookmarkModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadBookmarks();
  }

  /// Refreshes and loads all bookmarks from storage
  void loadBookmarks() {
    bookmarkedArticles.assignAll(_bookmarkRepository.getBookmarks());
  }

  /// Toggles bookmark state for a given news article
  Future<void> toggleBookmark(NewsModel news) async {
    final url = news.url;
    if (_bookmarkRepository.isBookmarked(url)) {
      await _bookmarkRepository.removeBookmark(url);
    } else {
      await _bookmarkRepository.addBookmark(news);
    }
    loadBookmarks();
  }

  /// Removes a bookmark directly by URL
  Future<void> removeBookmark(String url) async {
    await _bookmarkRepository.removeBookmark(url);
    loadBookmarks();
  }

  /// Returns whether a news article is bookmarked
  bool isBookmarked(String url) {
    return bookmarkedArticles.any((article) => article.url == url);
  }
}
