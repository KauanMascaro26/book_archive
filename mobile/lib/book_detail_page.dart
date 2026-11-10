import 'package:flutter/material.dart';

import 'app_theme.dart';

import 'services/book_request_service.dart';
import 'services/favorite_service.dart';

const _navy = AppTheme.navy;
const _gold = AppTheme.gold;
const _cream = AppTheme.cream;
const _paper = AppTheme.paper;
const _muted = AppTheme.muted;

class BookDetailPage extends StatefulWidget {
  final dynamic book;
  final String token;

  const BookDetailPage({
    super.key,
    required this.book,
    required this.token,
  });

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final BookRequestService requestService = BookRequestService();
  final FavoriteService favoriteService = FavoriteService();
  bool isFavorite = false;
  bool favoriteLoading = true;
  bool updatingFavorite = false;

  bool sendingRequest = false;
  bool requestSent = false;
  String? requestMessage;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final favorites = await favoriteService.getFavorites(widget.token);
      final bookId = (widget.book['id'] as num).toInt();
      if (!mounted) return;
      setState(() {
        isFavorite = favorites.any((item) => (item['id'] as num).toInt() == bookId);
        favoriteLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => favoriteLoading = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (favoriteLoading || updatingFavorite) return;
    setState(() => updatingFavorite = true);
    try {
      final bookId = (widget.book['id'] as num).toInt();
      if (isFavorite) {
        await favoriteService.removeFavorite(token: widget.token, bookId: bookId);
      } else {
        await favoriteService.addFavorite(token: widget.token, bookId: bookId);
      }
      if (!mounted) return;
      setState(() {
        isFavorite = !isFavorite;
        updatingFavorite = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isFavorite ? 'Adicionado aos favoritos.' : 'Removido dos favoritos.'),
      ));
    } catch (e) {
      if (!mounted) return;
      setState(() => updatingFavorite = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString().replaceFirst('Exception: ', '')),
      ));
    }
  }

  Future<void> _requestBook() async {
    if (sendingRequest || requestSent) return;

    setState(() {
      sendingRequest = true;
      requestMessage = null;
    });

    try {
      await requestService.requestBook(
        token: widget.token,
        bookId: (widget.book['id'] as num).toInt(),
      );

      if (!mounted) return;
      setState(() {
        sendingRequest = false;
        requestSent = true;
        requestMessage =
            'Solicitação enviada! Aguarde a análise do administrador.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        sendingRequest = false;
        requestMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget _metadataItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E1D4)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF0E9DA),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: _navy, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: _muted, fontSize: 11),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final title = (book['title'] ?? 'Título desconhecido').toString();
    final author = (book['author'] ?? 'Autor desconhecido').toString();
    final code = (book['code'] ?? '-').toString();
    final description = (book['description'] ?? '').toString().trim();
    final publisher = (book['publisher'] ?? '').toString().trim();
    final year = (book['year'] ?? '').toString().trim();
    final category = (book['category'] ?? '').toString().trim();
    final isAvailable = book['available'] == true;

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detalhes do livro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
            onPressed: favoriteLoading || updatingFavorite ? null : _toggleFavorite,
            icon: updatingFavorite
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _gold),
                  )
                : Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: _gold,
                  ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 190,
                height: 260,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF4EEDF), Color(0xFFE8DFC9)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: _navy.withValues(alpha: 0.13),
                      blurRadius: 18,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 84,
                        color: _navy,
                      ),
                    ),
                    Positioned(
                      top: 13,
                      left: 13,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _navy,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'BIM',
                          style: TextStyle(
                            color: _gold,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 18,
                      left: 12,
                      right: 12,
                      child: Text(
                        'BIBLIOTECA BIM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _navy.withValues(alpha: 0.6),
                          fontSize: 10,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _navy,
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              author,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 15),
            ),
            const SizedBox(height: 17),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? const Color(0xFFEAF2EA)
                      : const Color(0xFFF8E9E5),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isAvailable
                        ? const Color(0xFFC9DCCB)
                        : const Color(0xFFEBD0CA),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAvailable
                          ? Icons.check_circle_rounded
                          : Icons.lock_outline_rounded,
                      size: 17,
                      color: isAvailable
                          ? const Color(0xFF356B48)
                          : const Color(0xFF9B4840),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      isAvailable ? 'Disponível para empréstimo' : 'Indisponível',
                      style: TextStyle(
                        color: isAvailable
                            ? const Color(0xFF356B48)
                            : const Color(0xFF9B4840),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isAvailable) ...[
              const SizedBox(height: 18),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed:
                      sendingRequest || requestSent ? null : _requestBook,
                  icon: sendingRequest
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _navy,
                          ),
                        )
                      : Icon(
                          requestSent
                              ? Icons.check_rounded
                              : Icons.menu_book_rounded,
                        ),
                  label: Text(
                    sendingRequest
                        ? 'Enviando solicitação...'
                        : requestSent
                            ? 'Solicitação enviada'
                            : 'Solicitar empréstimo',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: _navy,
                    disabledBackgroundColor: const Color(0xFFE5D9C2),
                    disabledForegroundColor: _navy,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
            if (requestMessage != null) ...[
              const SizedBox(height: 11),
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: requestSent
                      ? const Color(0xFFEAF2EA)
                      : const Color(0xFFF8E9E5),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Text(
                  requestMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: requestSent
                        ? const Color(0xFF356B48)
                        : const Color(0xFF9B4840),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 28),
            _sectionTitle('Sobre o livro'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _paper,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: const Color(0xFFE8E1D4)),
              ),
              child: Text(
                description.isNotEmpty
                    ? description
                    : 'A descrição deste livro ainda não foi cadastrada.',
                style: const TextStyle(
                  color: Color(0xFF555F6D),
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ),
            const SizedBox(height: 25),
            _sectionTitle('Informações do exemplar'),
            const SizedBox(height: 11),
            _metadataItem(
              icon: Icons.qr_code_rounded,
              label: 'Código do acervo',
              value: code,
            ),
            if (publisher.isNotEmpty) ...[
              const SizedBox(height: 9),
              _metadataItem(
                icon: Icons.business_outlined,
                label: 'Editora',
                value: publisher,
              ),
            ],
            if (year.isNotEmpty) ...[
              const SizedBox(height: 9),
              _metadataItem(
                icon: Icons.calendar_today_outlined,
                label: 'Ano de publicação',
                value: year,
              ),
            ],
            if (category.isNotEmpty) ...[
              const SizedBox(height: 9),
              _metadataItem(
                icon: Icons.category_outlined,
                label: 'Categoria',
                value: category,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _gold,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
