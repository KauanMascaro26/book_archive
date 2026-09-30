
import 'package:flutter/material.dart';

import 'services/loan_service.dart';

class MyLoansPage extends StatefulWidget {
  final String token;

  const MyLoansPage({
    super.key,
    required this.token,
  });

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
      final loans = await _service.getMyLoans(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Meus Empréstimos',
          style: TextStyle(fontWeight: FontWeight.bold),
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
          Center(child: CircularProgressIndicator()),
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

    if (_loans.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 150),
          Icon(
            Icons.menu_book_outlined,
            size: 58,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Você ainda não possui empréstimos.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _loans.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final loan = _loans[index];
        final status = loan['status']?.toString() ?? 'UNKNOWN';
        final color = _statusColor(status);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0FF),
                      borderRadius: BorderRadius.circular(12),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Autor: ${loan['book_author'] ?? '-'}',
                          style: const TextStyle(fontSize: 13),
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
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Data do empréstimo')),
                  Text(_formatDate(loan['loan_date'])),
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
                  const Expanded(child: Text('Devolver até')),
                  Text(
                    _formatDate(loan['due_date']),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(status),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}