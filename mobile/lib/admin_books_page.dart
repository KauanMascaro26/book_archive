import 'package:flutter/material.dart';

import 'services/book_service.dart';

const _navy = Color(0xFF172B4D);
const _gold = Color(0xFFC6A15B);
const _cream = Color(0xFFF7F4ED);
const _paper = Color(0xFFFFFEFC);
const _muted = Color(0xFF727B88);

class AdminBooksPage extends StatefulWidget {
  final String token;

  const AdminBooksPage({super.key, required this.token});

  @override
  State<AdminBooksPage> createState() => _AdminBooksPageState();
}

class _AdminBooksPageState extends State<AdminBooksPage> {
  final BookService _service = BookService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _books = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _service.getBooks(widget.token);
      if (!mounted) return;
      setState(() {
        _books = result.map((item) => Map<String, dynamic>.from(item)).toList();
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

  List<Map<String, dynamic>> get _filteredBooks {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _books;
    return _books.where((book) {
      return [
        book['title'],
        book['author'],
        book['code'],
        book['category'],
      ].any((value) => (value ?? '').toString().toLowerCase().contains(query));
    }).toList();
  }

  Future<void> _showBookForm({Map<String, dynamic>? book}) async {
    final code = TextEditingController(text: book?['code']?.toString() ?? '');
    final title = TextEditingController(text: book?['title']?.toString() ?? '');
    final author = TextEditingController(text: book?['author']?.toString() ?? '');
    final publisher = TextEditingController(text: book?['publisher']?.toString() ?? '');
    final year = TextEditingController(text: book?['year']?.toString() ?? '');
    final category = TextEditingController(text: book?['category']?.toString() ?? '');
    final description = TextEditingController(text: book?['description']?.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    final data = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _paper,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          book == null ? 'Cadastrar livro' : 'Editar livro',
          style: const TextStyle(color: _navy, fontWeight: FontWeight.w800),
        ),
        content: SizedBox(
          width: 440,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(code, 'Código (ex.: M000001)', required: true, maxLength: 7),
                  _field(title, 'Título', required: true, maxLength: 200),
                  _field(author, 'Autor', required: true, maxLength: 150),
                  _field(publisher, 'Editora', maxLength: 150),
                  _field(year, 'Ano de publicação', numeric: true),
                  _field(category, 'Categoria', maxLength: 100),
                  _field(description, 'Descrição', maxLength: 500, maxLines: 3),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: _muted)),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final parsedYear = int.tryParse(year.text.trim());
              if (year.text.trim().isNotEmpty && parsedYear == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Informe um ano válido.')),
                );
                return;
              }
              Navigator.pop(dialogContext, {
                'code': code.text.trim().toUpperCase(),
                'title': title.text.trim(),
                'author': author.text.trim(),
                'publisher': publisher.text.trim().isEmpty ? null : publisher.text.trim(),
                'year': parsedYear,
                'category': category.text.trim().isEmpty ? null : category.text.trim(),
                'description': description.text.trim().isEmpty ? null : description.text.trim(),
              });
            },
            style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: _navy),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    code.dispose();
    title.dispose();
    author.dispose();
    publisher.dispose();
    year.dispose();
    category.dispose();
    description.dispose();

    if (data == null || !mounted) return;
    await _saveBook(data, bookId: book?['id'] as int?);
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool numeric = false,
    int? maxLength,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: TextFormField(
        controller: controller,
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        maxLength: maxLength,
        maxLines: maxLines,
        style: const TextStyle(color: _navy, fontSize: 13),
        validator: required
            ? (value) => value == null || value.trim().isEmpty ? 'Campo obrigatório.' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          counterText: '',
          labelStyle: const TextStyle(color: _muted, fontSize: 12),
          filled: true,
          fillColor: _cream,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8E1D4)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFE8E1D4)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _gold, width: 1.5),
          ),
        ),
      ),
    );
  }

  Future<void> _saveBook(Map<String, dynamic> data, {int? bookId}) async {
    setState(() => _saving = true);
    try {
      if (bookId == null) {
        await _service.createBook(token: widget.token, data: data);
      } else {
        await _service.updateBook(token: widget.token, bookId: bookId, data: data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookId == null ? 'Livro cadastrado com sucesso.' : 'Livro atualizado com sucesso.')),
      );
      await _loadBooks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _paper,
        title: const Text('Excluir livro?', style: TextStyle(color: _navy, fontWeight: FontWeight.w800)),
        content: Text('Deseja realmente excluir "${book['title']}" do acervo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF9B4840)),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      await _service.deleteBook(token: widget.token, bookId: book['id'] as int);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro excluído do acervo.')),
      );
      await _loadBooks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredBooks;
    final available = _books.where((book) => book['available'] == true).length;

    return Scaffold(
      backgroundColor: _cream,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gerenciar Acervo', style: TextStyle(fontWeight: FontWeight.w800)),
            Text('ADMINISTRAÇÃO BIM', style: TextStyle(color: _gold, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar acervo',
            onPressed: _saving ? null : _loadBooks,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : () => _showBookForm(),
        backgroundColor: _gold,
        foregroundColor: _navy,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Cadastrar livro', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Column(
        children: [
          Container(
            color: _navy,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
            child: Row(
              children: [
                _statCard('Livros', _books.length.toString()),
                const SizedBox(width: 9),
                _statCard('Disponíveis', available.toString()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: _navy, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Buscar por título, autor, código ou categoria',
                hintStyle: const TextStyle(color: _muted, fontSize: 11),
                prefixIcon: const Icon(Icons.search_rounded, color: _gold),
                filled: true,
                fillColor: _paper,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E1D4))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E1D4))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _gold, width: 1.5)),
              ),
            ),
          ),
          Expanded(child: _buildList(filtered)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF233D5E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF49617B)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(color: Color(0xFFD5DCE5), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> filtered) {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _gold));
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, color: _gold, size: 42),
              const SizedBox(height: 10),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: _navy)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadBooks,
                style: FilledButton.styleFrom(backgroundColor: _navy),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    if (_books.isEmpty) {
      return const Center(child: Text('Nenhum livro cadastrado.', style: TextStyle(color: _muted)));
    }
    if (filtered.isEmpty) {
      return const Center(child: Text('Nenhum livro encontrado.', style: TextStyle(color: _muted)));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 9),
      itemBuilder: (context, index) {
        final book = filtered[index];
        final isAvailable = book['available'] == true;
        return Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: _paper,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFE8E1D4)),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 55,
                decoration: BoxDecoration(color: const Color(0xFFF0E9DA), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.menu_book_rounded, color: _navy, size: 26),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book['title']?.toString() ?? 'Sem título', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _navy, fontSize: 13, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(book['author']?.toString() ?? 'Autor não informado', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: _muted, fontSize: 11)),
                    const SizedBox(height: 3),
                    Text('Código: ${book['code'] ?? '-'}', style: const TextStyle(color: _muted, fontSize: 10)),
                    const SizedBox(height: 5),
                    Text(isAvailable ? 'Disponível' : 'Indisponível', style: TextStyle(color: isAvailable ? const Color(0xFF356B48) : const Color(0xFF9B4840), fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: _navy),
                onSelected: (value) {
                  if (value == 'edit') _showBookForm(book: book);
                  if (value == 'delete') _confirmDelete(book);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Excluir')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
