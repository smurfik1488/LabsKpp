// lib/screens/auth/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:trezo/screens/auth/login_screen.dart';
import 'package:trezo/screens/auth/registration_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Градієнт для кнопок
    const LinearGradient blueGradient = LinearGradient(
      colors: [Color(0xFF00C6FF), Color(0xFF005FFF)], // Від яскраво-блакитного до темно-синього
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Верхня частина - Логотип та опис
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100), // Відступ зверху
                  // Логотип Collectioner (замініть на ваше реальне зображення)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: blueGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.star_half_outlined, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Trezo',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Твій особистий простір для колекціонування',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFFC7C7C7)),
                  ),
                ],
              ),

              // Нижня частина - Кнопки навігації
              Column(
                children: [
                  // Кнопка Увійти з градієнтом
                  _buildGradientButton(
                    context,
                    'Увійти',
                    blueGradient,
                        () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                  ),
                  const SizedBox(height: 16),
                  // Кнопка Створити акаунт (темна/прозора)
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegistrationScreen()));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF1C2128), width: 2), // Колір рамки як у карток
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Створити акаунт', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 32),
                  // Копірайт та посилання
                  const Text(
                    'Колекціонуй • Обмінюйся • Знаходь однодумців',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6C7B8F)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Допоміжний віджет для кнопки з градієнтом
  Widget _buildGradientButton(BuildContext context, String text, LinearGradient gradient, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}