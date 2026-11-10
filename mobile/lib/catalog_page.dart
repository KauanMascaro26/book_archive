import 'package:flutter/material.dart';

import 'app_theme.dart';

import 'book_detail_page.dart';
import 'services/book_service.dart';

const _navy = AppTheme.navy;
const _gold = AppTheme.gold;
const _cream = AppTheme.cream;
const _paper = AppTheme.paper;
const _muted = AppTheme.muted;

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
  String? selectedCategory;
  String? selectedAuthor;

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
    final categories = books
        .map((book) => (book['category'] ?? '').toString().trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final authors = books
        .map((book) => (book['author'] ?? '').toString().trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final filteredBooks = books.where((book) {
      final category = (book['category'] ?? '').toString().trim();
      final title = (book['title'] ?? '').toString().toLowerCase();
      final author = (book['author'] ?? '').toString().toLowerCase();
      final code = (book['code'] ?? '').toString().toLowerCase();
      final matchesQuery = title.contains(normalizedQuery) ||
          author.contains(normalizedQuery) ||
          code.contains(normalizedQuery);
      final matchesCategory = selectedCategory == null ||
          category.toLowerCase() == selectedCategory!.toLowerCase();
      final matchesAuthor = selectedAuthor == null ||
          author == selectedAuthor!.toLowerCase();
      return matchesQuery && matchesCategory && matchesAuthor;
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
                      padding: const EdgeInsets.fromLTRB(16, 11, 16, 12),
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
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pesquise por título, autor ou código do livro.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.76),
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 9),
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
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 8),
                              prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 40),
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
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFilterButton(
                                  context: context,
                                  label: 'Categoria',
                                  value: selectedCategory,
                                  values: categories,
                                  icon: Icons.category_outlined,
                                  onChanged: (value) =>
                                      setState(() => selectedCategory = value),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildFilterButton(
                                  context: context,
                                  label: 'Autor',
                                  value: selectedAuthor,
                                  values: authors,
                                  icon: Icons.person_outline_rounded,
                                  onChanged: (value) =>
                                      setState(() => selectedAuthor = value),
                                ),
                              ),
                            ],
                          ),
                          if (selectedCategory != null || selectedAuthor != null)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => setState(() {
                                  selectedCategory = null;
                                  selectedAuthor = null;
                                }),
                                style: TextButton.styleFrom(
                                  foregroundColor: _gold,
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.filter_alt_off_rounded, size: 15),
                                label: const Text('Limpar filtros', style: TextStyle(fontSize: 11)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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
                                      'Tente ajustar a busca ou os filtros de categoria e autor.',
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      16, 0, 16, 24),
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 220,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 18,
                                    childAspectRatio: 0.50,
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

                                    return Material(
                                      color: _paper,
                                      borderRadius: BorderRadius.circular(14),
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
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                              color: AppTheme.border,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Expanded(
                                                flex: 7,
                                                child: Container(
                                                  decoration: const BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [
                                                        Color(0xFFF4EEDF),
                                                        Color(0xFFE8DFC9),
                                                      ],
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Positioned(
                                                        right: -18,
                                                        top: -22,
                                                        child: Icon(
                                                          Icons.auto_stories_rounded,
                                                          color: _navy.withValues(alpha: 0.06),
                                                          size: 118,
                                                        ),
                                                      ),
                                                      const Center(
                                                        child: Icon(
                                                          Icons.menu_book_rounded,
                                                          color: _navy,
                                                          size: 58,
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
                                                        top: 9,
                                                        right: 9,
                                                        child: Container(
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 5,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            color: _paper.withValues(alpha: 0.92),
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Icon(
                                                                available ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                                                                size: 11,
                                                                color: available ? AppTheme.success : AppTheme.danger,
                                                              ),
                                                              const SizedBox(width: 4),
                                                              Text(
                                                                available ? 'Disponível' : 'Indisponível',
                                                                style: TextStyle(
                                                                  color: available ? AppTheme.success : AppTheme.danger,
                                                                  fontSize: 9,
                                                                  fontWeight: FontWeight.w800,
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
                                              Expanded(
                                                flex: 3,
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
                                                          fontSize: 13.5,
                                                          height: 1.2,
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
                                                      const Spacer(),
                                                      Container(
                                                        width: double.infinity,
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 6,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFF7F4ED),
                                                          borderRadius: BorderRadius.circular(7),
                                                          border: Border.all(color: AppTheme.border),
                                                        ),
                                                        child: Text(
                                                          code,
                                                          textAlign: TextAlign.center,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: const TextStyle(
                                                            color: _muted,
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w700,
                                                            letterSpacing: 0.5,
                                                          ),
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


  Widget _buildInfoTag(IconData icon, String value) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 145),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F0E7),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _muted),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _muted,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> values,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value != null;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showFilterPicker(
        context: context,
        label: label,
        value: value,
        values: values,
        onChanged: onChanged,
      ),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: isSelected ? _gold.withValues(alpha: 0.16) : _paper,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _gold : const Color(0xFFE8E1D4),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? _gold : _muted, size: 17),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                value ?? label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? _navy : _muted,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isSelected ? _gold : _muted,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFilterPicker({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> values,
    required ValueChanged<String?> onChanged,
  }) async {
    final controller = TextEditingController();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final query = controller.text.trim().toLowerCase();
            final filteredValues = values
                .where((item) => item.toLowerCase().contains(query))
                .toList();

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  16 + MediaQuery.of(sheetContext).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 38,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9D2C6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Filtrar por $label',
                            style: const TextStyle(
                              color: _navy,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded, color: _muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Escolha uma opção para refinar o acervo.',
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: controller,
                      onChanged: (_) => setSheetState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Buscar $label'.toLowerCase(),
                        prefixIcon: const Icon(Icons.search_rounded, color: _gold),
                        filled: true,
                        fillColor: _cream,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            leading: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: _cream,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.grid_view_rounded, color: _navy, size: 18),
                            ),
                            title: Text('Todas as opções', style: const TextStyle(color: _navy, fontWeight: FontWeight.w600)),
                            trailing: value == null
                                ? const Icon(Icons.check_circle_rounded, color: _gold)
                                : null,
                            onTap: () => Navigator.pop(sheetContext, ''),
                          ),
                          const Divider(height: 8, color: Color(0xFFEDE7DC)),
                          ...filteredValues.map((item) {
                            final selected = value?.toLowerCase() == item.toLowerCase();
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              title: Text(
                                item,
                                style: TextStyle(
                                  color: _navy,
                                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                                ),
                              ),
                              trailing: selected
                                  ? const Icon(Icons.check_circle_rounded, color: _gold)
                                  : const Icon(Icons.circle_outlined, color: Color(0xFFD5CFC4), size: 20),
                              onTap: () => Navigator.pop(sheetContext, item),
                            );
                          }),
                          if (filteredValues.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                'Nenhuma opção encontrada.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: _muted),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    controller.dispose();
    if (result != null) onChanged(result.isEmpty ? null : result);
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
