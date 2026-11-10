import 'package:flutter/material.dart';

import 'app_theme.dart';

import 'services/loan_service.dart';

const _navy = AppTheme.navy;
const _gold = AppTheme.gold;
const _cream = AppTheme.cream;
const _paper = AppTheme.paper;
const _muted = AppTheme.muted;

class MyLoansPage extends StatefulWidget {
  final String token;

  const MyLoansPage({super.key, required this.token});

  @override
  State<MyLoansPage> createState() => _MyLoansPageState();
}

class _MyLoansPageState extends State<MyLoansPage> {
  final LoanService _service = LoanService();
  List<Map<String, dynamic>> _loans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final loans = await _service.getMyLoans(token: widget.token);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Meus Empréstimos',
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
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _navy),
          ),
          const SizedBox(height: 12),
          Center(
            child: FilledButton(
              onPressed: _loadLoans,
              style: FilledButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar novamente'),
            ),
          ),
        ],
      );
    }

    final currentLoans = _loans.where((loan) {
      final status = (loan['status']?.toString() ?? '').toUpperCase();
      return status == 'ACTIVE' || status == 'OVERDUE';
    }).toList();

    if (currentLoans.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(28),
        children: const [
          SizedBox(height: 120),
          Icon(Icons.menu_book_outlined, size: 58, color: _gold),
          SizedBox(height: 16),
          Text(
            'Você ainda não possui empréstimos.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _navy,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Quando uma solicitação for aprovada, o livro aparecerá aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, height: 1.4),
          ),
        ],
      );
    }

    final activeCount = currentLoans
        .where((loan) =>
            (loan['status']?.toString() ?? '').toUpperCase() == 'ACTIVE')
        .length;
    final overdueCount = currentLoans
        .where((loan) =>
            (loan['status']?.toString() ?? '').toUpperCase() == 'OVERDUE')
        .length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Seus livros',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Acompanhe os prazos dos livros que ainda estão com você.',
                      style: TextStyle(color: Color(0xFFD5DCE5), fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.menu_book_rounded, color: _gold, size: 34),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _summary('Em aberto', currentLoans.length.toString())),
            const SizedBox(width: 9),
            Expanded(child: _summary('Em andamento', activeCount.toString())),
            const SizedBox(width: 9),
            Expanded(child: _summary('Atrasados', overdueCount.toString())),
          ],
        ),
        const SizedBox(height: 17),
        for (final loan in currentLoans) ...[
          _loanCard(loan),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _summary(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: _paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E1D4)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: _navy,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _muted, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _loanCard(Map<String, dynamic> loan) {
    final status = loan['status']?.toString() ?? 'UNKNOWN';
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(15),
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
                width: 49,
                height: 61,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E9DA),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.menu_book_rounded, color: _navy, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan['book_title']?.toString() ?? 'Livro sem título',
                      style: const TextStyle(
                        color: _navy,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Autor: ${loan['book_author'] ?? '-'}',
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Código: ${loan['book_code'] ?? '-'}',
                      style: const TextStyle(color: _muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE8E1D4)),
          ),
          _dateRow(Icons.calendar_today_outlined, 'Data do empréstimo',
              _formatDate(loan['loan_date'])),
          const SizedBox(height: 9),
          _dateRow(Icons.event_available_outlined, 'Devolver até',
              _formatDate(loan['due_date'])),
        ],
      ),
    );
  }

  Widget _dateRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: _gold, size: 17),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
        ),
        Text(
          value,
          style: const TextStyle(
            color: _navy,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
