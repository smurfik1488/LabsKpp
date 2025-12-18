import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trezo/models/collection_item.dart';
import 'package:trezo/screens/add_item_screen.dart';
import 'package:trezo/state/collection_items_provider.dart';
import 'package:trezo/state/mutation_status.dart';

class ItemDetailScreen extends StatelessWidget {
  final CollectionItem item;

  const ItemDetailScreen({super.key, required this.item});

  Future<void> _openEdit(BuildContext context) async {
    final provider = context.read<CollectionItemsProvider>();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: AddItemScreen(initialItem: item),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final provider = context.read<CollectionItemsProvider>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;
    await provider.deleteItem(item.id);

    if (!context.mounted) return;
    if (provider.mutationStatus == MutationStatus.error) {
      final message = provider.mutationError ?? 'Failed to delete item.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    provider.resetMutationStatus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(item.name, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _openEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFF11161C),
                        child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF6C7B8F)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: item.statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.statusLabel,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Row(
              children: [
                _infoPill(Icons.calendar_today_outlined, item.year.toString()),
                const SizedBox(width: 8),
                _infoPill(Icons.verified_outlined, item.condition),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '₴${_formatPrice(item.price)}',
              style: const TextStyle(
                color: Color(0xFF00C6FF),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Опис', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: const TextStyle(color: Color(0xFFC7C7C7), height: 1.5),
            ),
            const SizedBox(height: 20),
            _buildActionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF11161C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1F2A33)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Статус предмета', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                item.status == ItemStatus.exchange
                    ? Icons.compare_arrows
                    : item.status == ItemStatus.sale
                        ? Icons.sell_outlined
                        : Icons.collections_bookmark_outlined,
                color: item.statusColor,
              ),
              const SizedBox(width: 8),
              Text(item.statusLabel, style: TextStyle(color: item.statusColor, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Фільтрування та сортування працюють так само, як і в списку — можна швидко змінити статус і знайти предмет.',
            style: TextStyle(color: Color(0xFF6C7B8F)),
          ),
        ],
      ),
    );
  }

  Widget _infoPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF11161C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF1F2A33)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF6C7B8F)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  String _formatPrice(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[digits.length - 1 - i]);
      if ((i + 1) % 3 == 0 && i + 1 != digits.length) {
        buffer.write(' ');
      }
    }
    return buffer.toString().split('').reversed.join();
  }
}
