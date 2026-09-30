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
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  Future<void> loadBooks() async {
    try {
      final result = await bookService.getBooks(widget.token);

      if (!mounted) return;

      setState(() {
        books = result;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = 'Não foi possível carregar os livros.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = searchQuery.trim().toLowerCase();
    final filteredBooks = books.where((book) {
      final title = (book['title'] ?? '').toString().toLowerCase();
      final author = (book['author'] ?? '').toString().toLowerCase();
      final code = (book['code'] ?? '').toString().toLowerCase();

      return title.contains(normalizedQuery) ||
          author.contains(normalizedQuery) ||
          code.contains(normalizedQuery);
    }).toList();

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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            loading = true;
                          });
                          loadBooks();
                        },
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar por título, autor ou código',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchQuery.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Limpar busca',
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = '';
                                    });
                                  },
                                  icon: const Icon(Icons.clear),
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: books.isEmpty
                          ? const Center(
                              child: Text(
                                'Nenhum livro cadastrado.',
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          : filteredBooks.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Nenhum livro encontrado.',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: filteredBooks.length,
                                  itemBuilder: (context, index) {
                                    final book = filteredBooks[index];
                                    final isAvailable = book['available'] == true;

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.menu_book,
                                          size: 40,
                                        ),
                                        title: Text(
                                          (book['title'] ?? 'Título desconhecido')
                                              .toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${book['author'] ?? 'Autor desconhecido'}'
                                          '\nCódigo: ${book['code'] ?? '-'}'
                                          '\n${isAvailable ? 'Disponível' : 'Indisponível'}',
                                        ),
                                        isThreeLine: true,
                                        trailing: Icon(
                                          isAvailable
                                              ? Icons.check_circle_outline
                                              : Icons.cancel_outlined,
                                          color: isAvailable
                                              ? Colors.green
                                              : Colors.redAccent,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
    );
  }
}
