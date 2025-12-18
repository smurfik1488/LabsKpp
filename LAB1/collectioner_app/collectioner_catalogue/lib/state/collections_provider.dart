import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:trezo/models/user_collection.dart';
import 'package:trezo/repositories/collections_repository.dart';
import 'package:trezo/state/load_status.dart';
import 'package:trezo/state/mutation_status.dart';

class CollectionsProvider extends ChangeNotifier {
  CollectionsProvider({required CollectionsRepository repository})
      : _repository = repository;

  final CollectionsRepository _repository;
  LoadStatus status = LoadStatus.idle;
  MutationStatus mutationStatus = MutationStatus.idle;
  String? errorMessage;
  String? mutationError;
  List<UserCollection> _collections = [];
  StreamSubscription<List<UserCollection>>? _subscription;

  List<UserCollection> get collections => List.unmodifiable(_collections);

  void loadCollections() {
    status = LoadStatus.loading;
    errorMessage = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _repository.watchCollections().listen(
      (collections) {
        _collections = collections;
        status = LoadStatus.success;
        notifyListeners();
      },
      onError: (error) {
        status = LoadStatus.error;
        errorMessage = 'Failed to load collections.';
        notifyListeners();
      },
    );
  }

  Future<UserCollection?> createCollection(UserCollection collection) async {
    mutationStatus = MutationStatus.saving;
    mutationError = null;
    notifyListeners();

    try {
      final created = await _repository.addCollection(collection);
      mutationStatus = MutationStatus.success;
      return created;
    } catch (e) {
      mutationStatus = MutationStatus.error;
      mutationError = 'Failed to create collection.';
      return null;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateCollection(UserCollection collection) async {
    mutationStatus = MutationStatus.saving;
    mutationError = null;
    notifyListeners();

    try {
      await _repository.updateCollection(collection);
      mutationStatus = MutationStatus.success;
    } catch (e) {
      mutationStatus = MutationStatus.error;
      mutationError = 'Failed to update collection.';
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteCollection(String collectionId) async {
    mutationStatus = MutationStatus.saving;
    mutationError = null;
    notifyListeners();

    try {
      await _repository.deleteCollection(collectionId);
      mutationStatus = MutationStatus.success;
    } catch (e) {
      mutationStatus = MutationStatus.error;
      mutationError = 'Failed to delete collection.';
    } finally {
      notifyListeners();
    }
  }

  void resetMutationStatus() {
    mutationStatus = MutationStatus.idle;
    mutationError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
