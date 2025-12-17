import 'package:flutter/material.dart';
import 'package:trezo/screens/main_screen.dart';
import 'package:trezo/screens/auth/login_screen.dart';
import 'package:trezo/services/AuthService.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayedNameController = TextEditingController();
  final _authService = AuthService();

  // ---------------- ВАЛІДАТОРИ ----------------

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) return "Введіть ім'я";

    if (value.trim().length < 3) return "Мінімум 3 символи";

    if (!RegExp(r"^[a-zA-Zа-яА-ЯіІїЇєЄ0-9_ ]+$").hasMatch(value.trim())) {
      return "Ім'я може містити лише букви, цифри, _ та пробіли";
    }

    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Введіть email";
    }

    const pattern =
        r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$";
    if (!RegExp(pattern).hasMatch(value.trim())) {
      return "Некоректний email";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return "Введіть пароль";

    if (value.length < 6) return "Пароль має містити мінімум 6 символів";

    if (value.contains(" ")) return "Пароль не може містити пробіли";

    return null;
  }

  // ---------------- ЛОГІКА ----------------

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
    );
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final user = await _authService.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _displayedNameController.text.trim(),
    );

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Реєстрація успішна')),
      );
      _navigateToHome(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Помилка реєстрації')),
      );
    }
  }

  void _signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Успішний вхід через Google')),
      );
      _navigateToHome(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Помилка входу через Google')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(leading: const BackButton(), title: const Text('Створити акаунт')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey, // ⬅ ОБОВ’ЯЗКОВО!
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ---------- Ім’я ----------
              TextFormField(
                controller: _displayedNameController,
                decoration: const InputDecoration(
                  hintText: 'Ваше ім\'я',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: validateName,
              ),

              const SizedBox(height: 16),

              // ---------- Email ----------
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'your@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: validateEmail,
              ),

              const SizedBox(height: 16),

              // ---------- Пароль ----------
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Пароль',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: validatePassword,
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _register,
                child: const Text('Зареєструватися'),
              ),

              const SizedBox(height: 24),
              const Center(child: Text('або', style: TextStyle(color: Color(0xFF6C7B8F)))),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _signInWithGoogle,
                icon: Image.asset('assets/icons/google.png', height: 24),
                label: const Text('Реєстрація через Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Вже маєте акаунт?",
                      style: TextStyle(color: Color(0xFFC7C7C7))),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text('Увійти',
                        style: TextStyle(color: Color(0xFF00C6FF))),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
