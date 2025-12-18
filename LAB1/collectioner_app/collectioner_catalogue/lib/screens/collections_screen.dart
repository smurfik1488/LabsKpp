import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trezo/models/user_collection.dart';
import 'package:trezo/repositories/collections_repository.dart';
import 'package:trezo/screens/add_collection_screen.dart';
import 'package:trezo/screens/collection_detail_screen.dart';
import 'package:trezo/state/collections_provider.dart';
import 'package:trezo/state/load_status.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  late final CollectionsProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = CollectionsProvider(
      repository: context.read<CollectionsRepository>(),
    )..loadCollections();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<void> _openCreateCollection() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _provider,
          child: const AddCollectionScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<CollectionsProvider>(
        builder: (context, provider, _) {
          final isLoading = provider.status == LoadStatus.loading;
          final hasError = provider.status == LoadStatus.error;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Collections'),
              actions: [
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Failed to load collections.'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => provider.loadCollections(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final collections = provider.collections;
                  return ListView.builder(
                    itemCount: collections.length + 1,
                    itemBuilder: (context, index) {
                      if (index < collections.length) {
                        final collection = collections[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildCollectionCard(context, collection),
                        );
                      }
                      return _buildCreateNewCollectionCard(context);
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollectionCard(BuildContext context, UserCollection collection) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CollectionDetailScreen(collection: collection),
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
                collection.imageUrl,
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
                    collection.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    collection.type,
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
                '${collection.itemsCount} items',
                style: const TextStyle(color: Color(0xFF00C6FF), fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateNewCollectionCard(BuildContext context) {
    return GestureDetector(
      onTap: _openCreateCollection,
      child: Container(
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
            Text('Create new collection', style: TextStyle(color: Color(0xFFC7C7C7))),
          ],
        ),
      ),
    );
  }
}
