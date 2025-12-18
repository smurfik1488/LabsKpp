import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageUploadResult {
  final String downloadUrl;
  final String path;

  const StorageUploadResult({
    required this.downloadUrl,
    required this.path,
  });
}

abstract class StorageRepository {
  Future<StorageUploadResult> uploadCollectionImage({
    required String collectionId,
    required Uint8List bytes,
    String contentType,
  });

  Future<StorageUploadResult> uploadCollectionItemImage({
    required String collectionId,
    required String itemId,
    required Uint8List bytes,
    String contentType,
  });

  Future<void> deleteImage(String path);
}

class FirebaseStorageRepository implements StorageRepository {
  FirebaseStorageRepository({
    required FirebaseStorage storage,
    required FirebaseAuth auth,
  })  : _storage = storage,
        _auth = auth;

  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  String _itemImagePath(String collectionId, String itemId) {
    return 'collection_items/$collectionId/$itemId.jpg';
  }

  String _collectionImagePath(String collectionId) {
    return 'collection_covers/$collectionId/cover.jpg';
  }

  @override
  Future<StorageUploadResult> uploadCollectionImage({
    required String collectionId,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to upload images.');
    }

    final path = _collectionImagePath(collectionId);
    final ref = _storage.ref(path);
    final metadata = SettableMetadata(contentType: contentType);

    await ref.putData(bytes, metadata);
    final url = await ref.getDownloadURL();
    return StorageUploadResult(downloadUrl: url, path: path);
  }

  @override
  Future<StorageUploadResult> uploadCollectionItemImage({
    required String collectionId,
    required String itemId,
    required Uint8List bytes,
    String contentType = 'image/jpeg',
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to upload images.');
    }

    final path = _itemImagePath(collectionId, itemId);
    final ref = _storage.ref(path);
    final metadata = SettableMetadata(contentType: contentType);

    await ref.putData(bytes, metadata);
    final url = await ref.getDownloadURL();
    return StorageUploadResult(downloadUrl: url, path: path);
  }

  @override
  Future<void> deleteImage(String path) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to delete images.');
    }

    await _storage.ref(path).delete();
  }
}
