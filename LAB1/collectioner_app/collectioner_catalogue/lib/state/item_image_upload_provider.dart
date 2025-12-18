import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:trezo/repositories/storage_repository.dart';

enum UploadStatus { idle, uploading, success, error }

class ItemImageUploadProvider extends ChangeNotifier {
  ItemImageUploadProvider({required StorageRepository repository})
      : _repository = repository;

  final StorageRepository _repository;
  UploadStatus status = UploadStatus.idle;
  String? errorMessage;
  StorageUploadResult? lastResult;

  Future<StorageUploadResult?> uploadItemImage({
    required String collectionId,
    required String itemId,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    status = UploadStatus.uploading;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.uploadCollectionItemImage(
        collectionId: collectionId,
        itemId: itemId,
        bytes: bytes,
        contentType: contentType,
      );
      lastResult = result;
      status = UploadStatus.success;
      return result;
    } catch (e) {
      status = UploadStatus.error;
      errorMessage = 'Failed to upload image.';
      return null;
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteImage(String path) async {
    await _repository.deleteImage(path);
  }

  void reset() {
    status = UploadStatus.idle;
    errorMessage = null;
    lastResult = null;
    notifyListeners();
  }
}
