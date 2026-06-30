import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../data/models/news_model.dart';
import '../controllers/news_details_controller.dart';
import '../../bookmarks/controllers/bookmarks_controller.dart';

class NewsDetailsView extends GetView<NewsDetailsController> {
  const NewsDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final NewsModel article = Get.arguments as NewsModel;

    final bookmarksController = Get.find<BookmarksController>();

    final parsedDate = DateTime.tryParse(article.publishedAt);
    final formattedDate = parsedDate != null 
        ? DateFormat('MMMM d, yyyy • hh:mm a').format(parsedDate)
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Article Details'),
        actions: [
          // Bookmark toggle icon
          Obx(() {
            final isSaved = bookmarksController.bookmarkedArticles.any(
              (b) => b.url == article.url,
            );
            return IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: isSaved ? colorScheme.primary : null,
              ),
              tooltip: isSaved ? 'Remove from bookmarks' : 'Add to bookmarks',
              onPressed: () => bookmarksController.toggleBookmark(article),
            );
          }),
          // Share icon
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Share Article',
            onPressed: () => controller.shareArticle(article.title, article.url),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero article image
            _buildHeroImage(context, article.urlToImage),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      article.sourceName.toUpperCase(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Article title
                  Text(
                    article.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Published date
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const Divider(height: 32, thickness: 0.5),

                  // Description
                  if (article.description != null && article.description!.isNotEmpty) ...[
                    Text(
                      article.description!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withOpacity(0.85),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Content
                  if (article.content != null && article.content!.isNotEmpty) ...[
                    Text(
                      article.content!.replaceAll(RegExp(r'\[\+\d+ chars\]'), ''),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                        color: colorScheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Launch button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.openArticleInBrowser(article.url),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('Read Full Article'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage(BuildContext context, String? imageUrl) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: size.height * 0.3,
      color: colorScheme.surfaceVariant,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.image_not_supported_rounded,
                color: Colors.grey,
                size: 48,
              ),
            )
          : const Icon(
              Icons.newspaper_rounded,
              color: Colors.grey,
              size: 48,
            ),
    );
  }
}
