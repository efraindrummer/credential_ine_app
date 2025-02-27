import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:3000/api/auth';

  static Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }

  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
