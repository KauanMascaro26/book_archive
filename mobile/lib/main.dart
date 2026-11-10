import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'services/auth_service.dart';

const Color bimNavy = AppTheme.navy;
const Color bimGold = AppTheme.gold;
const Color bimCream = AppTheme.cream;
const Color bimField = AppTheme.field;
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const BookArchiveApp());
}

class BookArchiveApp extends StatelessWidget {
  const BookArchiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'BIM - Biblioteca dos Irmãos da Memphis',
      theme: AppTheme.light,
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
        const SnackBar(content: Text('Preencha o e-mail e a senha.')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final result = await authService.login(email, password);
      final user = result['user'];
      final String userName = user['name'];
      final String userRole = user['role'];

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            userName: userName,
            userRole: userRole,
            token: result['token'] as String,
            onLogout: () {
              appNavigatorKey.currentState?.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail ou senha inválidos.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _openRegister() async {
    final registeredEmail = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );

    if (!mounted || registeredEmail == null) return;

    emailController.text = registeredEmail;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cadastro realizado! Agora você pode entrar.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: bimNavy),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: bimField,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      labelStyle: const TextStyle(color: Color(0xFF6D7480)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE6E0D4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFE6E0D4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: bimGold, width: 1.7),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bimCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 30),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo_bim.png',
                    height: 118,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'BIM',
                    style: TextStyle(
                      color: bimNavy,
                      fontSize: 31,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3.2,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'BIBLIOTECA DOS IRMÃOS DA MEMPHIS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bimNavy,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.35,
                    ),
                  ),
                  const SizedBox(height: 34),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(24, 27, 24, 23),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE9E2D5)),
                      boxShadow: [
                        BoxShadow(
                          color: bimNavy.withOpacity(0.07),
                          blurRadius: 22,
                          offset: const Offset(0, 9),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Acesse sua conta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: bimNavy,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 23),
                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: _decoration(
                            label: 'E-mail',
                            icon: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          onSubmitted: (_) {
                            if (!loading) login();
                          },
                          decoration: _decoration(
                            label: 'Senha',
                            icon: Icons.lock_outline_rounded,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: bimNavy,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 53,
                          child: FilledButton(
                            onPressed: loading ? null : login,
                            style: FilledButton.styleFrom(
                              backgroundColor: bimNavy,
                              foregroundColor: bimGold,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(13),
                                side: const BorderSide(color: bimGold, width: 1),
                              ),
                            ),
                            child: loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: bimGold,
                                    ),
                                  )
                                : const Text(
                                    'ENTRAR',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Color(0xFFE6E0D4))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'ou',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                            const Expanded(child: Divider(color: Color(0xFFE6E0D4))),
                          ],
                        ),
                        const SizedBox(height: 13),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'Ainda não tem conta?',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            TextButton(
                              onPressed: _openRegister,
                              style: TextButton.styleFrom(
                                foregroundColor: bimNavy,
                                padding: const EdgeInsets.symmetric(horizontal: 5),
                              ),
                              child: const Text(
                                'Cadastre-se',
                                style: TextStyle(
                                  color: bimNavy,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: bimGold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    'BIBLIOTECA DOS IRMÃOS DA MEMPHIS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: bimNavy,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.05,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Acesso seguro ao seu acervo',
                    style: TextStyle(
                      color: Colors.blueGrey.shade600,
                      fontSize: 11,
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
