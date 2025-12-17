import 'package:flutter/material.dart';

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

  const CollectionItem({
    required this.id,
    required this.name,
    required this.year,
    required this.price,
    required this.status,
    required this.condition,
    required this.imageUrl,
    required this.description,
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
}
