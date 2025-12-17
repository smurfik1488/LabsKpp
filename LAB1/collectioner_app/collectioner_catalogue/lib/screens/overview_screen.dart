// lib/screens/overview_screen.dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/observer.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(context),

        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () {},
          ),
        ],

        // Використовуємо PreferredSize для розміщення кнопок фільтра під AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),

          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,

            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),

            child: Row(
              children: [
                _buildFilterButton(context, 'Всі предмети', true),

                _buildFilterButton(context, 'На обмін', false),

                _buildFilterButton(context, 'На продаж', false),

                _buildFilterButton(context, 'Рідкісні', false),
              ],
            ),
          ),
        ),
      ),

      body: GridView.builder(
        padding: const EdgeInsets.all(16.0),

        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,

          crossAxisSpacing: 12.0,

          mainAxisSpacing: 12.0,

          childAspectRatio: 0.7, // Адаптація під розмір карток на скріншоті
        ),

        itemCount: 4, // 4 hardcoded предмети

        itemBuilder: (context, index) {
          return _buildItemCard(context, index);
        },
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 40,

      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(12),
      ),

      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Пошук предметів...',

          hintStyle: TextStyle(color: Color(0xFF6C7B8F), fontSize: 14),

          prefixIcon: Icon(Icons.search, color: Color(0xFF6C7B8F)),

          border: InputBorder.none,

          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context,
    String text,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () {
          final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

          analytics.logEvent(
            name: 'button_click',
            parameters: {
              'button_id': 'submit_button',
              'screen_name': 'home_screen',
            },
          );

        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? const Color(0xFF00C6FF)
              : Theme.of(context).cardColor,
          foregroundColor: isSelected ? Colors.white : const Color(0xFFC7C7C7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 0,
        ),

        child: Text(text, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, int index) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Золота монета Liberty',
        'price': '85,000',
        'tag': 'Обмін',
        'user': 'Олександр К.',
        'image': 'assets/images/item_1.png',
      },

      {
        'title': 'Вінтажна марка 1960',
        'price': '15,000',
        'tag': 'Продаж',
        'user': 'Марія Л.',
        'image': 'assets/images/item_2.png',
      },

      {
        'title': 'Срібна монета 1921',
        'price': '12,000',
        'tag': 'Обмін',
        'user': 'Дмитро В.',
        'image': 'assets/images/item_3.png',
      },

      {
        'title': 'Антична римська монета',
        'price': '45,000',
        'tag': 'Продаж',
        'user': 'Іван П.',
        'image': 'assets/images/item_4.png',
      },
    ];

    final item = items[index];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),

                child: Image.asset(
                  item['image'],
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) =>
                      Container(height: 120, color: Colors.grey.shade800),
                ),
              ),

              Positioned(
                top: 8,

                left: 8,

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: item['tag'] == 'Обмін'
                        ? const Color(0xFFFF9900)
                        : const Color(0xFF00C6FF),

                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Text(
                    item['tag'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const Positioned(
                top: 8,

                right: 8,

                child: Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Color(0xFF6C7B8F),
                    ),

                    const SizedBox(width: 4),

                    Text(
                      item['user'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C7B8F),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  '₴${item['price']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF00C6FF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
