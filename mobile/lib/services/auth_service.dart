import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://192.168.1.113:8000';

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return data['access_token'];
    }

    throw Exception('E-mail ou senha inválidos');
  }
}