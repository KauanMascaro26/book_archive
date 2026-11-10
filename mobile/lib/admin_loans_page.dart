import 'package:flutter/material.dart';

import 'services/admin_loan_service.dart';

class AdminLoansPage extends StatefulWidget {
  final String token;

  const AdminLoansPage({
    super.key,
    required this.token,
  });

  @override
  State<AdminLoansPage> createState() => _AdminLoansPageState();
}

class _AdminLoansPageState extends State<AdminLoansPage> {
  final AdminLoanService _service = AdminLoanService();

  final TextEditingController _searchController =
      TextEditingController();

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
      final loans = await _service.getAllLoans(
        token: widget.token,
      );

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
        return Colors.green.shade700;

      case 'RETURNED':
        return Colors.blue.shade700;

      case 'OVERDUE':
        return Colors.red.shade700;

      default:
        return Colors.grey.shade700;
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
      final status =
          (loan['status'] ?? '').toString().toUpperCase();

      final matchesStatus =
          _selectedStatus == 'ALL' ||
          status == _selectedStatus;

      if (!matchesStatus) return false;

      if (query.isEmpty) return true;

      final userName =
          (loan['user_name'] ?? '').toString().toLowerCase();

      final bookTitle =
          (loan['book_title'] ?? '').toString().toLowerCase();

      final bookAuthor =
          (loan['book_author'] ?? '').toString().toLowerCase();

      final bookCode =
          (loan['book_code'] ?? '').toString().toLowerCase();

      return userName.contains(query) ||
          bookTitle.contains(query) ||
          bookAuthor.contains(query) ||
          bookCode.contains(query);
    }).toList();
  }

  void _applySearch() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Gerenciar Empréstimos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
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
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              _error!,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: FilledButton(
              onPressed: _loadLoans,
              child: const Text('Tentar novamente'),
            ),
          ),
        ],
      );
    }

    final filteredLoans = _filteredLoans;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => _applySearch(),
          decoration: InputDecoration(
            hintText:
                'Pesquisar usuário, livro, autor ou código...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _applySearch();
                    },
                    icon: const Icon(Icons.clear_rounded),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip('Todos', 'ALL'),

              const SizedBox(width: 8),

              _buildFilterChip(
                'Em andamento',
                'ACTIVE',
              ),

              const SizedBox(width: 8),

              _buildFilterChip(
                'Devolvidos',
                'RETURNED',
              ),

              const SizedBox(width: 8),

              _buildFilterChip(
                'Atrasados',
                'OVERDUE',
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        if (_loans.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 110),
            child: Column(
              children: [
                Icon(
                  Icons.library_books_outlined,
                  size: 58,
                  color: Colors.grey,
                ),

                SizedBox(height: 16),

                Text(
                  'Nenhum empréstimo encontrado.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          )
        else if (filteredLoans.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 110),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 58,
                  color: Colors.grey,
                ),

                SizedBox(height: 16),

                Text(
                  'Nenhum empréstimo corresponde ao filtro.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          )
        else
          ...filteredLoans.map(
            (loan) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildLoanCard(loan),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
  ) {
    final selected = _selectedStatus == value;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _selectedStatus = value;
        });
      },
      selectedColor: const Color(0xFFEAF0FF),
      labelStyle: TextStyle(
        color: selected
            ? const Color(0xFF2457C5)
            : Colors.grey.shade700,
        fontWeight:
            selected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: selected
            ? const Color(0xFF2457C5)
            : const Color(0xFFDDE2E8),
      ),
    );
  }

  Widget _buildLoanCard(
    Map<String, dynamic> loan,
  ) {
    final status =
        loan['status']?.toString() ?? 'UNKNOWN';

    final statusColor = _statusColor(status);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF0FF),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF2457C5),
                  size: 30,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan['book_title']?.toString() ??
                          'Livro sem título',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Código: ${loan['book_code'] ?? '-'}',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Autor: ${loan['book_author'] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(
                Icons.person_outline,
                size: 18,
                color: Colors.grey,
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text('Usuário'),
              ),

              Flexible(
                child: Text(
                  loan['user_name']?.toString() ?? '-',
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: Colors.grey,
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text('Data do empréstimo'),
              ),

              Text(
                _formatDate(loan['loan_date']),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.event_available_outlined,
                size: 18,
                color: Colors.grey,
              ),

              const SizedBox(width: 8),

              const Expanded(
                child: Text('Devolver até'),
              ),

              Text(
                _formatDate(loan['due_date']),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (loan['return_date'] != null) ...[
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(
                  Icons.assignment_turned_in_outlined,
                  size: 18,
                  color: Colors.grey,
                ),

                const SizedBox(width: 8),

                const Expanded(
                  child: Text('Data da devolução'),
                ),

                Text(
                  _formatDate(loan['return_date']),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel(status),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}