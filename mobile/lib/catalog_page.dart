import 'package:flutter/material.dart';

import 'book_detail_page.dart';
import 'services/book_service.dart';

const _navy = Color(0xFF172B4D);
const _gold = Color(0xFFC6A15B);
const _cream = Color(0xFFF7F4ED);
const _paper = Color(0xFFFFFEFC);
const _muted = Color(0xFF727B88);

class CatalogPage extends StatefulWidget {
  final String token;

  const CatalogPage({super.key, required this.token});

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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error = 'Não foi possível carregar os livros.';
        loading = false;
      });
    }
  }

  void _retry() {
    setState(() {
      loading = true;
      error = null;
    });
    loadBooks();
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
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Biblioteca', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'ACERVO BIM',
              style: TextStyle(
                color: _gold,
                fontSize: 9,
                letterSpacing: 1.8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar catálogo',
            onPressed: _retry,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : error != null
              ? _buildMessage(
                  icon: Icons.cloud_off_outlined,
                  title: 'Não foi possível carregar o acervo',
                  message: error!,
                  action: 'Tentar novamente',
                  onAction: _retry,
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                      decoration: const BoxDecoration(
                        color: _navy,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(22),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Encontre sua próxima leitura',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Pesquise por título, autor ou código do livro.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.76),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            onChanged: (value) =>
                                setState(() => searchQuery = value),
                            style: const TextStyle(color: _navy, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Buscar no acervo',
                              hintStyle: const TextStyle(color: _muted),
                              prefixIcon:
                                  const Icon(Icons.search, color: _gold),
                              suffixIcon: searchQuery.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Limpar busca',
                                      onPressed: () =>
                                          setState(() => searchQuery = ''),
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: _muted,
                                      ),
                                    ),
                              filled: true,
                              fillColor: _paper,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 13),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: const BorderSide(
                                  color: _gold,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                      child: Row(
                        children: [
                          const Text(
                            'Nosso acervo',
                            style: TextStyle(
                              color: _navy,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${filteredBooks.length} ${filteredBooks.length == 1 ? 'livro' : 'livros'}',
                            style: const TextStyle(
                              color: _muted,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: books.isEmpty
                          ? _buildMessage(
                              icon: Icons.menu_book_outlined,
                              title: 'Acervo vazio',
                              message: 'Ainda não há livros cadastrados.',
                            )
                          : filteredBooks.isEmpty
                              ? _buildMessage(
                                  icon: Icons.search_off_rounded,
                                  title: 'Nenhum resultado',
                                  message:
                                      'Tente buscar por outro título, autor ou código.',
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 24),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.62,
                                  ),
                                  itemCount: filteredBooks.length,
                                  itemBuilder: (context, index) {
                                    final book = filteredBooks[index];
                                    final available =
                                        book['available'] == true;
                                    final title = (book['title'] ??
                                            'Título desconhecido')
                                        .toString();
                                    final author = (book['author'] ??
                                            'Autor desconhecido')
                                        .toString();
                                    final code =
                                        (book['code'] ?? '-').toString();
                                    final description =
                                        (book['description'] ?? '')
                                            .toString()
                                            .trim();

                                    return Material(
                                      color: _paper,
                                      borderRadius: BorderRadius.circular(15),
                                      clipBehavior: Clip.antiAlias,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => BookDetailPage(
                                                book: book,
                                                token: widget.token,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                              color: const Color(0xFFE8E1D4),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  color: const Color(0xFFF0E9DA),
                                                  child: Stack(
                                                    children: [
                                                      const Center(
                                                        child: Icon(
                                                          Icons.menu_book_rounded,
                                                          color: _navy,
                                                          size: 54,
                                                        ),
                                                      ),
                                                      Positioned(
                                                        top: 9,
                                                        left: 9,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 7,
                                                            vertical: 4,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _navy,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(5),
                                                          ),
                                                          child: const Text(
                                                            'BIM',
                                                            style: TextStyle(
                                                              color: _gold,
                                                              fontSize: 9,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              letterSpacing: 1,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Positioned(
                                                        bottom: 9,
                                                        left: 0,
                                                        right: 0,
                                                        child: Text(
                                                          'CAPA EM BREVE',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: _navy
                                                                .withValues(
                                                                    alpha: 0.58),
                                                            fontSize: 8,
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
                                                flex: 6,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        title,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          color: _navy,
                                                          fontSize: 13,
                                                          height: 1.15,
                                                          fontWeight:
                                                              FontWeight.w800,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        author,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          color: _muted,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Expanded(
                                                        child: Text(
                                                          description.isEmpty
                                                              ? 'Descrição ainda não cadastrada.'
                                                              : description,
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              const TextStyle(
                                                            color: _muted,
                                                            fontSize: 10,
                                                            height: 1.3,
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          vertical: 6,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: available
                                                              ? const Color(
                                                                  0xFFEAF2EA)
                                                              : const Color(
                                                                  0xFFF8E9E5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(7),
                                                        ),
                                                        child: Text(
                                                          available
                                                              ? 'Disponível'
                                                              : 'Indisponível',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: available
                                                                ? const Color(
                                                                    0xFF356B48)
                                                                : const Color(
                                                                    0xFF9B4840),
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        code,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          color: _muted,
                                                          fontSize: 9,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String message,
    String? action,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _gold, size: 44),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _navy,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 13, height: 1.4),
            ),
            if (action != null && onAction != null) ...[
              const SizedBox(height: 12),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  foregroundColor: Colors.white,
                ),
                child: Text(action),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
