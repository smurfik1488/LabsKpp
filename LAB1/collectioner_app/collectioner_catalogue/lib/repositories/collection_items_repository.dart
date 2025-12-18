import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trezo/models/collection_item.dart';

abstract class CollectionItemsRepository {
  Stream<List<CollectionItem>> watchItems(String collectionId);
  Future<List<CollectionItem>> getItems(String collectionId);
  Future<CollectionItem> addItem(String collectionId, CollectionItem item);
  Future<void> updateItem(String collectionId, CollectionItem item);
  Future<void> deleteItem(String collectionId, String itemId);
}

class FirestoreCollectionItemsRepository implements CollectionItemsRepository {
  FirestoreCollectionItemsRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _itemsRef(String collectionId) {
    return _firestore.collection('collections').doc(collectionId).collection('items');
  }

  DocumentReference<Map<String, dynamic>> _collectionRef(String collectionId) {
    return _firestore.collection('collections').doc(collectionId);
  }

  @override
  Stream<List<CollectionItem>> watchItems(String collectionId) {
    return _itemsRef(collectionId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CollectionItem.fromFirestore(doc, collectionId: collectionId))
            .toList());
  }

  @override
  Future<List<CollectionItem>> getItems(String collectionId) async {
    final snapshot = await _itemsRef(collectionId).orderBy('createdAt', descending: true).get();
    return snapshot.docs
        .map((doc) => CollectionItem.fromFirestore(doc, collectionId: collectionId))
        .toList();
  }

  @override
  Future<CollectionItem> addItem(String collectionId, CollectionItem item) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to add items.');
    }

    final docRef = _itemsRef(collectionId).doc();
    final data = item.toMap(
      ownerId: user.uid,
      collectionId: collectionId,
      imagePath: item.imagePath,
    );
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.runTransaction((transaction) async {
      transaction.set(docRef, data);
      transaction.set(
        _collectionRef(collectionId),
        {
          'itemsCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });

    final snapshot = await docRef.get();
    return CollectionItem.fromFirestore(snapshot, collectionId: collectionId);
  }

  @override
  Future<void> updateItem(String collectionId, CollectionItem item) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to update items.');
    }

    final docRef = _itemsRef(collectionId).doc(item.id);
    final data = item.toMap(imagePath: item.imagePath);
    data['updatedAt'] = FieldValue.serverTimestamp();

    await docRef.update(data);
  }

  @override
  Future<void> deleteItem(String collectionId, String itemId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to delete items.');
    }

    final itemRef = _itemsRef(collectionId).doc(itemId);
    await _firestore.runTransaction((transaction) async {
      transaction.delete(itemRef);
      transaction.set(
        _collectionRef(collectionId),
        {
          'itemsCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }
}
