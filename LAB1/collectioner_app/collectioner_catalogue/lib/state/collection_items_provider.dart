import 'package:flutter/foundation.dart';
import 'package:trezo/data/sample_items.dart';
import 'package:trezo/models/collection_item.dart';

enum LoadStatus { idle, loading, success, error }

class CollectionItemsProvider extends ChangeNotifier {
  final String collectionTitle;
  LoadStatus status = LoadStatus.idle;
  String? errorMessage;
  List<CollectionItem> _items = [];

  CollectionItemsProvider(this.collectionTitle);

  List<CollectionItem> get items => List.unmodifiable(_items);

  void addItem(CollectionItem item) {
    _items = [..._items, item];
    notifyListeners();
  }

  Future<void> loadItems({bool simulateError = true}) async {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 450));
      if (simulateError) {
        throw Exception('Симульована помилка завантаження');
      }
      _items = cloneCollectionItems(collectionTitle);
      status = LoadStatus.success;
    } catch (e) {
      status = LoadStatus.error;
      errorMessage = 'Не вдалося завантажити предмети. Спробуйте ще раз.';
    } finally {
      notifyListeners();
    }
  }
}
