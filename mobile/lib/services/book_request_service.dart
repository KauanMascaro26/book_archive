
import 'dart:convert';

import 'package:http/http.dart' as http;

class BookRequestService {
  static const String baseUrl = 'http://192.168.1.113:8000';

  Map<String, dynamic> _decodeResponse(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{'data': decoded};
  }

  String _errorMessage(
    Map<String, dynamic> body,
    String fallback,
  ) {
    return body['detail']?.toString() ?? fallback;
  }

  // Solicita um empréstimo.
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

    final body = _decodeResponse(response);

    if (response.statusCode == 201) {
      return body;
    }

    throw Exception(
      _errorMessage(
        body,
        'Não foi possível solicitar o empréstimo.',
      ),
    );
  }

  // Lista as solicitações pendentes para o administrador.
  Future<List<Map<String, dynamic>>> getPendingRequests({
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/book-requests/pending'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final body = _decodeResponse(response);

    if (response.statusCode == 200) {
      final data = body['data'];

      if (data is List) {
        return data
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }

      return <Map<String, dynamic>>[];
    }

    throw Exception(
      _errorMessage(
        body,
        'Não foi possível carregar as solicitações.',
      ),
    );
  }

  // Aprova uma solicitação e informa a data de devolução.
  Future<Map<String, dynamic>> approveRequest({
    required String token,
    required int requestId,
    required DateTime dueDate,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/book-requests/$requestId/approve'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'due_date': dueDate.toIso8601String(),
      }),
    );

    final body = _decodeResponse(response);

    if (response.statusCode == 200) {
      return body;
    }

    throw Exception(
      _errorMessage(
        body,
        'Não foi possível aprovar a solicitação.',
      ),
    );
  }

  // Rejeita uma solicitação pendente.
  Future<Map<String, dynamic>> rejectRequest({
    required String token,
    required int requestId,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/book-requests/$requestId/reject'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    final body = _decodeResponse(response);

    if (response.statusCode == 200) {
      return body;
    }

    throw Exception(
      _errorMessage(
        body,
        'Não foi possível rejeitar a solicitação.',
      ),
    );
  }
}