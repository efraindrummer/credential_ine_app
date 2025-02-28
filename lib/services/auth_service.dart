import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl =
      'https://credential-ine-backend.onrender.com/api/auth';

  // Registro de usuario
  static Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_name': username, 'user_password': password}),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'data': responseData};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'error': errorData};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Inicio de sesión
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_name': username, 'user_password': password}),
      );

      print(response.body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {'success': true, 'data': responseData};
      } else {
        final errorData = jsonDecode(response.body);
        return {'success': false, 'error': errorData};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
