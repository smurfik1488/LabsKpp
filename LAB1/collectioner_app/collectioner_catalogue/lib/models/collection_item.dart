import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ItemStatus { collectionOnly, exchange, sale }

class CollectionItem {
  final String id;
  final String name;
  final int year;
  final int price;
  final ItemStatus status;
  final String condition;
  final String imageUrl;
  final String description;
  final String? ownerId;
  final String? collectionId;
  final String? imagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CollectionItem({
    required this.id,
    required this.name,
    required this.year,
    required this.price,
    required this.status,
    required this.condition,
    required this.imageUrl,
    required this.description,
    this.ownerId,
    this.collectionId,
    this.imagePath,
    this.createdAt,
    this.updatedAt,
  });

  String get statusLabel {
    switch (status) {
      case ItemStatus.exchange:
        return 'Обмін';
      case ItemStatus.sale:
        return 'Продаж';
      case ItemStatus.collectionOnly:
      default:
        return 'Тільки в колекції';
    }
  }

  Color get statusColor {
    switch (status) {
      case ItemStatus.exchange:
        return const Color(0xFFFF9900);
      case ItemStatus.sale:
        return const Color(0xFF00C853);
      case ItemStatus.collectionOnly:
      default:
        return const Color(0xFF00C6FF);
    }
  }

  CollectionItem copyWith({
    String? id,
    String? name,
    int? year,
    int? price,
    ItemStatus? status,
    String? condition,
    String? imageUrl,
    String? description,
    String? ownerId,
    String? collectionId,
    String? imagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CollectionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      year: year ?? this.year,
      price: price ?? this.price,
      status: status ?? this.status,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      collectionId: collectionId ?? this.collectionId,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap({
    String? ownerId,
    String? collectionId,
    String? imagePath,
  }) {
    final resolvedOwnerId = ownerId ?? this.ownerId;
    final resolvedCollectionId = collectionId ?? this.collectionId;
    final resolvedImagePath = imagePath ?? this.imagePath;

    return {
      'name': name,
      'year': year,
      'price': price,
      'status': status.name,
      'condition': condition,
      'imageUrl': imageUrl,
      'description': description,
      if (resolvedOwnerId != null) 'ownerId': resolvedOwnerId,
      if (resolvedCollectionId != null) 'collectionId': resolvedCollectionId,
      if (resolvedImagePath != null) 'imagePath': resolvedImagePath,
    };
  }

  static CollectionItem fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    String? collectionId,
  }) {
    final data = doc.data() ?? <String, dynamic>{};
    final statusValue = data['status'];
    ItemStatus status = ItemStatus.collectionOnly;
    if (statusValue is String) {
      status = ItemStatus.values.firstWhere(
        (value) => value.name == statusValue,
        orElse: () => ItemStatus.collectionOnly,
      );
    }

    final createdAt = data['createdAt'];
    final updatedAt = data['updatedAt'];

    return CollectionItem(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      year: (data['year'] as num?)?.toInt() ?? 0,
      price: (data['price'] as num?)?.toInt() ?? 0,
      status: status,
      condition: (data['condition'] as String?) ?? '',
      imageUrl: (data['imageUrl'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      ownerId: data['ownerId'] as String?,
      collectionId: collectionId ?? data['collectionId'] as String?,
      imagePath: data['imagePath'] as String?,
      createdAt: createdAt is Timestamp ? createdAt.toDate() : null,
      updatedAt: updatedAt is Timestamp ? updatedAt.toDate() : null,
    );
  }
}
