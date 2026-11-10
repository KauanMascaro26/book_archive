import 'package:flutter/material.dart';

import 'services/admin_loan_service.dart';

const _navy = Color(0xFF172B4D);
const _gold = Color(0xFFC6A15B);
const _cream = Color(0xFFF7F4ED);
const _paper = Color(0xFFFFFEFC);
const _muted = Color(0xFF727B88);

class AdminLoansPage extends StatefulWidget {
  final String token;

  const AdminLoansPage({super.key, required this.token});

  @override
  State<AdminLoansPage> createState() => _AdminLoansPageState();
}

class _AdminLoansPageState extends State<AdminLoansPage> {
  final AdminLoanService _service = AdminLoanService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _loans = [];
  String _selectedStatus = 'ALL';
  bool _loading = true;
  String? _error;

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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final loans = await _service.getAllLoans(token: widget.token);
      if (!mounted) return;
      setState(() {
        _loans = loans;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return '-';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return const Color(0xFF356B48);
      case 'RETURNED':
        return _navy;
      case 'OVERDUE':
        return const Color(0xFF9B4840);
      default:
        return _muted;
    }
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'Em andamento';
      case 'RETURNED':
        return 'Devolvido';
      case 'OVERDUE':
        return 'Atrasado';
      default:
        return status;
    }
  }

  List<Map<String, dynamic>> get _filteredLoans {
    final query = _searchController.text.trim().toLowerCase();
    return _loans.where((loan) {
      final status = (loan['status'] ?? '').toString().toUpperCase();
      final isCurrent = status == 'ACTIVE' || status == 'OVERDUE';
      final matchesStatus = isCurrent &&
          (_selectedStatus == 'ALL' || status == _selectedStatus);
      if (!matchesStatus) return false;
      if (query.isEmpty) return true;
      final userName = (loan['user_name'] ?? '').toString().toLowerCase();
      final bookTitle = (loan['book_title'] ?? '').toString().toLowerCase();
      final bookAuthor = (loan['book_author'] ?? '').toString().toLowerCase();
      final bookCode = (loan['book_code'] ?? '').toString().toLowerCase();
      return userName.contains(query) ||
          bookTitle.contains(query) ||
          bookAuthor.contains(query) ||
          bookCode.contains(query);
    }).toList();
  }

  void _applySearch() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Gerenciar Empréstimos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar empréstimos',
            onPressed: _loadLoans,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _gold,
        onRefresh: _loadLoans,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return ListView(
        children: const [
          SizedBox(height: 180),
          Center(child: CircularProgressIndicator(color: _gold)),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.cloud_off_outlined, size: 48, color: _gold),
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center,
              style: const TextStyle(color: _navy)),
          const SizedBox(height: 12),
          Center(
            child: FilledButton(
              onPressed: _loadLoans,
              style: FilledButton.styleFrom(
                  backgroundColor: _navy, foregroundColor: Colors.white),
              child: const Text('Tentar novamente'),
            ),
          ),
        ],
      );
    }

    final filteredLoans = _filteredLoans;
    final active = _loans.where((loan) =>
        (loan['status'] ?? '').toString().toUpperCase() == 'ACTIVE').length;
    final overdue = _loans.where((loan) =>
        (loan['status'] ?? '').toString().toUpperCase() == 'OVERDUE').length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Controle do acervo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Acompanhe os empréstimos em andamento e os atrasos.',
                        style: TextStyle(
                            color: Color(0xFFD5DCE5), fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.library_books_outlined, color: _gold, size: 34),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _summary('Em aberto', (active + overdue).toString())),
            const SizedBox(width: 8),
            Expanded(child: _summary('Ativos', active.toString())),
            const SizedBox(width: 8),
            Expanded(child: _summary('Atrasados', overdue.toString())),
          ],
        ),
        const SizedBox(height: 15),
        TextField(
          controller: _searchController,
          onChanged: (_) => _applySearch(),
          style: const TextStyle(color: _navy, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Pesquisar usuário, livro, autor ou código',
            hintStyle: const TextStyle(color: _muted, fontSize: 12),
            prefixIcon: const Icon(Icons.search_rounded, color: _gold),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _applySearch();
                    },
                    icon: const Icon(Icons.clear_rounded, color: _muted),
                  )
                : null,
            filled: true,
            fillColor: _paper,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E1D4)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE8E1D4)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _gold, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip('Todos', 'ALL'),
              const SizedBox(width: 7),
              _buildFilterChip('Em andamento', 'ACTIVE'),
              const SizedBox(width: 7),
              _buildFilterChip('Atrasados', 'OVERDUE'),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            const Text('Empréstimos em aberto',
                style: TextStyle(
                    color: _navy, fontSize: 16, fontWeight: FontWeight.w800)),
            const Spacer(),
            Text('${filteredLoans.length} encontrados',
                style: const TextStyle(color: _muted, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 10),
        if (_loans.isEmpty)
          _emptyState(Icons.library_books_outlined,
              'Nenhum empréstimo registrado.')
        else if (filteredLoans.isEmpty)
          _emptyState(Icons.search_off_rounded,
              'Nenhum empréstimo corresponde ao filtro.')
        else
          ...filteredLoans.map((loan) => Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: _buildLoanCard(loan),
              )),
      ],
    );
  }

  Widget _summary(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFE8E1D4)),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: _navy, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(label,
              style: const TextStyle(color: _muted, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _emptyState(IconData icon, String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 65),
      child: Column(
        children: [
          Icon(icon, size: 48, color: _gold),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: _navy, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedStatus = value),
      selectedColor: _gold,
      backgroundColor: _paper,
      side: BorderSide(
          color: selected ? _gold : const Color(0xFFE2D9C9)),
      labelStyle: TextStyle(
        color: selected ? _navy : _muted,
        fontSize: 11,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildLoanCard(Map<String, dynamic> loan) {
    final status = loan['status']?.toString() ?? 'UNKNOWN';
    final statusColor = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E1D4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 47,
                height: 58,
                decoration: BoxDecoration(
                    color: const Color(0xFFF0E9DA),
                    borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.menu_book_rounded,
                    color: _navy, size: 27),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loan['book_title']?.toString() ?? 'Livro sem título',
                        style: const TextStyle(
                            color: _navy,
                            fontWeight: FontWeight.w800,
                            fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Autor: ${loan['book_author'] ?? '-'}',
                        style: const TextStyle(color: _muted, fontSize: 11)),
                    Text('Código: ${loan['book_code'] ?? '-'}',
                        style: const TextStyle(color: _muted, fontSize: 10)),
                  ],
                ),
              ),
              _statusBadge(_statusLabel(status), statusColor),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 11),
            child: Divider(height: 1, color: Color(0xFFE8E1D4)),
          ),
          _infoRow(Icons.person_outline, 'Usuário',
              loan['user_name']?.toString() ?? '-'),
          const SizedBox(height: 9),
          _infoRow(Icons.calendar_today_outlined, 'Data do empréstimo',
              _formatDate(loan['loan_date'])),
          const SizedBox(height: 9),
          _infoRow(Icons.event_available_outlined, 'Devolver até',
              _formatDate(loan['due_date'])),
          if (loan['return_date'] != null) ...[
            const SizedBox(height: 9),
            _infoRow(Icons.assignment_turned_in_outlined, 'Data da devolução',
                _formatDate(loan['return_date'])),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 9, fontWeight: FontWeight.w800)),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _gold, size: 16),
        const SizedBox(width: 7),
        Expanded(
            child: Text(label,
                style: const TextStyle(color: _muted, fontSize: 10))),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                  color: _navy, fontSize: 10, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
