import 'package:hive/hive.dart';

part 'news_model.g.dart';

@HiveType(typeId: 2)
class NewsModel extends HiveObject {
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

  NewsModel({
    required this.title,
    this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    required this.sourceName,
    this.content,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    // Extracts source name from the nested source Map
    String srcName = 'Unknown Source';
    if (json['source'] != null && json['source'] is Map) {
      srcName = json['source']['name']?.toString() ?? 'Unknown Source';
    } else if (json['sourceName'] != null) {
      srcName = json['sourceName'].toString();
    }

    return NewsModel(
      title: json['title']?.toString() ?? 'No Title',
      description: json['description']?.toString(),
      url: json['url']?.toString() ?? '',
      urlToImage: json['urlToImage']?.toString(),
      publishedAt: json['publishedAt']?.toString() ?? '',
      sourceName: srcName,
      content: json['content']?.toString(),
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
    };
  }
}
