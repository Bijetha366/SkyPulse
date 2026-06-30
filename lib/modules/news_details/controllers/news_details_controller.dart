import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailsController extends GetxController {
  /// Opens a URL in the platform's default web browser
  Future<void> openArticleInBrowser(String urlString) async {
    final uri = Uri.tryParse(urlString);
    if (uri != null) {
      try {
        final launchSuccess = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launchSuccess) {
          Get.snackbar(
            'Error',
            'Could not launch the article URL.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Could not launch url: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Invalid URL',
        'The article URL is malformed.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
    }
  }

  /// Shares the article link and title using the native platform share dialog
  Future<void> shareArticle(String title, String url) async {
    try {
      await Share.share('$title\n\nRead more at: $url');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not share article: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}
