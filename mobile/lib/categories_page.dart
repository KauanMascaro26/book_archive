import 'package:flutter/material.dart';

import 'app_theme.dart';

import 'book_detail_page.dart';
import 'services/book_service.dart';

const _navy = AppTheme.navy;
const _gold = AppTheme.gold;
const _cream = AppTheme.cream;
const _paper = AppTheme.paper;
const _muted = AppTheme.muted;

class CategoriesPage extends StatefulWidget {
  final String token;

  const CategoriesPage({super.key, required this.token});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final BookService _service = BookService();

  List<dynamic> _books = [];
  bool _loading = true;
  String? _error;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final books = await _service.getBooks(widget.token);
      if (!mounted) return;
      setState(() {
        _books = books;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Não foi possível carregar as categorias.';
        _loading = false;
      });
    }
  }

  String _categoryName(dynamic book) {
    final value = (book['category'] ?? '').toString().trim();
    return value.isEmpty ? 'Sem categoria' : value;
  }

  Map<String, List<dynamic>> _groupBooks() {
    final groups = <String, List<dynamic>>{};

    for (final book in _books) {
      final name = _categoryName(book);
      final existing = groups.keys.cast<String?>().firstWhere(
            (key) => key != null && key.toLowerCase() == name.toLowerCase(),
            orElse: () => null,
          );
      final key = existing ?? name;
      groups.putIfAbsent(key, () => []).add(book);
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupBooks();
    final categories = groups.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final selectedBooks = _selectedCategory == null
        ? <dynamic>[]
        : (groups[_selectedCategory] ?? <dynamic>[]);

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        leading: _selectedCategory == null
            ? null
            : IconButton(
                tooltip: 'Voltar às categorias',
                onPressed: () => setState(() => _selectedCategory = null),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _selectedCategory ?? 'Categorias',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
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
            tooltip: 'Atualizar',
            onPressed: _load,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : _error != null
              ? _buildMessage(
                  icon: Icons.cloud_off_outlined,
                  title: 'Não foi possível carregar',
                  message: _error!,
                  action: 'Tentar novamente',
                  onAction: _load,
                )
              : _books.isEmpty
                  ? _buildMessage(
                      icon: Icons.menu_book_outlined,
                      title: 'Acervo vazio',
                      message: 'Ainda não há livros cadastrados na biblioteca.',
                    )
                  : _selectedCategory == null
                      ? _buildCategories(categories, groups)
                      : _buildCategoryBooks(selectedBooks),
    );
  }

  Widget _buildCategories(
    List<String> categories,
    Map<String, List<dynamic>> groups,
  ) {
    final totalBooks = _books.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.grid_view_rounded, color: _gold, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explore por assunto',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${categories.length} categorias · $totalBooks livros no acervo',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Todas as categorias',
          style: TextStyle(
            color: _navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        for (var index = 0; index < categories.length; index++)
          _buildCategoryCard(categories[index], groups[categories[index]]!.length, index),
      ],
    );
  }

  Widget _buildCategoryCard(String name, int count, int index) {
    final icons = <IconData>[
      Icons.auto_stories_rounded,
      Icons.science_outlined,
      Icons.history_edu_rounded,
      Icons.psychology_alt_outlined,
      Icons.menu_book_rounded,
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _paper,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => setState(() => _selectedCategory = name),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE8E1D4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E9DA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icons[index % icons.length], color: _navy, size: 22),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$count ${count == 1 ? 'livro' : 'livros'}',
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _gold, size: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBooks(List<dynamic> books) {
    if (books.isEmpty) {
      return _buildMessage(
        icon: Icons.menu_book_outlined,
        title: 'Nenhum livro encontrado',
        message: 'Não há livros cadastrados nesta categoria.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        Text(
          '${books.length} ${books.length == 1 ? 'livro disponível no acervo' : 'livros nesta categoria'}',
          style: const TextStyle(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        for (final book in books) _buildBookCard(book),
      ],
    );
  }

  Widget _buildBookCard(dynamic book) {
    final available = book['available'] == true;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _paper,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookDetailPage(book: book, token: widget.token),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE8E1D4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E9DA),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: _navy, size: 27),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (book['title'] ?? 'Sem título').toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        (book['author'] ?? 'Autor desconhecido').toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        available ? 'Disponível' : 'Indisponível',
                        style: TextStyle(
                          color: available
                              ? const Color(0xFF356B48)
                              : const Color(0xFF9B4840),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: _gold),
              ],
            ),
          ),
        ),
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
