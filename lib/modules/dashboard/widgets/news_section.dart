import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../data/models/news_model.dart';
import '../../../routes/app_routes.dart';
import '../../bookmarks/controllers/bookmarks_controller.dart';
import 'news_shimmer.dart';

class NewsSection extends StatelessWidget {
  final List<NewsModel> newsList;
  final bool isLoadingMore;
  final bool hasMore;

  const NewsSection({
    super.key,
    required this.newsList,
    required this.isLoadingMore,
    required this.hasMore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarksController = Get.find<BookmarksController>();

    if (newsList.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(theme),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Icon(Icons.newspaper_rounded, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                const SizedBox(height: 8),
                Text(
                  'No articles available',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitle(theme),
        const SizedBox(height: 12),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(), // Handled by parent scroll
          shrinkWrap: true,
          itemCount: newsList.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == newsList.length) {
              if (isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: NewsCardShimmer(),
                );
              } else {
                return const SizedBox.shrink();
              }
            }

            final article = newsList[index];
            final parsedDate = DateTime.tryParse(article.publishedAt);
            final formattedDate = parsedDate != null 
                ? DateFormat('MMM d, yyyy • hh:mm a').format(parsedDate)
                : '';

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              clipBehavior: Clip.antiAlias,
              elevation: 1,
              child: InkWell(
                onTap: () {
                  // Navigate to News Details view passing the article model
                  Get.toNamed(AppRoutes.newsDetails, arguments: article);
                },
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Image thumbnail
                      _buildImageThumbnail(context, article.urlToImage),
                      // Content details
                      Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article.sourceName,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              article.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    formattedDate,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                // Bookmark toggle
                                Obx(() {
                                  final isSaved = bookmarksController.bookmarkedArticles.any(
                                    (b) => b.url == article.url,
                                  );
                                  return IconButton(
                                    icon: Icon(
                                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                      size: 20,
                                      color: isSaved ? theme.colorScheme.primary : null,
                                    ),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () {
                                      bookmarksController.toggleBookmark(article);
                                    },
                                  );
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        ),
      ],
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Text(
        'Latest News',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(BuildContext context, String? imageUrl) {
    return Container(
      width: 100,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.image_not_supported_rounded,
                color: Colors.grey,
                size: 28,
              ),
            )
          : const Icon(
              Icons.newspaper_rounded,
              color: Colors.grey,
              size: 28,
            ),
    );
  }
}
