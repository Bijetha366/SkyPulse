import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/weather_card.dart';
import '../widgets/forecast_section.dart';
import '../widgets/news_section.dart';
import '../widgets/news_shimmer.dart';
import '../../bookmarks/views/bookmarks_view.dart';
import '../../settings/views/settings_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Obx(() {
        switch (controller.tabIndex.value) {
          case 0:
            return const _DashboardHomeTab();
          case 1:
            return const BookmarksView();
          case 2:
            return const SettingsView();
          default:
            return const _DashboardHomeTab();
        }
      }),
      bottomNavigationBar: Obx(() {
        return NavigationBar(
          selectedIndex: controller.tabIndex.value,
          onDestinationSelected: (index) => controller.tabIndex.value = index,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.wb_sunny_outlined),
              selectedIcon: Icon(Icons.wb_sunny_rounded),
              label: 'SkyPulse',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded),
              label: 'Bookmarks',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        );
      }),
    );
  }
}

/// The actual dashboard home tab showing weather details and headlines
class _DashboardHomeTab extends GetView<DashboardController> {
  const _DashboardHomeTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.storm_rounded, color: colorScheme.primary, size: 28),
            const SizedBox(width: 8),
            const Text(
              'SkyPulse',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshAll(),
        child: SingleChildScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Search Bar
              _buildSearchBar(context),
              const SizedBox(height: 20),

              // 2. Weather Section
              Obx(() {
                if (controller.isLoadingWeather.value && controller.weather.value == null) {
                  return const SizedBox(
                    height: 180,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final weatherData = controller.weather.value;
                if (weatherData == null) {
                  if (controller.weatherError.value != null) {
                    return _buildErrorCard(
                      context,
                      title: 'Weather Error',
                      message: controller.weatherError.value!,
                      onRetry: () => controller.fetchWeatherByLocation(),
                    );
                  }
                  return const SizedBox.shrink();
                }

                return WeatherCard(
                  weather: weatherData,
                  offlineMessage: controller.weatherOfflineMessage.value,
                );
              }),
              const SizedBox(height: 24),

              // 3. Forecast Section
              Obx(() {
                final weatherData = controller.weather.value;
                if (weatherData == null || weatherData.forecasts.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    ForecastSection(forecasts: weatherData.forecasts),
                    const SizedBox(height: 28),
                  ],
                );
              }),

              // 4. News Section
              Obx(() {
                if (controller.isLoadingNews.value && controller.newsList.isEmpty) {
                  return const NewsShimmerList();
                }

                if (controller.newsError.value != null && controller.newsList.isEmpty) {
                  return _buildErrorCard(
                    context,
                    title: 'News Error',
                    message: controller.newsError.value!,
                    onRetry: () => controller.refreshNews(),
                  );
                }

                return Column(
                  children: [
                    if (controller.newsOfflineMessage.value != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              controller.newsOfflineMessage.value!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    NewsSection(
                      newsList: controller.newsList,
                      isLoadingMore: controller.isLoadingMoreNews.value,
                      hasMore: controller.hasMoreNews.value,
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    return SearchBar(
      elevation: MaterialStateProperty.all(0),
      hintText: 'Search city weather...',
      leading: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
      backgroundColor: MaterialStateProperty.all(theme.colorScheme.surfaceVariant.withOpacity(0.5)),
      onChanged: (value) => controller.searchQuery.value = value,
      trailing: [
        IconButton(
          icon: const Icon(Icons.my_location_rounded),
          tooltip: 'Use current location',
          onPressed: () => controller.fetchWeatherByLocation(),
        ),
      ],
    );
  }

  Widget _buildErrorCard(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onRetry,
  }) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer.withOpacity(0.4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.error.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Retry', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
