import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      body: {'username': username, 'password': password},
    );
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<List<dynamic>> fetchIneCredentials() async {
    final response = await http.get(Uri.parse('$baseUrl/ine'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Error al cargar credenciales');
  }

  static Future<void> addIneCredential(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse('$baseUrl/ine/register-ine'),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
