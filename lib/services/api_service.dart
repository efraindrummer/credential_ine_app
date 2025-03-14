import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../models/ine_credential_model.dart';

class ApiService {
  static const String baseUrl =
      'https://credential-ine-backend.onrender.com/api/ine';

  // Login
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

  // Obtener todas las credenciales
  static Future<List<dynamic>> fetchAllIneCredentials() async {
    final response = await http.get(Uri.parse('$baseUrl/ine'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Error al cargar credenciales');
  }

  // Agregar una credencial con solo datos JSON (método existente)
  static Future<void> addIneCredential(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ine/register-ine'),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 201) {
      throw Exception('Error al registrar credencial: ${response.statusCode}');
    }
  }

  // Nuevo método para agregar una credencial con archivos multipart
  static Future<void> addIneCredentialWithFiles(
    IneCredentialModel credential,
    File frontImage,
    File backImage,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/ine/register-ine'),
    );

    // Agregar los campos de texto
    request.fields.addAll({
      'full_name': credential.fullName,
      'curp': credential.curp,
      'birth_date': credential.birthDate,
      'gender': credential.gender,
      'federal_entity': credential.federalEntity,
      'voter_key': credential.voterKey,
      'ocr_code': credential.ocrCode,
      'expiration_date': credential.expirationDate,
      'street': credential.street,
      'house_number': credential.houseNumber,
      'neighborhood': credential.neighborhood,
      'municipality': credential.municipality,
      'state': credential.state,
      'zip_code': credential.zipCode,
    });

    // Agregar las imágenes como archivos multipart
    request.files.add(
      await http.MultipartFile.fromPath(
        'photo_url_inverse', // Nombre del campo esperado por el backend
        frontImage.path,
      ),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'photo_url_reverse', // Nombre del campo esperado por el backend
        backImage.path,
      ),
    );

    // Enviar la solicitud
    final response = await request.send();

    if (response.statusCode != 201) {
      final responseBody = await response.stream.bytesToString();
      throw Exception('Error al registrar credencial: $responseBody');
    }
  }

  // Obtener todas las credenciales (método existente)
  static Future<List<dynamic>> fetchIneCredentials() async {
    final response = await http.get(Uri.parse('$baseUrl/ine'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data;
    }
    throw Exception('Error al cargar credenciales');
  }

  // Obtener una credencial por ID
  static Future<Map<String, dynamic>> fetchIneCredentialById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/ine/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return data;
    }
    throw Exception('Error al cargar credencial');
  }
}
