import 'package:flutter/material.dart';

import 'book_detail_page.dart';
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
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        title: const Text(
          'Catálogo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar catálogo',
            onPressed: () {
              setState(() {
                loading = true;
              });
              loadBooks();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 42,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                        ),
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
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar título, autor ou código',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: searchQuery.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Limpar busca',
                                  onPressed: () {
                                    setState(() {
                                      searchQuery = '';
                                    });
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    if (books.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                        child: Row(
                          children: [
                            Text(
                              '${filteredBooks.length} ${filteredBooks.length == 1 ? 'livro' : 'livros'}',
                              style: const TextStyle(
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: books.isEmpty
                          ? const Center(
                              child: Text('Nenhum livro cadastrado.'),
                            )
                          : filteredBooks.isEmpty
                              ? const Center(
                                  child: Text('Nenhum livro encontrado.'),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    0,
                                    16,
                                    20,
                                  ),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.49,
                                  ),
                                  itemCount: filteredBooks.length,
                                  itemBuilder: (context, index) {
                                    final book = filteredBooks[index];
                                    final isAvailable =
                                        book['available'] == true;
                                    final title =
                                        (book['title'] ?? 'Título desconhecido')
                                            .toString();
                                    final author =
                                        (book['author'] ?? 'Autor desconhecido')
                                            .toString();
                                    final code =
                                        (book['code'] ?? '-').toString();
                                    final description =
                                        (book['description'] ?? '')
                                            .toString()
                                            .trim();

                                    return InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => BookDetailPage(
                                              book: book,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Card(
                                      margin: EdgeInsets.zero,
                                      color: Colors.white,
                                      elevation: 1.5,
                                      shadowColor:
                                          Colors.black.withOpacity(0.07),
                                      clipBehavior: Clip.antiAlias,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: Container(
                                              color: const Color(0xFFE7F0FC),
                                              child: Stack(
                                                children: [
                                                  const Center(
                                                    child: Icon(
                                                      Icons.menu_book_rounded,
                                                      size: 58,
                                                      color: Color(0xFF7CA7D9),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    left: 8,
                                                    right: 8,
                                                    bottom: 10,
                                                    child: Text(
                                                      'CAPA EM BREVE',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                        color: Colors.blueGrey
                                                            .shade600,
                                                        fontSize: 9,
                                                        letterSpacing: 1.2,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(
                                                10,
                                                10,
                                                10,
                                                9,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    title,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      height: 1.15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF202B3C),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    author,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.blueGrey,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Expanded(
                                                    child: Text(
                                                      description.isNotEmpty
                                                          ? description
                                                          : 'Descrição ainda não cadastrada.',
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 10,
                                                        height: 1.25,
                                                        color:
                                                            Color(0xFF586579),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 7,
                                                      vertical: 5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isAvailable
                                                          ? const Color(
                                                              0xFFE5F6EC)
                                                          : const Color(
                                                              0xFFFFE9E8),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        8,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          isAvailable
                                                              ? Icons
                                                                  .check_circle_rounded
                                                              : Icons
                                                                  .cancel_rounded,
                                                          size: 12,
                                                          color: isAvailable
                                                              ? const Color(
                                                                  0xFF218653)
                                                              : const Color(
                                                                  0xFFC43D3D),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Flexible(
                                                          child: Text(
                                                            isAvailable
                                                                ? 'Disponível'
                                                                : 'Indisponível',
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: isAvailable
                                                                  ? const Color(
                                                                      0xFF218653)
                                                                  : const Color(
                                                                      0xFFC43D3D),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    code,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 9,
                                                      color: Colors.blueGrey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
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
