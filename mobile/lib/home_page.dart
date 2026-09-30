import 'package:flutter/material.dart';

import 'catalog_page.dart';
import 'admin_requests_page.dart';

class HomePage extends StatelessWidget {
  final String userName;
  final String userRole;
  final String token;

  const HomePage({
    super.key,
    required this.userName,
    required this.userRole,
    required this.token,
  });

  void _openCatalog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CatalogPage(token: token),
      ),
    );
  }

  void _openAdminRequests(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminRequestsPage(token: token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = userRole == 'ADMIN';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.menu_book_rounded,
              color: Colors.blue,
            ),
            SizedBox(width: 10),
            Text(
              'Book Archive',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu_rounded),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saudação
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1976D2),
                    Color(0xFF42A5F5),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.25),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, $userName! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          isAdmin
                              ? 'Administrador'
                              : 'Membro do Book Archive',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Resumo',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // Cards
            Row(
              children: [
                Expanded(
                  child: _StatusCard(
                    icon: Icons.menu_book_rounded,
                    value: isAdmin ? '245' : '2',
                    label: isAdmin
                        ? 'Livros cadastrados'
                        : 'Livros em posse',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _StatusCard(
                    icon: Icons.schedule_rounded,
                    value: isAdmin ? '8' : '1',
                    label: isAdmin
                        ? 'Solicitações'
                        : 'Expirando em breve',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Seus livros',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                TextButton(
                  onPressed: () => _openCatalog(context),
                  child: const Text('Ver todos'),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Livro 1
            const _BookCard(
              title: 'Dom Casmurro',
              author: 'Machado de Assis',
              code: 'M000001',
              date: '15/09/2026',
            ),

            const SizedBox(height: 12),

            // Livro 2
            const _BookCard(
              title: 'Memórias Póstumas de Brás Cubas',
              author: 'Machado de Assis',
              code: 'M000002',
              date: '28/09/2026',
            ),

            const SizedBox(height: 25),

            // Atalho catálogo
            SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton.icon(
                onPressed: () => _openCatalog(context),
                icon: const Icon(Icons.library_books_rounded),
                label: const Text(
                  'EXPLORAR CATÁLOGO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (isAdmin) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () => _openAdminRequests(context),
                  icon: const Icon(Icons.pending_actions_rounded),
                  label: const Text(
                    'GERENCIAR SOLICITAÇÕES',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),

      // Navegação inferior
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            _openCatalog(context);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}


// Card de status
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatusCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 135,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.blue,
            size: 28,
          ),

          const Spacer(),

          Text(
            value,
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}


// Card de livro
class _BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String code;
  final String date;

  const _BookCard({
    required this.title,
    required this.author,
    required this.code,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.blue,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  author,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Text(
                      code,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(width: 10),

                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Colors.orange,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      date,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}