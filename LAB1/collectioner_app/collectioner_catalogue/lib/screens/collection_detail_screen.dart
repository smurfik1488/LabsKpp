import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trezo/models/collection_item.dart';
import 'package:trezo/screens/add_item_screen.dart';
import 'package:trezo/screens/item_detail_screen.dart';
import 'package:trezo/state/collection_items_provider.dart';

enum SortOption { newest, oldest, priceHigh, priceLow, name }

class CollectionDetailScreen extends StatefulWidget {
  final String title;
  final String subtitle;

  const CollectionDetailScreen({
    super.key,
    required this.title,
    this.subtitle = '',
  });

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  late final CollectionItemsProvider _provider;
  bool _isGrid = true;
  ItemStatus? _statusFilter;
  SortOption _sortOption = SortOption.newest;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provider = CollectionItemsProvider(widget.title)..loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _provider.dispose();
    super.dispose();
  }

  List<CollectionItem> _visibleItems(List<CollectionItem> source) {
    final query = _searchController.text.toLowerCase().trim();
    final filtered = source.where((item) {
      final matchesQuery = query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.year.toString().contains(query);
      final matchesStatus =
          _statusFilter == null || item.status == _statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();

    filtered.sort((a, b) {
      switch (_sortOption) {
        case SortOption.oldest:
          return a.year.compareTo(b.year);
        case SortOption.priceHigh:
          return b.price.compareTo(a.price);
        case SortOption.priceLow:
          return a.price.compareTo(b.price);
        case SortOption.name:
          return a.name.compareTo(b.name);
        case SortOption.newest:
        default:
          return b.year.compareTo(a.year);
      }
    });

    return filtered;
  }

  Future<void> _openAddItem() async {
    final newItem = await Navigator.of(context).push<CollectionItem>(
      MaterialPageRoute(builder: (context) => const AddItemScreen()),
    );

    if (newItem != null) {
      _provider.addItem(newItem);
    }
  }

  void _openSortSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Сортування', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _buildSortTile('Новіші', SortOption.newest),
              _buildSortTile('Старші', SortOption.oldest),
              _buildSortTile('Дорожчі', SortOption.priceHigh),
              _buildSortTile('Дешевші', SortOption.priceLow),
              _buildSortTile('Назва A→Я', SortOption.name),
            ],
          ),
        );
      },
    );
  }

  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Фільтр за статусом', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildFilterChip('Усі', null),
                  _buildFilterChip('Тільки в колекції', ItemStatus.collectionOnly),
                  _buildFilterChip('Пропоную на обмін', ItemStatus.exchange),
                  _buildFilterChip('Пропоную на продаж', ItemStatus.sale),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Застосувати'),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, ItemStatus? status) {
    final bool isSelected = _statusFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _statusFilter = status;
        });
      },
      selectedColor: const Color(0xFF00C6FF).withOpacity(0.15),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFFC7C7C7),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
      backgroundColor: const Color(0xFF11161C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? const Color(0xFF00C6FF) : const Color(0xFF1F2A33),
        ),
      ),
    );
  }

  Widget _buildSortTile(String label, SortOption option) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Radio<SortOption>(
        value: option,
        groupValue: _sortOption,
        activeColor: const Color(0xFF00C6FF),
        onChanged: (value) {
          if (value == null) return;
          setState(() => _sortOption = value);
          Navigator.of(context).pop();
        },
      ),
      onTap: () {
        setState(() => _sortOption = option);
        Navigator.of(context).pop();
      },
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

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF11161C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F2A33)),
      ),
      child: Row(
        children: [
          _toggleButton(
            icon: Icons.grid_view_rounded,
            isActive: _isGrid,
            onTap: () => setState(() => _isGrid = true),
          ),
          _toggleButton(
            icon: Icons.view_list_rounded,
            isActive: !_isGrid,
            onTap: () => setState(() => _isGrid = false),
          ),
        ],
      ),
    );
  }

  Widget _toggleButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00C6FF).withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : const Color(0xFF6C7B8F),
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<CollectionItemsProvider>(
        builder: (context, provider, _) {
          final items = _visibleItems(provider.items);
          final itemCountText = provider.status == LoadStatus.success
              ? '${items.length} предмет${items.length == 1 ? '' : 'ів'}'
              : 'Завантаження...';

          return Scaffold(
            appBar: AppBar(
              leading: const BackButton(),
              titleSpacing: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text(
                    itemCountText,
                    style: const TextStyle(color: Color(0xFF6C7B8F), fontSize: 12),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF11161C),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1F2A33)),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Пошук...',
                              hintStyle: const TextStyle(color: Color(0xFF6C7B8F)),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF6C7B8F)),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.close, color: Color(0xFF6C7B8F)),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: _openFilterSheet,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: const Color(0xFF11161C),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1F2A33)),
                          ),
                          child: const Icon(Icons.tune_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildViewToggle(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openSortSheet,
                          icon: const Icon(Icons.swap_vert, color: Colors.white),
                          label: const Text('Сортування', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF1F2A33)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_statusFilter != null) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => setState(() => _statusFilter = null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF11161C),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF00C6FF)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                  _statusFilter == ItemStatus.exchange
                                      ? Icons.compare_arrows
                                      : _statusFilter == ItemStatus.sale
                                          ? Icons.sell_outlined
                                          : Icons.collections_bookmark_outlined,
                                  size: 16,
                                  color: Colors.white),
                              const SizedBox(width: 6),
                              Text(
                                _statusFilter == ItemStatus.exchange
                                    ? 'Обмін'
                                    : _statusFilter == ItemStatus.sale
                                        ? 'Продаж'
                                        : 'Тільки в колекції',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.close, size: 16, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildBody(provider, items),
                  ),
                ],
              ),
            ),
            floatingActionButton: GestureDetector(
              onTap: _openAddItem,
              child: Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF00C6FF), Color(0xFF005FFF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x8000C6FF),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, size: 30, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(CollectionItemsProvider provider, List<CollectionItem> items) {
    if (provider.status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.status == LoadStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              provider.errorMessage ?? 'Сталася помилка',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6C7B8F)),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => provider.loadItems(),
              icon: const Icon(Icons.refresh),
              label: const Text('Спробувати ще раз'),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Text(
          'Немає предметів за вибраними фільтрами',
          style: TextStyle(color: Color(0xFF6C7B8F)),
        ),
      );
    }

    final content = _isGrid
        ? GridView.builder(
            key: const ValueKey('grid'),
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.62,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _ItemCard(
                item: item,
                formatPrice: _formatPrice,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ItemDetailScreen(item: item),
                  ),
                ),
              );
            },
          )
        : ListView.separated(
            key: const ValueKey('list'),
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return _ListTileItem(
                item: item,
                formatPrice: _formatPrice,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ItemDetailScreen(item: item),
                  ),
                ),
              );
            },
          );

    return RefreshIndicator(
      onRefresh: () => provider.loadItems(),
      child: content,
    );
  }
}

