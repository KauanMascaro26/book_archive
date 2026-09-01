import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://192.168.1.113:8000';

  Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    // 1. Faz login
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

    if (response.statusCode != 200) {
      throw Exception('E-mail ou senha inválidos');
    }

    final data = jsonDecode(response.body);

    final token = data['access_token'];

    // 2. Busca os dados do usuário
    final userResponse = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (userResponse.statusCode != 200) {
      throw Exception(
        'Não foi possível obter os dados do usuário',
      );
    }

    final user = jsonDecode(userResponse.body);

    // 3. Retorna token + usuário
    return {
      'token': token,
      'user': user,
    };
  }
}