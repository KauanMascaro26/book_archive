
import 'package:flutter/material.dart';

import 'services/book_request_service.dart';

class AdminRequestsPage extends StatefulWidget {
  final String token;

  const AdminRequestsPage({
    super.key,
    required this.token,
  });

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
      final requests = await _service.getPendingRequests(
        token: widget.token,
      );

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
          backgroundColor: isError ? Colors.redAccent : Colors.green,
        ),
      );
  }

  Future<void> _approveRequest(Map<String, dynamic> request) async {
    final requestId = int.tryParse('${request['id']}');

    if (requestId == null ||
        _processingRequestIds.contains(requestId)) {
      return;
    }

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
    );

    if (selectedDate == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar empréstimo'),
        content: Text(
          'Deseja aprovar o empréstimo de '
          '"${request['book_title'] ?? 'este livro'}"?\n\n'
          'Data de devolução: '
          '${_formatDate(selectedDate)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Aprovar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _processingRequestIds.add(requestId);
    });

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
          (item) => int.tryParse('${item['id']}') == requestId,
        );
      });

      _showMessage('Empréstimo aprovado com sucesso!');
    } catch (e) {
      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingRequestIds.remove(requestId);
        });
      }
    }
  }

  Future<void> _rejectRequest(Map<String, dynamic> request) async {
    final requestId = int.tryParse('${request['id']}');

    if (requestId == null ||
        _processingRequestIds.contains(requestId)) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rejeitar solicitação'),
        content: Text(
          'Deseja realmente rejeitar a solicitação de '
          '"${request['book_title'] ?? 'este livro'}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _processingRequestIds.add(requestId);
    });

    try {
      await _service.rejectRequest(
        token: widget.token,
        requestId: requestId,
      );

      if (!mounted) return;

      setState(() {
        _requests.removeWhere(
          (item) => int.tryParse('${item['id']}') == requestId,
        );
      });

      _showMessage('Solicitação rejeitada com sucesso!');
    } catch (e) {
      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingRequestIds.remove(requestId);
        });
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
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'Solicitações',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
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
              onPressed: _loadRequests,
              child: const Text('Tentar novamente'),
            ),
          ),
        ],
      );
    }

    if (_requests.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 160),
          Icon(
            Icons.inbox_outlined,
            size: 56,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'Nenhuma solicitação pendente.',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: _requests.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final request = _requests[index];
        final requestId = int.tryParse('${request['id']}');
        final processing = requestId != null &&
            _processingRequestIds.contains(requestId);

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
                    width: 48,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Color(0xFF2457C5),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request['book_title']?.toString() ??
                              'Livro sem título',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Código: ${request['book_code'] ?? '-'}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Solicitante: '
                          '${request['user_name'] ?? 'Não informado'}',
                        ),
                        Text(
                          request['user_email']?.toString() ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pendente',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: processing
                          ? null
                          : () => _rejectRequest(request),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Rejeitar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: processing
                          ? null
                          : () => _approveRequest(request),
                      icon: processing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_rounded),
                      label: const Text('Aprovar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2457C5),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}