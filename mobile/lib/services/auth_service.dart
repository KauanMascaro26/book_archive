import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://bim-backend-os3d.onrender.com';

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

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      }),
    );

    dynamic decoded;
    if (response.body.isNotEmpty) {
      decoded = jsonDecode(response.body);
    }

    if (response.statusCode == 201 && decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map<String, dynamic>) {
      final detail = decoded['detail'];

      if (detail is List) {
        final messages = detail.map((item) {
          if (item is Map) {
            return item['msg']?.toString() ?? 'Dados inválidos.';
          }
          return item.toString();
        }).join(' ');
        throw Exception(messages);
      }

      throw Exception(
        detail?.toString() ?? 'Não foi possível realizar o cadastro.',
      );
    }

    throw Exception('Não foi possível realizar o cadastro.');
  }
}
