import 'package:get/get.dart';
import '../controllers/bookmarks_controller.dart';
import '../../../data/repositories/bookmark_repository.dart';

class BookmarksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookmarkRepository>(
      () => BookmarkRepository(storageService: Get.find()),
    );
    Get.lazyPut<BookmarksController>(
      () => BookmarksController(bookmarkRepository: Get.find()),
    );
  }
}
