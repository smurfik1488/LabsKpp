// lib/screens/overview_screen.dart
import 'package:flutter/material.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _demoItems;

    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(context),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip(context, 'Trending', true),
                _buildFilterChip(context, 'Exchange', false),
                _buildFilterChip(context, 'For sale', false),
                _buildFilterChip(context, 'New', false),
              ],
            ),
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) => _ItemCard(item: items[index]),
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
          hintText: 'Search...',
          hintStyle: TextStyle(color: Color(0xFF6C7B8F), fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Color(0xFF6C7B8F)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String text, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected ? const Color(0xFF00C6FF) : Theme.of(context).cardColor,
          foregroundColor: selected ? Colors.white : const Color(0xFFC7C7C7),
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
}

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final Map<String, String> item;

  Color _tagColor(String tag) {
    switch (tag) {
      case 'Exchange':
        return const Color(0xFFFF9900);
      case 'For sale':
        return const Color(0xFF00C853);
      default:
        return const Color(0xFF00C6FF);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  item['image'] ?? '',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _tagColor(item['tag'] ?? ''),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['tag'] ?? '',
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
                child: Icon(Icons.favorite_border,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        size: 14, color: Color(0xFF6C7B8F)),
                    const SizedBox(width: 4),
                    Text(
                      item['user'] ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C7B8F),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${item['price']}',
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

const List<Map<String, String>> _demoItems = [
  {
    'title': 'Liberty collection coin',
    'price': '85,000',
    'tag': 'Exchange',
    'user': 'Max T.',
    'image':
        'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?auto=format&fit=crop&w=800&q=80',
  },
  {
    'title': 'Vintage banknote 1960',
    'price': '15,000',
    'tag': 'For sale',
    'user': 'Anna P.',
    'image':
        'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?auto=format&fit=crop&w=800&q=80',
  },
  {
    'title': 'Rare coin 1921',
    'price': '12,000',
    'tag': 'Exchange',
    'user': 'John S.',
    'image':
        'https://images.unsplash.com/photo-1512428559087-560fa5ceab42?auto=format&fit=crop&w=800&q=80',
  },
  {
    'title': 'Collector’s note set',
    'price': '45,000',
    'tag': 'For sale',
    'user': 'Eva L.',
    'image':
        'https://images.unsplash.com/photo-1462396881884-de2c07cb95ed?auto=format&fit=crop&w=800&q=80',
  },
];
