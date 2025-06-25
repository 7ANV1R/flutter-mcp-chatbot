import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/weather_data.dart';

class WeatherWidget extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherWidget({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            weatherData.temperatureColor.withValues(alpha: 0.8),
            weatherData.temperatureColor.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: weatherData.temperatureColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
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
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (weatherData.country.isNotEmpty)
                            Text(
                              weatherData.country,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (weatherData.isDemo)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'DEMO',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
                    // Weather icon
                    Text(
                      weatherData.weatherIcon,
                      style: const TextStyle(fontSize: 80),
                    ),

                    const SizedBox(width: 20),

                    // Temperature and condition
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${weatherData.temperature.round()}°',
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              height: 0.8,
                            ),
                          ),
                          Text(
                            'Feels like ${weatherData.feelsLike.round()}°',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            weatherData.description,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Weather details grid
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWeatherDetail(
                        icon: '💧',
                        label: 'Humidity',
                        value: '${weatherData.humidity}%',
                      ),
                      _buildWeatherDetail(
                        icon: '💨',
                        label: 'Wind',
                        value: '${weatherData.windSpeed} m/s',
                      ),
                      _buildWeatherDetail(
                        icon: '🔽',
                        label: 'Pressure',
                        value: '${weatherData.pressure} hPa',
                      ),
                    ],
                  ),
                ),

                // Powered by MCP badge
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.api, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Powered by MCP',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}
