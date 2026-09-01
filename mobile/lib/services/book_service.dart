import 'dart:convert';

import 'package:http/http.dart' as http;

class BookService {
  static const String baseUrl = 'http://192.168.1.113:8000';

  Future<List<dynamic>> getBooks(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/books/'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception('Erro ao carregar livros');
  }
}