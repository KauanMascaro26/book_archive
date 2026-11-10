import 'package:flutter/material.dart';
import 'services/loan_service.dart';
import 'services/admin_loan_service.dart';

const _navy = Color(0xFF172B4D);
const _gold = Color(0xFFC6A15B);
const _cream = Color(0xFFF7F4ED);
const _paper = Color(0xFFFFFEFC);
const _muted = Color(0xFF727B88);

class LoanHistoryPage extends StatefulWidget {
  final String token;
  final bool isAdmin;
  const LoanHistoryPage({super.key, required this.token, this.isAdmin = false});
  @override
  State<LoanHistoryPage> createState() => _LoanHistoryPageState();
}

class _LoanHistoryPageState extends State<LoanHistoryPage> {
  final LoanService _service = LoanService();
  final AdminLoanService _adminService = AdminLoanService();
  List<Map<String, dynamic>> _loans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _loadHistory(); }

  Future<void> _loadHistory() async {
    setState(() { _loading = true; _error = null; });
    try {
      final result = widget.isAdmin
          ? await _adminService.getAllLoans(token: widget.token)
          : await _service.getMyLoans(token: widget.token);
      if (!mounted) return;
      setState(() { _loans = result; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString().replaceFirst('Exception: ', ''); _loading = false; });
    }
  }

  List<Map<String, dynamic>> get _filteredLoans => _loans
      .where((loan) => (loan['status']?.toString() ?? '').toUpperCase() == 'RETURNED')
      .toList()
    ..sort((a, b) {
      final dateA = DateTime.tryParse('${a['return_date'] ?? ''}') ?? DateTime(1970);
      final dateB = DateTime.tryParse('${b['return_date'] ?? ''}') ?? DateTime(1970);
      return dateB.compareTo(dateA);
    });

  String _date(dynamic value) {
    if (value == null) return 'Não registrado';
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return 'Não registrado';
    final date = parsed.toLocal();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _statusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return 'Em andamento';
      case 'RETURNED': return 'Devolvido';
      case 'OVERDUE': return 'Atrasado';
      default: return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE': return const Color(0xFF356B48);
      case 'RETURNED': return _navy;
      case 'OVERDUE': return const Color(0xFF9B4840);
      default: return _muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final returned = _loans.where((loan) => (loan['status']?.toString() ?? '').toUpperCase() == 'RETURNED').length;

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy, foregroundColor: Colors.white, elevation: 0,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Histórico', style: TextStyle(fontWeight: FontWeight.w800)),
          Text(widget.isAdmin ? 'DEVOLUÇÕES DE TODO O ACERVO' : 'CONSULTA DE EMPRÉSTIMOS', style: TextStyle(color: _gold, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
        ]),
        actions: [IconButton(tooltip: 'Atualizar histórico', onPressed: _loading ? null : _loadHistory, icon: const Icon(Icons.refresh_rounded))],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: _gold))
        : _error != null
          ? _message(Icons.cloud_off_outlined, 'Não foi possível carregar o histórico', _error!, action: 'Tentar novamente', onAction: _loadHistory)
          : RefreshIndicator(
              color: _gold, onRefresh: _loadHistory,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(16)),
                    child: const Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(widget.isAdmin ? 'Histórico geral de devoluções' : 'Seus empréstimos concluídos', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                        SizedBox(height: 5),
                        Text(widget.isAdmin ? 'Consulte todos os livros devolvidos, quem realizou o empréstimo e as datas.' : 'Consulte os livros que você já devolveu e as datas de cada empréstimo.', style: TextStyle(color: Color(0xFFD5DCE5), fontSize: 11, height: 1.4)),
                      ])),
                      Icon(Icons.history_rounded, color: _gold, size: 35),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    _summary('Devolvidos', returned),
                  ]),
                  const SizedBox(height: 18),
                  const SizedBox(height: 15),
                  const Text('Empréstimos devolvidos', style: TextStyle(color: _navy, fontSize: 14, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  if (_filteredLoans.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      child: _message(Icons.history_toggle_off_rounded, 'Nenhum registro encontrado',
                        widget.isAdmin ? 'Quando um livro for devolvido, o registro aparecerá aqui.' : 'Quando você devolver um livro, o registro ficará disponível aqui.'),
                    )
                  else
                    for (final loan in _filteredLoans) ...[
                      _loanCard(loan),
                      const SizedBox(height: 10),
                    ],
                ],
              ),
            ),
    );
  }

  Widget _summary(String label, int value) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 3),
      decoration: BoxDecoration(color: _paper, borderRadius: BorderRadius.circular(11), border: Border.all(color: const Color(0xFFE8E1D4))),
      child: Column(children: [
        Text(value.toString(), style: const TextStyle(color: _navy, fontSize: 19, fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(label, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 9)),
      ]),
    ),
  );

  Widget _loanCard(Map<String, dynamic> loan) {
    final status = loan['status']?.toString() ?? 'UNKNOWN';
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _paper, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8E1D4))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 43, height: 53, decoration: BoxDecoration(color: const Color(0xFFF0E9DA), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.menu_book_rounded, color: _navy, size: 25)),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text((loan['book_title'] ?? 'Livro sem título').toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _navy, fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 3),
            Text((loan['book_author'] ?? 'Autor não informado').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 11)),
            Text('Código: ${loan['book_code'] ?? '-'}', style: const TextStyle(color: _muted, fontSize: 10)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(18)),
            child: Text(_statusLabel(status), style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
          ),
        ]),
        const Padding(padding: EdgeInsets.symmetric(vertical: 11), child: Divider(height: 1, color: Color(0xFFE8E1D4))),
        if (widget.isAdmin) ...[
          _dateRow(Icons.person_outline_rounded, 'Emprestado para', (loan['user_name'] ?? 'Usuário não informado').toString()),
          const SizedBox(height: 8),
        ],
        _dateRow(Icons.login_rounded, 'Retirado em', _date(loan['loan_date'])),
        const SizedBox(height: 8),
        _dateRow(Icons.event_outlined, 'Prazo de devolução', _date(loan['due_date'])),
        if (loan['return_date'] != null) ...[
          const SizedBox(height: 8),
          _dateRow(Icons.check_circle_outline_rounded, 'Devolvido em', _date(loan['return_date'])),
        ],
      ]),
    );
  }

  Widget _dateRow(IconData icon, String label, String value) => Row(children: [
    Icon(icon, color: _gold, size: 16),
    const SizedBox(width: 8),
    Expanded(child: Text(label, style: const TextStyle(color: _muted, fontSize: 10))),
    Text(value, style: const TextStyle(color: _navy, fontSize: 10, fontWeight: FontWeight.w700)),
  ]);

  Widget _message(IconData icon, String title, String message, {String? action, VoidCallback? onAction}) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: _gold, size: 43), const SizedBox(height: 11),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(color: _navy, fontSize: 15, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _muted, fontSize: 12, height: 1.4)),
        if (action != null && onAction != null) ...[
          const SizedBox(height: 12),
          FilledButton(onPressed: onAction, style: FilledButton.styleFrom(backgroundColor: _navy), child: Text(action)),
        ],
      ]),
    ));
  }
}
