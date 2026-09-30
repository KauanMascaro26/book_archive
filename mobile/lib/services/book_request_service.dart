import 'dart:convert';

import 'package:http/http.dart' as http;

class BookRequestService {
  static const String baseUrl = 'http://192.168.1.113:8000';

  Future<Map<String, dynamic>> requestBook({
    required String token,
    required int bookId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/book-requests/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'book_id': bookId}),
    );

    final Map<String, dynamic> body = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode == 201) {
      return body;
    }

    final detail = body['detail']?.toString() ?? 'Não foi possível solicitar o empréstimo.';
    throw Exception(detail);
  }
}
