import 'dart:convert';
import 'package:http/http.dart' as http;

class QuotesApiService {
  // ZenQuotes API - Completely free, no API key needed
  // Rate limit: 5 requests per 30 seconds
  static const _baseUrl = 'https://zenquotes.io/api';

  // Get quote of the day
  static Future<QuoteData> getQuoteOfDay() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/today'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return QuoteData.fromJson(data[0]);
        }
        throw Exception('No quote found');
      }
      throw Exception('Failed to load quote');
    } catch (e) {
      // Return fallback quote if API fails
      return QuoteData(
        quote: 'Discipline is the bridge between goals and accomplishment.',
        author: 'Jim Rohn',
      );
    }
  }

  // Get random quote
  static Future<QuoteData> getRandomQuote() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/random'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return QuoteData.fromJson(data[0]);
        }
        throw Exception('No quote found');
      }
      throw Exception('Failed to load quote');
    } catch (e) {
      // Return fallback quote if API fails
      return QuoteData(
        quote: 'The only bad workout is the one that didn\'t happen.',
        author: 'Unknown',
      );
    }
  }

  // Get multiple random quotes
  static Future<List<QuoteData>> getRandomQuotes({int count = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/quotes'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.take(count).map((e) => QuoteData.fromJson(e)).toList();
      }
      throw Exception('Failed to load quotes');
    } catch (e) {
      // Return fallback quotes if API fails
      return [
        QuoteData(quote: 'Success is the sum of small efforts repeated day in and day out.', author: 'Robert Collier'),
        QuoteData(quote: 'Your body can stand almost anything. It\'s your mind you have to convince.', author: 'Unknown'),
        QuoteData(quote: 'Don\'t wish for it. Work for it.', author: 'Unknown'),
      ];
    }
  }
}

class QuoteData {
  final String quote;
  final String author;

  QuoteData({
    required this.quote,
    required this.author,
  });

  factory QuoteData.fromJson(Map<String, dynamic> json) {
    return QuoteData(
      quote: json['q'] ?? json['quote'] ?? '',
      author: json['a'] ?? json['author'] ?? 'Unknown',
    );
  }

  String get formatted => '"$quote" — $author';
}
