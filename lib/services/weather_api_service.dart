import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApiService {
  // Open-Meteo API - Completely free, no API key needed
  // No rate limits for non-commercial use
  static const _baseUrl = 'https://api.open-meteo.com/v1';

  // Get current weather by coordinates
  static Future<WeatherData> getCurrentWeather(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/forecast?latitude=$latitude&longitude=$longitude&current_weather=true&temperature_unit=celsius'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data['current_weather']);
      }
      throw Exception('Failed to load weather');
    } catch (e) {
      throw Exception('Error fetching weather: $e');
    }
  }

  // Get weather forecast
  static Future<WeatherForecast> getWeatherForecast(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/forecast?latitude=$latitude&longitude=$longitude&daily=temperature_2m_max,temperature_2m_min,precipitation_sum,weathercode&timezone=auto'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherForecast.fromJson(data);
      }
      throw Exception('Failed to load forecast');
    } catch (e) {
      throw Exception('Error fetching forecast: $e');
    }
  }

  // Get workout recommendation based on weather
  static String getWorkoutRecommendation(WeatherData weather) {
    final temp = weather.temperature;
    final code = weather.weatherCode;

    // Weather codes: 0=clear, 1-3=partly cloudy, 45-48=fog, 51-67=rain, 71-77=snow, 80-99=thunderstorm
    if (code >= 80) {
      return '⛈️ Thunderstorm! Indoor workout recommended - HIIT or Strength training';
    } else if (code >= 71) {
      return '❄️ Snowy weather! Indoor cardio or yoga session';
    } else if (code >= 51) {
      return '🌧️ Rainy day! Perfect for indoor strength training';
    } else if (temp < 5) {
      return '🥶 Too cold! Indoor workout recommended';
    } else if (temp > 30) {
      return '🥵 Too hot! Early morning or evening outdoor run, or indoor AC workout';
    } else if (temp >= 15 && temp <= 25 && code <= 3) {
      return '☀️ Perfect weather! Outdoor run, cycling, or park workout';
    } else if (code <= 3) {
      return '🌤️ Good weather! Outdoor activities recommended';
    } else {
      return '💪 Any workout is a good workout!';
    }
  }
}

class WeatherData {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final String time;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.time,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['windspeed'] as num?)?.toDouble() ?? 0.0,
      weatherCode: json['weathercode'] ?? 0,
      time: json['time'] ?? '',
    );
  }

  String get weatherDescription {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode <= 48) return 'Foggy';
    if (weatherCode <= 67) return 'Rainy';
    if (weatherCode <= 77) return 'Snowy';
    if (weatherCode <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  String get weatherEmoji {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 48) return '🌫️';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '❄️';
    if (weatherCode <= 99) return '⛈️';
    return '🌤️';
  }
}

class WeatherForecast {
  final List<DailyWeather> daily;

  WeatherForecast({required this.daily});

  factory WeatherForecast.fromJson(Map<String, dynamic> json) {
    final dailyData = json['daily'];
    final times = List<String>.from(dailyData['time']);
    final maxTemps = List<double>.from(dailyData['temperature_2m_max'].map((e) => (e as num).toDouble()));
    final minTemps = List<double>.from(dailyData['temperature_2m_min'].map((e) => (e as num).toDouble()));
    final precipitation = List<double>.from(dailyData['precipitation_sum'].map((e) => (e as num).toDouble()));
    final weatherCodes = List<int>.from(dailyData['weathercode']);

    final daily = <DailyWeather>[];
    for (int i = 0; i < times.length && i < 7; i++) {
      daily.add(DailyWeather(
        date: times[i],
        maxTemp: maxTemps[i],
        minTemp: minTemps[i],
        precipitation: precipitation[i],
        weatherCode: weatherCodes[i],
      ));
    }

    return WeatherForecast(daily: daily);
  }
}

class DailyWeather {
  final String date;
  final double maxTemp;
  final double minTemp;
  final double precipitation;
  final int weatherCode;

  DailyWeather({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.precipitation,
    required this.weatherCode,
  });

  String get weatherEmoji {
    if (weatherCode == 0) return '☀️';
    if (weatherCode <= 3) return '⛅';
    if (weatherCode <= 48) return '🌫️';
    if (weatherCode <= 67) return '🌧️';
    if (weatherCode <= 77) return '❄️';
    if (weatherCode <= 99) return '⛈️';
    return '🌤️';
  }
}
