import 'package:flutter/material.dart';

class BookDetailPage extends StatelessWidget {
  final dynamic book;

  const BookDetailPage({
    super.key,
    required this.book,
  });

  Widget _metadataItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    if (value.trim().isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF4979B8)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF202B3C),
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
    final title = (book['title'] ?? 'Título desconhecido').toString();
    final author = (book['author'] ?? 'Autor desconhecido').toString();
    final code = (book['code'] ?? '-').toString();
    final description = (book['description'] ?? '').toString().trim();
    final publisher = (book['publisher'] ?? '').toString().trim();
    final year = (book['year'] ?? '').toString().trim();
    final category = (book['category'] ?? '').toString().trim();
    final isAvailable = book['available'] == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FB),
        title: const Text(
          'Detalhes do livro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 190,
                height: 270,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1ECFA),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 76,
                        color: Color(0xFF7CA7D9),
                      ),
                    ),
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 18,
                      child: Text(
                        'CAPA EM BREVE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blueGrey.shade600,
                          fontSize: 10,
                          letterSpacing: 1.4,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                height: 1.2,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202B3C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              author,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? const Color(0xFFE5F6EC)
                      : const Color(0xFFFFE9E8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAvailable
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 17,
                      color: isAvailable
                          ? const Color(0xFF218653)
                          : const Color(0xFFC43D3D),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      isAvailable ? 'Disponível para empréstimo' : 'Indisponível',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isAvailable
                            ? const Color(0xFF218653)
                            : const Color(0xFFC43D3D),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Sobre o livro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202B3C),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description.isNotEmpty
                  ? description
                  : 'A descrição deste livro ainda não foi cadastrada.',
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: Color(0xFF586579),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Informações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF202B3C),
              ),
            ),
            const SizedBox(height: 12),
            _metadataItem(
              icon: Icons.qr_code_rounded,
              label: 'Código do acervo',
              value: code,
            ),
            if (publisher.isNotEmpty) ...[
              const SizedBox(height: 10),
              _metadataItem(
                icon: Icons.business_outlined,
                label: 'Editora',
                value: publisher,
              ),
            ],
            if (year.isNotEmpty) ...[
              const SizedBox(height: 10),
              _metadataItem(
                icon: Icons.calendar_today_outlined,
                label: 'Ano de publicação',
                value: year,
              ),
            ],
            if (category.isNotEmpty) ...[
              const SizedBox(height: 10),
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
}
