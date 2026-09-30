
import 'package:flutter/material.dart';

import 'admin_requests_page.dart';
import 'catalog_page.dart';
import 'my_loans_page.dart';
import 'services/loan_service.dart';

const Color navy = Color(0xFF071D35);
const Color navyLight = Color(0xFF102D50);
const Color gold = Color(0xFFE5AF35);
const Color pageBackground = Color(0xFFF2F4F7);
const Color cardWhite = Color(0xFFFFFEFC);
const Color textNavy = Color(0xFF172B45);
const Color mutedText = Color(0xFF718096);

class HomePage extends StatefulWidget {
  final String userName;
  final String userRole;
  final String token;

  const HomePage({
    super.key,
    required this.userName,
    required this.userRole,
    required this.token,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LoanService _loanService = LoanService();
  final TextEditingController _searchController =
      TextEditingController();

  List<Map<String, dynamic>> _loans = [];
  bool _loadingLoans = true;
  String? _loanError;

  bool get _isAdmin =>
      widget.userRole.trim().toUpperCase() == 'ADMIN';

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia!';
    if (hour < 18) return 'Boa tarde!';
    return 'Boa noite!';
  }

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLoans() async {
    if (!mounted) return;

    setState(() {
      _loadingLoans = true;
      _loanError = null;
    });

    try {
      final loans = await _loanService.getMyLoans(
        token: widget.token,
      );

      if (!mounted) return;

      setState(() {
        _loans = loans;
        _loadingLoans = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loanError = e.toString().replaceFirst('Exception: ', '');
        _loadingLoans = false;
      });
    }
  }

  void _openCatalog() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CatalogPage(token: widget.token),
      ),
    );
  }

  void _openMyLoans() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyLoansPage(token: widget.token),
      ),
    ).then((_) {
      if (mounted) _loadLoans();
    });
  }

  void _openAdminRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminRequestsPage(token: widget.token),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponível em breve.'),
        backgroundColor: navy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _searchCatalog() {
    FocusScope.of(context).unfocus();
    _openCatalog();
  }

  int get _activeLoans => _loans.where((loan) {
        return (loan['status'] ?? '').toString().toUpperCase() ==
            'ACTIVE';
      }).length;

  int get _loansDueSoon => _loans.where((loan) {
        final status =
            (loan['status'] ?? '').toString().toUpperCase();
        final dueDate =
            DateTime.tryParse('${loan['due_date'] ?? ''}');

        if (status != 'ACTIVE' || dueDate == null) return false;

        final now = DateTime.now();
        return !dueDate.isBefore(now) &&
            dueDate.difference(now).inDays <= 7;
      }).length;

  String _formatDate(dynamic value) {
    if (value == null) return 'Não informada';

    final date = DateTime.tryParse(value.toString());
    if (date == null) return 'Não informada';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: RefreshIndicator(
        color: gold,
        onRefresh: _loadLoans,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  _buildMainContent(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // Cabeçalho azul-marinho uniforme.
  Widget _buildHeader() {
    return Container(
      color: navy,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${widget.userName}!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _greeting,
                          style: const TextStyle(
                            color: Color(0xFFC7D2E0),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Notificações',
                    onPressed: () =>
                        _showComingSoon('Notificações'),
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: gold,
                      size: 26,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Pesquisa compacta.
              Container(
                height: 46,
                decoration: BoxDecoration(
                  color: navyLight,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: const Color(0xFF294666),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.search_rounded,
                      color: gold,
                      size: 23,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _searchCatalog(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Pesquisar livros, autores...',
                          hintStyle: TextStyle(
                            color: Color(0xFFB7C4D5),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Filtros',
                      onPressed: _searchCatalog,
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.tune_rounded,
                        color: gold,
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              _buildFeaturedBook(),
            ],
          ),
        ),
      ),
    );
  }

  // Livro do mês compacto, reservado para implementação futura.
  Widget _buildFeaturedBook() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 142),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0A223F),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFF294666),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'LIVRO DO MÊS',
                  style: TextStyle(
                    color: gold,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Em breve',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'O livro em destaque será apresentado aqui.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFFC7D2E0),
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: _openCatalog,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: gold,
                      side: const BorderSide(color: gold),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Explorar catálogo',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            flex: 3,
            child: Icon(
              Icons.menu_book_rounded,
              color: Color(0xFF294666),
              size: 70,
            ),
          ),
        ],
      ),
    );
  }

  // Painel branco sobreposto ao cabeçalho azul.
  // A sobreposição é feita pelos cantos arredondados e pelo
  // deslocamento vertical, sem degradê ou faixa cinza.
  Widget _buildMainContent() {
  return Transform.translate(
    offset: const Offset(0, -18),
    child: ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(50),
      ),
      child: Container(
        color: cardWhite,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 34, 16, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeading(
                'Acesso rápido',
                'Ver todos',
                _openCatalog,
              ),
              const SizedBox(height: 10),
              _buildQuickAccessGrid(),

              const SizedBox(height: 22),

              _buildSectionHeading(
                'Meus empréstimos',
                'Ver todos',
                _openMyLoans,
              ),
              const SizedBox(height: 10),
              _buildLoansSection(),

              const SizedBox(height: 22),

              _buildSectionHeading(
                'Últimos adicionados',
                'Ver todos',
                _openCatalog,
              ),
              const SizedBox(height: 10),
              _buildRecentBooks(),

              if (_isAdmin) ...[
                const SizedBox(height: 22),
                _buildAdminSection(),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}

  Widget _buildSectionHeading(
    String title,
    String action,
    VoidCallback onTap,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: textNavy,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: navy,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            minimumSize: const Size(0, 32),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            action,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Os seis atalhos ficam em uma grade compacta de três colunas.
  Widget _buildQuickAccessGrid() {
    final items = <_QuickAccessItem>[
      _QuickAccessItem(
        label: 'Biblioteca',
        icon: Icons.menu_book_outlined,
        onTap: _openCatalog,
      ),
      _QuickAccessItem(
        label: 'Favoritos',
        icon: Icons.favorite_border_rounded,
        onTap: () => _showComingSoon('Favoritos'),
      ),
      _QuickAccessItem(
        label: 'Empréstimos',
        icon: Icons.access_time_rounded,
        onTap: _openMyLoans,
      ),
      _QuickAccessItem(
        label: 'Histórico',
        icon: Icons.history_rounded,
        onTap: () => _showComingSoon('Histórico'),
      ),
      _QuickAccessItem(
        label: 'Categorias',
        icon: Icons.grid_view_rounded,
        onTap: () => _showComingSoon('Categorias'),
      ),
      _QuickAccessItem(
        label: 'Autores',
        icon: Icons.person_outline_rounded,
        onTap: () => _showComingSoon('Autores'),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.22,
      ),
      itemBuilder: (context, index) {
        final item = items[index];

        return Material(
          color: const Color(0xFFFCFBF8),
          borderRadius: BorderRadius.circular(13),
          child: InkWell(
            onTap: item.onTap,
            borderRadius: BorderRadius.circular(13),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: const Color(0xFFE9E8E4),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 7,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: gold, size: 27),
                  const SizedBox(height: 5),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textNavy,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoansSection() {
    if (_loadingLoans) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: gold),
        ),
      );
    }

    if (_loanError != null) {
      return _InfoCard(
        icon: Icons.cloud_off_outlined,
        title: 'Não foi possível carregar',
        message: _loanError!,
        actionLabel: 'Tentar novamente',
        onAction: _loadLoans,
      );
    }

    if (_loans.isEmpty) {
      return _InfoCard(
        icon: Icons.menu_book_outlined,
        title: 'Nenhum empréstimo por enquanto',
        message:
            'Explore o catálogo e encontre seu próximo livro.',
        actionLabel: 'Explorar catálogo',
        onAction: _openCatalog,
      );
    }

    final recentLoans = _loans.take(3).toList();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.menu_book_outlined,
                label: 'Em andamento',
                value: '$_activeLoans',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SummaryCard(
                icon: Icons.event_available_outlined,
                label: 'Vencem em breve',
                value: '$_loansDueSoon',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cardWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE6E9ED),
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < recentLoans.length; i++) ...[
                _buildLoanTile(recentLoans[i]),
                if (i < recentLoans.length - 1)
                  const Divider(
                    height: 1,
                    indent: 14,
                    endIndent: 14,
                    color: Color(0xFFE9EBEF),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoanTile(Map<String, dynamic> loan) {
    final status =
        (loan['status'] ?? '').toString().toUpperCase();
    final title =
        (loan['book_title'] ?? 'Livro sem título').toString();
    final author =
        (loan['book_author'] ?? 'Autor não informado').toString();
    final code = (loan['book_code'] ?? '').toString();
    final dueDate = _formatDate(loan['due_date']);

    final overdue = status == 'OVERDUE';
    final returned = status == 'RETURNED';

    return InkWell(
      onTap: _openMyLoans,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.menu_book_outlined,
                color: navy,
                size: 25,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textNavy,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: mutedText,
                      fontSize: 11,
                    ),
                  ),
                  if (code.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      code,
                      style: const TextStyle(
                        color: mutedText,
                        fontSize: 10,
                      ),
                    ),
                  ],
                  const SizedBox(height: 3),
                  Text(
                    'Devolução: $dueDate',
                    style: TextStyle(
                      color: overdue ? Colors.red.shade700 : navy,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              overdue
                  ? Icons.warning_amber_rounded
                  : returned
                      ? Icons.check_circle_outline_rounded
                      : Icons.access_time_rounded,
              color: overdue ? Colors.red.shade700 : gold,
              size: 23,
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: mutedText,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // Livros de exemplo já presentes na versão inicial.
  // Esta seção poderá ser conectada à API na próxima etapa.
  Widget _buildRecentBooks() {
    const books = [
      ('Dom Casmurro', 'Machado de Assis'),
      ('Memórias Póstumas', 'Machado de Assis'),
    ];

    return SizedBox(
      height: 155,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final book = books[index];

          return SizedBox(
            width: 125,
            child: InkWell(
              onTap: _openCatalog,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 105,
                    width: 125,
                    decoration: BoxDecoration(
                      color: index.isEven
                          ? const Color(0xFFF1E7CF)
                          : navyLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFE4E5E8),
                      ),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 40,
                      color: index.isEven ? navy : gold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.$1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textNavy,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    book.$2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: mutedText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                color: gold,
                size: 24,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Área administrativa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          const Text(
            'Gerencie as solicitações da biblioteca.',
            style: TextStyle(
              color: Color(0xFFC7D2E0),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openAdminRequests,
              style: FilledButton.styleFrom(
                backgroundColor: gold,
                foregroundColor: navy,
              ),
              icon: const Icon(Icons.pending_actions_outlined),
              label: const Text('Gerenciar solicitações'),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  _showComingSoon('Cadastro de livros'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFF6A7D91),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline_rounded),
              label: const Text('Cadastrar livro'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: navy,
        border: Border(
          top: BorderSide(color: Color(0xFF294666)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          child: Row(
            children: [
              _BottomItem(
                icon: Icons.home_outlined,
                label: 'Início',
                selected: true,
                onTap: () {},
              ),
              _BottomItem(
                icon: Icons.menu_book_outlined,
                label: 'Biblioteca',
                onTap: _openCatalog,
              ),
              _BottomItem(
                icon: Icons.search_rounded,
                label: 'Pesquisar',
                onTap: _openCatalog,
              ),
              _BottomItem(
                icon: Icons.person_outline_rounded,
                label: 'Perfil',
                onTap: () => _showComingSoon('Perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAccessItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickAccessItem({
    required this.label,
    required this.icon,
    required this.onTap,
  });
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0xFFE6E9ED),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: gold, size: 23),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: textNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: mutedText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE6E9ED),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: gold, size: 29),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textNavy,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: mutedText,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: navy,
              visualDensity: VisualDensity.compact,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? gold : const Color(0xFFCAD3DF);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 23),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}