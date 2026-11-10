import 'dart:convert';
import 'package:http/http.dart' as http;

class FavoriteService {
  static const String baseUrl = 'http://192.168.1.113:8000';
  Map<String, String> _headers(String token) => {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json',
  };

  Future<List<dynamic>> getFavorites(String token) async {
    final response = await http.get(Uri.parse('$baseUrl/favorites/'), headers: _headers(token));
    if (response.statusCode == 200) return jsonDecode(response.body) as List<dynamic>;
    throw Exception(_message(response));
  }

  Future<void> addFavorite({required String token, required int bookId}) async {
    final response = await http.post(Uri.parse('$baseUrl/favorites/$bookId'), headers: _headers(token));
    if (response.statusCode != 200 && response.statusCode != 201) throw Exception(_message(response));
  }

  Future<void> removeFavorite({required String token, required int bookId}) async {
    final response = await http.delete(Uri.parse('$baseUrl/favorites/$bookId'), headers: _headers(token));
    if (response.statusCode != 200) throw Exception(_message(response));
  }

  String _message(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      final detail = decoded is Map ? decoded['detail'] : null;
      if (detail is String && detail.isNotEmpty) return detail;
    } catch (_) {}
    return 'Não foi possível atualizar os favoritos (${response.statusCode}).';
  }
}
