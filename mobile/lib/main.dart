import 'package:flutter/material.dart';

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
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Archive'),
      ),
      body: const Center(
        child: Text(
          'Bem-vindo ao Book Archive!',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}

