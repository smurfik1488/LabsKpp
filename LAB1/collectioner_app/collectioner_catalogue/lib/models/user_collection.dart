import 'package:cloud_firestore/cloud_firestore.dart';

class UserCollection {
  final String id;
  final String title;
  final String type;
  final String imageUrl;
  final String? imagePath;
  final int itemsCount;
  final String? ownerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserCollection({
    required this.id,
    required this.title,
    required this.type,
    required this.imageUrl,
    this.imagePath,
    required this.itemsCount,
    this.ownerId,
    this.createdAt,
    this.updatedAt,
  });

  UserCollection copyWith({
    String? id,
    String? title,
    String? type,
    String? imageUrl,
    String? imagePath,
    int? itemsCount,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserCollection(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      itemsCount: itemsCount ?? this.itemsCount,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap({String? ownerId, String? imagePath}) {
    final resolvedOwnerId = ownerId ?? this.ownerId;
    final resolvedImagePath = imagePath ?? this.imagePath;

    return {
      'title': title,
      'type': type,
      'imageUrl': imageUrl,
      if (resolvedImagePath != null) 'imagePath': resolvedImagePath,
      'itemsCount': itemsCount,
      if (resolvedOwnerId != null) 'ownerId': resolvedOwnerId,
    };
  }

  static UserCollection fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAt = data['createdAt'];
    final updatedAt = data['updatedAt'];

    return UserCollection(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      type: (data['type'] as String?) ?? '',
      imageUrl: (data['imageUrl'] as String?) ?? '',
      imagePath: data['imagePath'] as String?,
      itemsCount: (data['itemsCount'] as num?)?.toInt() ?? 0,
      ownerId: data['ownerId'] as String?,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
    );
  }
}
