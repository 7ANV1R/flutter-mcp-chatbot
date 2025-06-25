import 'dart:ui';
import 'package:flutter/material.dart';
import '../../models/weather_data.dart';

class WeatherWidget extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherWidget({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            weatherData.temperatureColor.withValues(alpha: 0.9),
            weatherData.temperatureColor.withValues(alpha: 0.7),
            weatherData.temperatureColor.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: weatherData.temperatureColor.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with city name and demo badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weatherData.cityName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          if (weatherData.country.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              weatherData.country,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (weatherData.isDemo)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'DEMO',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // Main temperature and weather icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Clean weather icon
                    _buildWeatherIcon(),

                    const SizedBox(width: 20),

                    // Temperature and condition
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weatherData.temperature.round()}°',
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              height: 1.0,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Feels like ${weatherData.feelsLike.round()}°',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weatherData.description,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Weather details grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWeatherDetail(
                        icon: '💧',
                        label: 'Humidity',
                        value: '${weatherData.humidity}%',
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      _buildWeatherDetail(
                        icon: '💨',
                        label: 'Wind',
                        value: '${weatherData.windSpeed} m/s',
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      _buildWeatherDetail(
                        icon: '🔽',
                        label: 'Pressure',
                        value: '${weatherData.pressure} hPa',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherIcon() {
    // Get weather condition from the description
    final condition = weatherData.description.toLowerCase();

    // Select appropriate icon based on weather condition
    IconData iconData;
    Color iconColor;

    if (condition.contains('rain') || condition.contains('drizzle')) {
      iconData = Icons.water_drop;
      iconColor = Colors.lightBlue;
    } else if (condition.contains('snow')) {
      iconData = Icons.ac_unit;
      iconColor = Colors.white;
    } else if (condition.contains('thunder') || condition.contains('storm')) {
      iconData = Icons.flash_on;
      iconColor = Colors.yellow;
    } else if (condition.contains('cloud')) {
      iconData = Icons.cloud;
      iconColor = Colors.white;
    } else if (condition.contains('clear') || condition.contains('sun')) {
      iconData = Icons.wb_sunny;
      iconColor = Colors.orange;
    } else if (condition.contains('mist') ||
        condition.contains('fog') ||
        condition.contains('haze')) {
      iconData = Icons.blur_on;
      iconColor = Colors.grey.shade300;
    } else if (condition.contains('wind')) {
      iconData = Icons.air;
      iconColor = Colors.white;
    } else {
      iconData = Icons.wb_cloudy;
      iconColor = Colors.white;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Icon(iconData, size: 48, color: iconColor),
    );
  }

  Widget _buildWeatherDetail({
    required String icon,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.75),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
