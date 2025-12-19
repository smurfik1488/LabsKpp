// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:trezo/data/user_data.dart';
import 'package:trezo/screens/settings_screen.dart';
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  (Route<dynamic> route) => false,
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            _buildStatsRow(context),
            _buildActionButtons(context),
            _buildActivitySection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF1C2128),
              child: Icon(Icons.person, color: Colors.white, size: 36),
            ),
          const SizedBox(height: 8),
          Text(UserData.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(UserData.userHandle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(UserData.userBio, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),

          // Інформація про місце та дату
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFFC7C7C7)),
              const SizedBox(width: 4),
              Text(UserData.userLocation, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(width: 16),
              const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFFC7C7C7)),
              const SizedBox(width: 4),
              Text(UserData.userRegistrationDate, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 16),

          // Теги статусу
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatusTag('Тоp колекціонер', const Color(0xFFFF9900), Colors.black),
              const SizedBox(width: 8),
              _buildStatusTag('Активний', const Color(0xFF00C6FF), Colors.white),
            ],
          ),
          const SizedBox(height: 16),

          // Кнопки дій
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Редагувати профіль'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C6FF),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(context, 'Колекції', UserData.collectionsCount),
            _buildStatItem(context, 'Предмети', UserData.itemsCount),
            _buildStatItem(context, 'Обміни', UserData.tradesCount),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, int value) {
    return Column(
      children: [
        Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(color: Color(0xFFC7C7C7))),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(child: _buildSecondaryButton(context, 'Мої запити', Icons.history)),
          const SizedBox(width: 12),
          Expanded(child: _buildSecondaryButton(context, 'Колекції', Icons.collections_bookmark_outlined)),
        ],
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFC7C7C7)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Остання активність', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          // Картка активності 1
          _buildActivityCard(
            context,
            const Icon(Icons.verified_outlined, color: Color(0xFF00C6FF)),
            'Успішний обмін завершено',
            'Обмін монети Liberty 1904\n2 дні тому',
          ),
          const SizedBox(height: 12),
          // Картка активності 2
          _buildActivityCard(
            context,
            const Icon(Icons.grid_view_outlined, color: Color(0xFFFF9900)),
            'Додано нову колекцію',
            'Вінтажні годинники\n1 тиждень тому',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Icon icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: icon.color?.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: icon,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
