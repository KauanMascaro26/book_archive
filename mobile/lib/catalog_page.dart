import 'package:flutter/material.dart';
import 'services/book_service.dart';

class CatalogPage extends StatefulWidget {
  final String token;

  const CatalogPage({
    super.key,
    required this.token,
  });

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final BookService bookService = BookService();

  List<dynamic> books = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      final result = await bookService.getBooks(widget.token);

      setState(() {
        books = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Não foi possível carregar os livros.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Archive'),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Text(error!),
                )
              : books.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum livro cadastrado.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        final book = books[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const Icon(
                              Icons.menu_book,
                              size: 40,
                            ),
                            title: Text(
                              book['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${book['author']}\nCódigo: ${book['code']}',
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}