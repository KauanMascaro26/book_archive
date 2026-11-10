
import 'dart:convert';

import 'package:http/http.dart' as http;

class LoanService {
  static const String baseUrl = 'http://192.168.1.113:8000';

  Future<List<Map<String, dynamic>>> getMyLoans({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/loans/my-loans'),
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
      throw Exception('Você não tem permissão para consultar empréstimos.');
    }

    throw Exception(
      'Erro ao carregar empréstimos (${response.statusCode}).',
    );
  }
}