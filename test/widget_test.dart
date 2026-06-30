import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sky_pulse/modules/dashboard/widgets/news_section.dart';
import 'package:sky_pulse/modules/dashboard/widgets/news_shimmer.dart';
import 'package:sky_pulse/modules/bookmarks/controllers/bookmarks_controller.dart';
import 'package:sky_pulse/modules/settings/views/settings_view.dart';
import 'package:sky_pulse/modules/settings/controllers/settings_controller.dart';
import 'package:sky_pulse/data/models/news_model.dart';
import 'package:sky_pulse/data/models/bookmark_model.dart';

class MockBookmarksController extends GetxController implements BookmarksController {
  @override
  final RxList<BookmarkModel> bookmarkedArticles = <BookmarkModel>[].obs;

  @override
  Future<void> toggleBookmark(NewsModel news) async {
    final existingIndex = bookmarkedArticles.indexWhere((element) => element.url == news.url);
    if (existingIndex >= 0) {
      bookmarkedArticles.removeAt(existingIndex);
    } else {
      bookmarkedArticles.add(BookmarkModel.fromNewsModel(news));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockSettingsController extends GetxController implements SettingsController {
  @override
  final RxBool isDarkMode = false.obs;
  @override
  final RxString defaultCity = 'London'.obs;
  @override
  final RxString appVersion = '1.0.0'.obs;
  @override
  final RxString buildNumber = '1'.obs;

  @override
  Future<void> toggleThemeMode(bool isDark) async {
    isDarkMode.value = isDark;
  }

  @override
  Future<void> updateDefaultCity(String city) async {
    defaultCity.value = city;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    Get.put<BookmarksController>(MockBookmarksController() as BookmarksController);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('NewsSection displays articles and handles bookmarks', (WidgetTester tester) async {
    final testArticles = [
      NewsModel(
        title: 'Test Article 1',
        description: 'Description 1',
        url: 'https://test1.com',
        urlToImage: 'https://test1.com/image.jpg',
        publishedAt: '2026-06-30T12:00:00Z',
        sourceName: 'Source 1',
        content: 'Content 1',
      ),
      NewsModel(
        title: 'Test Article 2',
        description: 'Description 2',
        url: 'https://test2.com',
        urlToImage: null,
        publishedAt: '2026-06-30T13:00:00Z',
        sourceName: 'Source 2',
        content: 'Content 2',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NewsSection(
              newsList: testArticles,
              isLoadingMore: false,
              hasMore: false,
            ),
          ),
        ),
      ),
    );

    // Verify latest news title is displayed
    expect(find.text('Latest News'), findsOneWidget);

    // Verify article titles and sources are displayed
    expect(find.text('Test Article 1'), findsOneWidget);
    expect(find.text('Source 1'), findsOneWidget);
    expect(find.text('Test Article 2'), findsOneWidget);
    expect(find.text('Source 2'), findsOneWidget);

    // Verify bookmark buttons exist
    expect(find.byIcon(Icons.bookmark_border_rounded), findsNWidgets(2));

    // Tap first bookmark button
    await tester.tap(find.byIcon(Icons.bookmark_border_rounded).first);
    await tester.pump();

    // Verify first article is bookmarked (icon changed)
    expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
  });

  testWidgets('NewsShimmerList renders placeholder cards correctly', (WidgetTester tester) async {
    // Import news shimmer
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: NewsShimmerList(itemCount: 3),
        ),
      ),
    );

    // Verify Title text displays
    expect(find.text('Latest News'), findsOneWidget);

    // Verify 3 NewsCardShimmer are rendered
    expect(find.byType(NewsCardShimmer), findsNWidgets(3));
  });

  testWidgets('SettingsView renders and validates city input', (WidgetTester tester) async {
    final mockSettings = MockSettingsController();
    Get.put<SettingsController>(mockSettings);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: SettingsView(),
      ),
    );

    // Verify section titles
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Weather Configuration'), findsOneWidget);

    // Verify Default City TextField has the initial value
    expect(find.text('London'), findsOneWidget);

    // Clear city input and press save
    await tester.enterText(find.byType(TextField), '');
    await tester.ensureVisible(find.byIcon(Icons.save_rounded));
    await tester.tap(find.byIcon(Icons.save_rounded));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    // Verify the mock value is still London (was not updated to empty)
    expect(mockSettings.defaultCity.value, 'London');
  });
}
