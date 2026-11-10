import 'package:flutter/material.dart';

import 'app_theme.dart';

import 'services/book_request_service.dart';

const _navy = AppTheme.navy;
const _gold = AppTheme.gold;
const _cream = AppTheme.cream;
const _paper = AppTheme.paper;
const _muted = AppTheme.muted;

class AdminRequestsPage extends StatefulWidget {
  final String token;

  const AdminRequestsPage({super.key, required this.token});

  @override
  State<AdminRequestsPage> createState() => _AdminRequestsPageState();
}

class _AdminRequestsPageState extends State<AdminRequestsPage> {
  final BookRequestService _service = BookRequestService();
  List<Map<String, dynamic>> _requests = [];
  final Set<int> _processingRequestIds = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final requests = await _service.getPendingRequests(token: widget.token);
      if (!mounted) return;
      setState(() {
        _requests = requests;
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

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? const Color(0xFF9B4840) : const Color(0xFF356B48),
        ),
      );
  }

  Future<void> _approveRequest(Map<String, dynamic> request) async {
    final requestId = int.tryParse('${request['id']}');
    if (requestId == null || _processingRequestIds.contains(requestId)) return;

    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year, now.month, now.day)
          .add(const Duration(days: 7)),
      firstDate: DateTime(now.year, now.month, now.day)
          .add(const Duration(days: 1)),
      lastDate: DateTime(now.year + 5, now.month, now.day),
      helpText: 'Selecione a data de devolução',
      cancelText: 'Cancelar',
      confirmText: 'Continuar',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _navy,
            onPrimary: Colors.white,
            secondary: _gold,
            onSecondary: _navy,
            surface: _paper,
            onSurface: _navy,
          ),
        ),
        child: child!,
      ),
    );
    if (selectedDate == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _paper,
        title: const Text('Confirmar empréstimo',
            style: TextStyle(color: _navy, fontWeight: FontWeight.w800)),
        content: Text(
          'Deseja aprovar o empréstimo de '
          '"${request['book_title'] ?? 'este livro'}"?\n\n'
          'Data de devolução: ${_formatDate(selectedDate)}',
          style: const TextStyle(color: _muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar', style: TextStyle(color: _muted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: _gold, foregroundColor: _navy),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Aprovar',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _processingRequestIds.add(requestId));
    try {
      final dueDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        23,
        59,
        0,
      );
      await _service.approveRequest(
        token: widget.token,
        requestId: requestId,
        dueDate: dueDate,
      );
      if (!mounted) return;
      setState(() {
        _requests.removeWhere(
            (item) => int.tryParse('${item['id']}') == requestId);
      });
      _showMessage('Empréstimo aprovado com sucesso!');
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''),
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _processingRequestIds.remove(requestId));
      }
    }
  }

  Future<void> _rejectRequest(Map<String, dynamic> request) async {
    final requestId = int.tryParse('${request['id']}');
    if (requestId == null || _processingRequestIds.contains(requestId)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _paper,
        title: const Text('Rejeitar solicitação',
            style: TextStyle(color: _navy, fontWeight: FontWeight.w800)),
        content: Text(
          'Deseja realmente rejeitar a solicitação de '
          '"${request['book_title'] ?? 'este livro'}"?',
          style: const TextStyle(color: _muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar', style: TextStyle(color: _muted)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF9B4840),
                foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _processingRequestIds.add(requestId));
    try {
      await _service.rejectRequest(
        token: widget.token,
        requestId: requestId,
      );
      if (!mounted) return;
      setState(() {
        _requests.removeWhere(
            (item) => int.tryParse('${item['id']}') == requestId);
      });
      _showMessage('Solicitação rejeitada com sucesso!');
    } catch (e) {
      _showMessage(e.toString().replaceFirst('Exception: ', ''),
          isError: true);
    } finally {
      if (mounted) {
        setState(() => _processingRequestIds.remove(requestId));
      }
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Solicitações',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Atualizar solicitações',
            onPressed: _loadRequests,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: _gold,
        onRefresh: _loadRequests,
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
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _navy)),
          const SizedBox(height: 12),
          Center(
            child: FilledButton(
              onPressed: _loadRequests,
              style: FilledButton.styleFrom(
                  backgroundColor: _navy, foregroundColor: Colors.white),
              child: const Text('Tentar novamente'),
            ),
          ),
        ],
      );
    }

    if (_requests.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(28),
        children: const [
          SizedBox(height: 125),
          Icon(Icons.inbox_outlined, size: 58, color: _gold),
          SizedBox(height: 15),
          Text(
            'Nenhuma solicitação pendente.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: _navy, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            'Quando alguém solicitar um livro, o pedido aparecerá aqui.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 12, height: 1.4),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 17, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pedidos de empréstimo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('Analise os pedidos e defina a data de devolução.',
                        style: TextStyle(
                            color: Color(0xFFD5DCE5), fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.pending_actions_outlined,
                  color: _gold, size: 34),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            const Text('Pendentes',
                style: TextStyle(
                    color: _navy, fontSize: 16, fontWeight: FontWeight.w800)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: const Color(0xFFF0E9DA),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                _requests.length.toString(),
                style: const TextStyle(
                    color: _navy, fontSize: 11, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._requests.map((request) {
          final requestId = int.tryParse('${request['id']}');
          final processing = requestId != null &&
              _processingRequestIds.contains(requestId);
          return Padding(
            padding: const EdgeInsets.only(bottom: 11),
            child: _requestCard(request, processing),
          );
        }),
      ],
    );
  }

  Widget _requestCard(Map<String, dynamic> request, bool processing) {
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
                width: 48,
                height: 59,
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
                    Text(
                      request['book_title']?.toString() ?? 'Livro sem título',
                      style: const TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text('Código: ${request['book_code'] ?? '-'}',
                        style: const TextStyle(color: _muted, fontSize: 10)),
                    const SizedBox(height: 7),
                    Text(
                      'Solicitante: ${request['user_name'] ?? 'Não informado'}',
                      style: const TextStyle(
                          color: _navy,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      request['user_email']?.toString() ?? '',
                      style: const TextStyle(color: _muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E9DA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Aguardando análise',
                style: TextStyle(
                    color: _navy, fontWeight: FontWeight.w700, fontSize: 10)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      processing ? null : () => _rejectRequest(request),
                  icon: const Icon(Icons.close_rounded, size: 17),
                  label: const Text('Rejeitar'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF9B4840),
                    side: const BorderSide(color: Color(0xFFD8B6AF)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    textStyle: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      processing ? null : () => _approveRequest(request),
                  icon: processing
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _navy),
                        )
                      : const Icon(Icons.check_rounded, size: 17),
                  label: const Text('Aprovar'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _gold,
                    foregroundColor: _navy,
                    disabledBackgroundColor: const Color(0xFFE5D9C2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9)),
                    textStyle: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
