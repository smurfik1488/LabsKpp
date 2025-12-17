// lib/screens/collections_screen.dart

import 'package:flutter/material.dart';
import 'package:trezo/data/user_data.dart'; // hardcoded дані користувача
import 'package:trezo/screens/collection_detail_screen.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Колекції'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: UserData.collections.length + 1,
        itemBuilder: (context, index) {
          if (index < UserData.collections.length) {
            final collection = UserData.collections[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildCollectionCard(context, collection),
            );
          } else {
            return _buildCreateNewCollectionCard(context);
          }
        },
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, Map<String, dynamic> collection) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CollectionDetailScreen(
              title: collection['title'] as String,
              subtitle: collection['type'] as String,
            ),
          ),
        );
      },
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                collection['image'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) =>
                    Container(width: 80, height: 80, color: Colors.grey.shade800),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    collection['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    collection['type'],
                    style: const TextStyle(color: Color(0xFFC7C7C7)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF00C6FF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${collection['count']} предметів',
                style: const TextStyle(color: Color(0xFF00C6FF), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateNewCollectionCard(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, size: 30, color: Color(0xFFC7C7C7)),
          SizedBox(height: 4),
          Text('Створити нову колекцію', style: TextStyle(color: Color(0xFFC7C7C7))),
        ],
      ),
    );
  }
}
