import 'package:flutter/material.dart';

import 'services/auth_service.dart';
import 'home_page.dart';

void main() {
  runApp(const BookArchiveApp());
}

class BookArchiveApp extends StatelessWidget {
  const BookArchiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Archive',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2457C5),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool obscurePassword = true;
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha o e-mail e a senha.'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      // Faz login e busca os dados reais do usuário
      final result = await authService.login(
        email,
        password,
      );

      final user = result['user'];

      final String userName = user['name'];
      final String userRole = user['role'];

      print('Login realizado!');
      print('Usuário: $userName');
      print('Cargo: $userRole');

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userName: userName,
            userRole: userRole,
            token: result['token'] as String,
          ),
        ),
      );
    } catch (e) {
      print('Erro no login: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'E-mail ou senha inválidos.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2457C5),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 30,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // LOGO
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF0FF),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 52,
                      color: Color(0xFF2457C5),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // TÍTULO
                  const Text(
                    'BOOK ARCHIVE',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Color(0xFF172B4D),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Seu acervo de livros',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 35),

                  // E-MAIL
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'E-mail',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF2457C5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // SENHA
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Senha',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF2457C5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ESQUECI SENHA
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Esqueci minha senha',
                        style: TextStyle(
                          color: Color(0xFF2457C5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // BOTÃO ENTRAR
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: loading ? null : login,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2457C5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'ENTRAR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // DIVISOR
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Text(
                          'ou',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // CADASTRO
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Ainda não possui uma conta?',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Cadastre-se',
                          style: TextStyle(
                            color: Color(0xFF2457C5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // RODAPÉ
                  Text(
                    'Acesso seguro ao seu acervo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}