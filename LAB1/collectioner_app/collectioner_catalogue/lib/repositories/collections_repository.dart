import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trezo/models/user_collection.dart';

abstract class CollectionsRepository {
  Stream<List<UserCollection>> watchCollections();
  Future<List<UserCollection>> getCollections();
  Future<UserCollection> addCollection(UserCollection collection);
  Future<void> updateCollection(UserCollection collection);
  Future<void> deleteCollection(String collectionId);
}

class FirestoreCollectionsRepository implements CollectionsRepository {
  FirestoreCollectionsRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _collectionsRef =>
      _firestore.collection('collections');

  @override
  Stream<List<UserCollection>> watchCollections() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _collectionsRef
        .where('ownerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
          final items =
              snapshot.docs.map(UserCollection.fromFirestore).toList();
          items.sort(
            (a, b) =>
                (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
                    .compareTo(
                        a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
          );
          return items;
        });
  }

  @override
  Future<List<UserCollection>> getCollections() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to get collections.');
    }

    final snapshot =
        await _collectionsRef.where('ownerId', isEqualTo: user.uid).get();
    final items = snapshot.docs.map(UserCollection.fromFirestore).toList();
    items.sort(
      (a, b) =>
          (b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0))
              .compareTo(
                  a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0)),
    );
    return items;
  }

  @override
  Future<UserCollection> addCollection(UserCollection collection) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to add collections.');
    }

    final docRef = _collectionsRef.doc();
    final data = collection.toMap(ownerId: user.uid);
    data['createdAt'] = FieldValue.serverTimestamp();
    data['updatedAt'] = FieldValue.serverTimestamp();

    await docRef.set(data);
    final snapshot = await docRef.get();
    return UserCollection.fromFirestore(snapshot);
  }

  @override
  Future<void> updateCollection(UserCollection collection) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to update collections.');
    }

    final docRef = _collectionsRef.doc(collection.id);
    final data = collection.toMap();
    data['updatedAt'] = FieldValue.serverTimestamp();
    await docRef.update(data);
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User must be signed in to delete collections.');
    }

    await _collectionsRef.doc(collectionId).delete();
  }
}
