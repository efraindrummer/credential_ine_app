import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://172.22.78.175:3000/api/auth';

  // Registro de usuario
  static Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {'user_name': username, 'user_password': password}, // Ajuste aquí
    );

    if (response.statusCode == 201) {
      return true;
    }
    return false;
  }

  // Inicio de sesión
  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {'user_name': username, 'user_password': password}, // Ajuste aquí
    );

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}
