import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'book_detail_page.dart';
import 'services/favorite_service.dart';

const _navy = AppTheme.navy;
const _gold = AppTheme.gold;
const _cream = AppTheme.cream;
const _paper = AppTheme.paper;
const _muted = AppTheme.muted;

class FavoritesPage extends StatefulWidget {
  final String token;
  const FavoritesPage({super.key, required this.token});
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FavoriteService _service = FavoriteService();
  List<Map<String, dynamic>> _books = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _loadFavorites(); }

  Future<void> _loadFavorites() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = await _service.getFavorites(widget.token);
      if (!mounted) return;
      setState(() {
        _books = result.map((item) => Map<String, dynamic>.from(item)).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  Future<void> _removeFavorite(Map<String, dynamic> book) async {
    try {
      await _service.removeFavorite(token: widget.token, bookId: (book['id'] as num).toInt());
      if (!mounted) return;
      setState(() => _books.removeWhere((item) => item['id'] == book['id']));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Livro removido dos favoritos.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy, foregroundColor: Colors.white, elevation: 0,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Meus favoritos', style: TextStyle(fontWeight: FontWeight.w800)),
          Text('SUA LISTA DE LEITURA', style: TextStyle(color: _gold, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
        ]),
        actions: [IconButton(tooltip: 'Atualizar favoritos', onPressed: _loadFavorites, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: _gold))
        : _error != null
          ? _empty(Icons.cloud_off_outlined, 'Não foi possível carregar', _error!, action: 'Tentar novamente', onAction: _loadFavorites)
          : _books.isEmpty
            ? _empty(Icons.favorite_border_rounded, 'Sua lista está vazia', 'Abra um livro no catálogo e toque no coração para adicioná-lo aos favoritos.')
            : RefreshIndicator(
                color: _gold, onRefresh: _loadFavorites,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16), itemCount: _books.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    final available = book['available'] == true;
                    return Material(
                      color: _paper, borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => BookDetailPage(book: book, token: widget.token),
                        )).then((_) => _loadFavorites()),
                        child: Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8E1D4))),
                          child: Row(children: [
                            Container(width: 48, height: 60, decoration: BoxDecoration(color: const Color(0xFFF0E9DA), borderRadius: BorderRadius.circular(9)), child: const Icon(Icons.menu_book_rounded, color: _navy, size: 28)),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text((book['title'] ?? 'Sem título').toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _navy, fontSize: 13, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Text((book['author'] ?? 'Autor não informado').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 11)),
                              const SizedBox(height: 5),
                              Text(available ? 'Disponível' : 'Indisponível', style: TextStyle(color: available ? const Color(0xFF356B48) : const Color(0xFF9B4840), fontSize: 10, fontWeight: FontWeight.w700)),
                            ])),
                            IconButton(tooltip: 'Remover dos favoritos', onPressed: () => _removeFavorite(book), icon: const Icon(Icons.favorite_rounded, color: _gold)),
                          ]),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _empty(IconData icon, String title, String message, {String? action, VoidCallback? onAction}) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: _gold, size: 46), const SizedBox(height: 12),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(color: _navy, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 13, height: 1.4)),
        if (action != null && onAction != null) ...[
          const SizedBox(height: 12),
          FilledButton(onPressed: onAction, style: FilledButton.styleFrom(backgroundColor: _navy), child: Text(action)),
        ],
      ]),
    ));
  }
}
