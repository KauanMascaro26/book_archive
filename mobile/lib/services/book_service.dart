import 'dart:convert';

import 'package:http/http.dart' as http;

class BookService {
  static const String baseUrl = 'http://192.168.1.113:8000';

  Future<List<dynamic>> getBooks(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/books/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception(_message(response));
  }

  Future<Map<String, dynamic>> createBook({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_message(response));
  }

  Future<Map<String, dynamic>> updateBook({
    required String token,
    required int bookId,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/books/$bookId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_message(response));
  }

  Future<void> deleteBook({
    required String token,
    required int bookId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/books/$bookId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception(_message(response));
    }
  }

  String _message(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      final detail = decoded is Map ? decoded['detail'] : null;
      if (detail is String && detail.isNotEmpty) {
        if (detail == 'Book code already exists') {
          return 'Já existe um livro cadastrado com esse código.';
        }
        if (detail == 'Not authenticated') {
          return 'Sua sessão expirou. Entre novamente.';
        }
        return detail;
      }
    } catch (_) {
      // Usa a mensagem padrão quando a API não retorna JSON.
    }
    return 'Não foi possível concluir a operação (${response.statusCode}).';
  }
}
