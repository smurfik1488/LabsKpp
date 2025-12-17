// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:trezo/screens/auth/welcome_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _logout(BuildContext context) {
    // Імітація виходу з акаунту та очищення стеку навігації
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Налаштування'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Картка з основними налаштуваннями
              _buildSettingsCard(context, [
                _buildSettingItem(context, 'Редагувати профіль', Icons.person_outline),
                _buildSettingItem(context, 'Сповіщення', Icons.notifications_none),
                _buildSettingItem(context, 'Безпека та конфіденційність', Icons.security),
                _buildSettingItem(context, 'Мова та регіон', Icons.language),
              ]),
              const SizedBox(height: 20),

              // Картка підтримки
              _buildSettingsCard(context, [
                _buildSettingItem(context, 'Допомога та підтримка', Icons.help_outline),
                _buildSettingItem(context, 'Про програму', Icons.info_outline),
              ]),
              const SizedBox(height: 32),

              // Кнопка Вийти (Активна)
              ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text('Вийти з акаунту', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor, // Темний фон
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, IconData icon) {
    // Елемент налаштування у вигляді ListTile
    return InkWell(
      onTap: () {
        // Імітація дії
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Перехід до $title...')),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFC7C7C7)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF6C7B8F)),
          ],
        ),
      ),
    );
  }
}