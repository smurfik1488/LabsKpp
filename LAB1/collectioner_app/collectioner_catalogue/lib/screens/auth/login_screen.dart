import 'package:flutter/material.dart';
import 'package:trezo/screens/main_screen.dart';
import 'package:trezo/screens/auth/registration_screen.dart';
import 'package:trezo/services/AuthService.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  void _navigateToHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
    );
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final user = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Успішний вхід')),
      );
      _navigateToHome(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Помилка входу')),
      );
    }
  }

  void _signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Успішний вхід')),
      );
      _navigateToHome(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Помилка реєстрації')),
      );
    }
  }

  // ---------- ВАЛІДАТОРИ ----------
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
    if (value.length < 6) return "Мінімум 6 символів";
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(leading: const BackButton(), title: const Text('Вітаємо назад!')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey, // <<<<<< ВАЖЛИВО
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Поле Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'your@email.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 16),

              // Поле Пароль
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: '********',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: validatePassword,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Забули пароль?',
                      style: TextStyle(color: Color(0xFF00C6FF))),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _login,
                child: const Text('Увійти'),
              ),

              const SizedBox(height: 24),
              const Center(
                  child: Text('або', style: TextStyle(color: Color(0xFF6C7B8F)))),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _signInWithGoogle,
                icon: Image.asset('assets/icons/google.png', height: 24),
                label: const Text('Продовжити з Google'),
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
                  const Text("Ще не маєте акаунту?",
                      style: TextStyle(color: Color(0xFFC7C7C7))),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const RegistrationScreen()));
                    },
                    child: const Text('Зареєструватися',
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
