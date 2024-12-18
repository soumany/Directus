import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:developer' as developer;

class DirectusService {
  final String _baseUrl = dotenv.env['DIRECTUS_API_URL']!;

  Future<List<dynamic>> getHomeContent() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/article'),
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      developer.log('Home Content Response Status: ${response.statusCode}', name: 'DirectusService');
      
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        
        // Ensure we always return a List
        dynamic data = responseBody['data'];
        
        if (data is List) {
          return data;
        } else if (data is Map) {
          // If it's a single object, wrap it in a list
          return [data];
        } else {
          // If data is null or unexpected type, return an empty list
          return [];
        }
      } else {
        throw Exception('Failed to load home content: ${response.body}');
      }
    } catch (e) {
      developer.log('Error fetching home content: $e', name: 'DirectusService', error: e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getGlobalMetadata() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/article'),
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      developer.log('Global Metadata Response Status: ${response.statusCode}', name: 'DirectusService');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        developer.log('Global Metadata: $data', name: 'DirectusService');
        return data is List ? data.first : data;
      } else {
        throw Exception('Failed to load global metadata: ${response.body}');
      }
    } catch (e) {
      developer.log('Error fetching global metadata: $e', name: 'DirectusService', error: e);
      rethrow;
    }
  }
}