import 'package:hive/hive.dart';

part 'forecast_model.g.dart';

@HiveType(typeId: 1)
class ForecastModel extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  final double maxTemp;

  @HiveField(2)
  final double minTemp;

  @HiveField(3)
  final int weatherCode;

  ForecastModel({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    return ForecastModel(
      date: json['date']?.toString() ?? '',
      maxTemp: (json['maxTemp'] as num?)?.toDouble() ?? 0.0,
      minTemp: (json['minTemp'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weatherCode'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'maxTemp': maxTemp,
      'minTemp': minTemp,
      'weatherCode': weatherCode,
    };
  }
}
