import 'package:hive/hive.dart';
import 'forecast_model.dart';

part 'weather_model.g.dart';

@HiveType(typeId: 0)
class WeatherModel extends HiveObject {
  @HiveField(0)
  final double temperature;

  @HiveField(1)
  final int weatherCode;

  @HiveField(2)
  final double windSpeed;

  @HiveField(3)
  final double humidity;

  @HiveField(4)
  final String cityName;

  @HiveField(5)
  final String time;

  @HiveField(6)
  final List<ForecastModel> forecasts;

  WeatherModel({
    required this.temperature,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
    required this.cityName,
    required this.time,
    required this.forecasts,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, String cityName) {
    // Current Weather
    final current = json['current_weather'] ?? {};
    final double temp = (current['temperature'] as num?)?.toDouble() ?? 0.0;
    final int code = (current['weathercode'] as num?)?.toInt() ?? 0;
    final double wind = (current['windspeed'] as num?)?.toDouble() ?? 0.0;
    final String timeStr = current['time']?.toString() ?? '';

    // Relative humidity can be extracted from current, current_weather_interval, or hourly
    // We request current=relative_humidity_2m or hourly=relative_humidity_2m.
    // If it's in hourly, we can find the matching time index, or default.
    double humid = 0.0;
    if (json['current'] != null && json['current']['relative_humidity_2m'] != null) {
      humid = (json['current']['relative_humidity_2m'] as num).toDouble();
    } else if (json['hourly'] != null && json['hourly']['relative_humidity_2m'] != null) {
      final times = json['hourly']['time'] as List;
      final humidities = json['hourly']['relative_humidity_2m'] as List;
      final index = times.indexOf(timeStr);
      if (index != -1 && index < humidities.length) {
        humid = (humidities[index] as num).toDouble();
      } else if (humidities.isNotEmpty) {
        humid = (humidities[0] as num).toDouble();
      }
    }

    // Daily Forecast
    final List<ForecastModel> parsedForecasts = [];
    if (json['daily'] != null) {
      final daily = json['daily'];
      final times = daily['time'] as List? ?? [];
      final maxTemps = daily['temperature_2m_max'] as List? ?? [];
      final minTemps = daily['temperature_2m_min'] as List? ?? [];
      final codes = daily['weathercode'] as List? ?? [];

      for (int i = 0; i < times.length; i++) {
        parsedForecasts.add(
          ForecastModel(
            date: times[i]?.toString() ?? '',
            maxTemp: i < maxTemps.length ? (maxTemps[i] as num).toDouble() : 0.0,
            minTemp: i < minTemps.length ? (minTemps[i] as num).toDouble() : 0.0,
            weatherCode: i < codes.length ? (codes[i] as num).toInt() : 0,
          ),
        );
      }
    }

    return WeatherModel(
      temperature: temp,
      weatherCode: code,
      windSpeed: wind,
      humidity: humid,
      cityName: cityName,
      time: timeStr,
      forecasts: parsedForecasts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'weatherCode': weatherCode,
      'windSpeed': windSpeed,
      'humidity': humidity,
      'cityName': cityName,
      'time': time,
      'forecasts': forecasts.map((f) => f.toJson()).toList(),
    };
  }
}
