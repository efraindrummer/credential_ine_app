import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://credential-ine-backend.onrender.com/api';

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

  static Future<List<dynamic>> fetchAllIneCredentials() async {
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

  static Future<List<dynamic>> fetchIneCredentials() async {
    final response = await http.get(Uri.parse('$baseUrl/ine'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data;
    }
    throw Exception('Error al cargar credenciales');
  }

  // Obtener una credencial del INE por ID
  static Future<Map<String, dynamic>> fetchIneCredentialById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/ine/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data;
    }
    throw Exception('Error al cargar credencial');
  }
}
