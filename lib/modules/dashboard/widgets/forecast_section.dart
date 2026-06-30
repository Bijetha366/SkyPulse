import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/forecast_model.dart';
import '../../../core/utils/weather_helper.dart';

class ForecastSection extends StatelessWidget {
  final List<ForecastModel> forecasts;

  const ForecastSection({
    super.key,
    required this.forecasts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Show maximum of 5 days as per the design requirements
    final displayForecasts = forecasts.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            '5-Day Forecast',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayForecasts.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final forecast = displayForecasts[index];
              
              // Format date string to short day name (e.g., 'Mon')
              final parsedDate = DateTime.tryParse(forecast.date) ?? DateTime.now();
              final dayName = DateFormat('E').format(parsedDate);
              final dateStr = DateFormat('MMM d').format(parsedDate);

              final iconData = WeatherHelper.getWeatherIcon(forecast.weatherCode);
              final isDark = theme.brightness == Brightness.dark;

              return Container(
                width: 95,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: isDark ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isDark
                        ? BorderSide(color: colorScheme.outline.withOpacity(0.15), width: 1)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dayName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.5),
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Icon(
                          iconData,
                          size: 28,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${forecast.maxTemp.toStringAsFixed(0)}° / ${forecast.minTemp.toStringAsFixed(0)}°',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
