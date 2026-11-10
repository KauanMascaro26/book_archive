import 'dart:convert';

import 'package:http/http.dart' as http;

class AdminLoanService {
  static const String baseUrl = 'http://192.168.1.113:8000';

  Future<List<Map<String, dynamic>>> getAllLoans({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/loans/admin'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      throw Exception('Formato de resposta inválido.');
    }

    if (response.statusCode == 401) {
      throw Exception('Sessão expirada. Faça login novamente.');
    }

    if (response.statusCode == 403) {
      throw Exception(
        'Apenas administradores podem consultar os empréstimos.',
      );
    }

    throw Exception(
      'Erro ao carregar empréstimos (${response.statusCode}).',
    );
  }
}