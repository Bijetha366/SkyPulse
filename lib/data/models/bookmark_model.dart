import 'package:hive/hive.dart';
import 'news_model.dart';

part 'bookmark_model.g.dart';

@HiveType(typeId: 3)
class BookmarkModel extends HiveObject {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String? description;

  @HiveField(2)
  final String url;

  @HiveField(3)
  final String? urlToImage;

  @HiveField(4)
  final String publishedAt;

  @HiveField(5)
  final String sourceName;

  @HiveField(6)
  final String? content;

  @HiveField(7)
  final DateTime bookmarkedAt;

  BookmarkModel({
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    required this.sourceName,
    this.content,
    required this.bookmarkedAt,
  });

  factory BookmarkModel.fromNewsModel(NewsModel news) {
    return BookmarkModel(
      title: news.title,
      description: news.description,
      url: news.url,
      urlToImage: news.urlToImage,
      publishedAt: news.publishedAt,
      sourceName: news.sourceName,
      content: news.content,
      bookmarkedAt: DateTime.now(),
    );
  }

  NewsModel toNewsModel() {
    return NewsModel(
      title: title,
      description: description,
      url: url,
      urlToImage: urlToImage,
      publishedAt: publishedAt,
      sourceName: sourceName,
      content: content,
    );
  }

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      title: json['title']?.toString() ?? 'No Title',
      description: json['description']?.toString(),
      url: json['url']?.toString() ?? '',
      urlToImage: json['urlToImage']?.toString(),
      publishedAt: json['publishedAt']?.toString() ?? '',
      sourceName: json['sourceName']?.toString() ?? 'Unknown Source',
      content: json['content']?.toString(),
      bookmarkedAt: json['bookmarkedAt'] != null 
          ? DateTime.parse(json['bookmarkedAt'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'url': url,
      'urlToImage': urlToImage,
      'publishedAt': publishedAt,
      'sourceName': sourceName,
      'content': content,
      'bookmarkedAt': bookmarkedAt.toIso8601String(),
    };
  }
}
