import 'package:flutter/material.dart';
import 'book_detail_page.dart';
import 'services/book_service.dart';

const _navy = Color(0xFF172B4D);
const _gold = Color(0xFFC6A15B);
const _cream = Color(0xFFF7F4ED);

class CategoriesPage extends StatefulWidget {
  final String token;
  const CategoriesPage({super.key, required this.token});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _service = BookService();
  List<dynamic> _books = [];
  bool _loading = true;
  String? _error;
  String? _category;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final books = await _service.getBooks(widget.token);
      if (!mounted) return;
      setState(() { _books = books; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Não foi possível carregar as categorias.'; _loading = false; });
    }
  }

  String _name(dynamic book) {
    final value = (book['category'] ?? '').toString().trim();
    return value.isEmpty ? 'Sem categoria' : value;
  }

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<dynamic>>{};
    for (final book in _books) {
      final name = _name(book);
      final key = groups.keys.where((item) => item.toLowerCase() == name.toLowerCase()).firstOrNull ?? name;
      groups.putIfAbsent(key, () => []).add(book);
    }
    final categories = groups.keys.toList()..sort((a,b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final selected = _category;
    final selectedBooks = selected == null ? <dynamic>[] : (groups[selected] ?? <dynamic>[]);

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: Text(selected ?? 'Categorias', style: const TextStyle(fontWeight: FontWeight.bold)),
        leading: selected == null ? null : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => _category = null),
        ),
        actions: [IconButton(onPressed: _load, tooltip: 'Atualizar', icon: const Icon(Icons.refresh_rounded))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _gold))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!), const SizedBox(height: 12),
                  FilledButton(onPressed: _load, child: const Text('Tentar novamente')),
                ]))
              : _books.isEmpty
                  ? const Center(child: Text('Ainda não há livros cadastrados.'))
                  : selected == null
                      ? ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            const Text('Explore o acervo por categoria', style: TextStyle(color: _navy, fontSize: 18, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 12),
                            for (final name in categories)
                              Card(
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.category_outlined, color: _gold),
                                  title: Text(name, style: const TextStyle(color: _navy, fontWeight: FontWeight.w700)),
                                  subtitle: Text('${groups[name]!.length} ${groups[name]!.length == 1 ? 'livro' : 'livros'}'),
                                  trailing: const Icon(Icons.chevron_right_rounded),
                                  onTap: () => setState(() => _category = name),
                                ),
                              ),
                          ],
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Text('${selectedBooks.length} ${selectedBooks.length == 1 ? 'livro' : 'livros'} em $selected',
                                style: const TextStyle(color: _navy, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            for (final book in selectedBooks)
                              Card(
                                color: Colors.white,
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.menu_book_rounded, color: _gold),
                                  title: Text((book['title'] ?? 'Sem título').toString(), style: const TextStyle(fontWeight: FontWeight.w700)),
                                  subtitle: Text((book['author'] ?? 'Autor desconhecido').toString()),
                                  trailing: const Icon(Icons.chevron_right_rounded),
                                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => BookDetailPage(book: book, token: widget.token),
                                  )),
                                ),
                              ),
                          ],
                        ),
    );
  }
}