class _ItemCard extends StatelessWidget {
  final CollectionItem item;
  final String Function(int) formatPrice;
  final VoidCallback onTap;

  const _ItemCard({
    required this.item,
    required this.formatPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: AspectRatio(
                    aspectRatio: 1,
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
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.statusColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.statusLabel,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
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
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.year.toString(),
                    style: const TextStyle(color: Color(0xFF6C7B8F)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₴${formatPrice(item.price)}',
                    style: const TextStyle(
                      color: Color(0xFF00C6FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListTileItem extends StatelessWidget {
  final CollectionItem item;
  final String Function(int) formatPrice;
  final VoidCallback onTap;

  const _ListTileItem({
    required this.item,
    required this.formatPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
              child: Image.network(
                item.imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 110,
                  height: 110,
                  color: const Color(0xFF11161C),
                  child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF6C7B8F)),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: item.statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            item.statusLabel,
                            style: TextStyle(
                              color: item.statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF6C7B8F)),
                        const SizedBox(width: 6),
                        Text(item.year.toString(), style: const TextStyle(color: Color(0xFF6C7B8F))),
                        const SizedBox(width: 12),
                        const Icon(Icons.verified_outlined, size: 14, color: Color(0xFF6C7B8F)),
                        const SizedBox(width: 6),
                        Text(item.condition, style: const TextStyle(color: Color(0xFF6C7B8F))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₴${formatPrice(item.price)}',
                      style: const TextStyle(
                        color: Color(0xFF00C6FF),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
