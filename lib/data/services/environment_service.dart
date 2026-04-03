import 'dart:math';

class EnvironmentData {
  final int aqi;
  final String aqiStatus; // Good, Moderate, Unhealthy
  final double temperature;
  final String waterQuality; // Safe, Boil Advisory
  final String weatherCondition; // Sunny, Cloudy, Rain

  EnvironmentData({
    required this.aqi,
    required this.aqiStatus,
    required this.temperature,
    required this.waterQuality,
    required this.weatherCondition,
  });
}

class EnvironmentService {
  // Mock service for now
  Future<EnvironmentData> getEnvironmentData() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final random = Random();

    // Simulate some variance
    final aqi = 45 + random.nextInt(60);
    String status = 'Good';
    if (aqi > 50) status = 'Moderate';
    if (aqi > 100) status = 'Unhealthy';

    return EnvironmentData(
      aqi: aqi,
      aqiStatus: status,
      temperature: 28.5 + random.nextDouble() * 2,
      waterQuality: random.nextBool() ? 'Safe' : 'Boil Advisory',
      weatherCondition: 'Sunny',
    );
  }
}


