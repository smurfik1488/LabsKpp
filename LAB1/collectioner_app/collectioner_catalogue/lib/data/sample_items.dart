import 'package:trezo/models/collection_item.dart';

final Map<String, List<CollectionItem>> sampleCollections = {
  'Антикварні монети': [
    const CollectionItem(
      id: 'liberty-1904',
      name: 'Золота монета Liberty',
      year: 1904,
      price: 85000,
      status: ItemStatus.exchange,
      condition: 'Відмінний',
      imageUrl: 'https://images.unsplash.com/photo-1567427018141-0584cfcbf1b4?auto=format&fit=crop&w=800&q=80',
      description: 'Рідкісна золота монета Liberty у чудовому стані. Зберігається у капсулі, підходить для обміну та інвестицій.',
    ),
    const CollectionItem(
      id: 'morgan-1921',
      name: 'Срібний долар Morgan 1921',
      year: 1921,
      price: 12000,
      status: ItemStatus.sale,
      condition: 'Добрий',
      imageUrl: 'https://images.unsplash.com/photo-1614103235694-82f0c36c5c54?auto=format&fit=crop&w=800&q=80',
      description: 'Оригінальний срібний долар 1921 року. Є сліди часу, але рельєф збережений. Готовий до продажу.',
    ),
    const CollectionItem(
      id: 'roman-coin',
      name: 'Римська монета',
      year: 161,
      price: 45000,
      status: ItemStatus.sale,
      condition: 'Задовільний',
      imageUrl: 'https://images.unsplash.com/photo-1582234372722-50d94b1d4483?auto=format&fit=crop&w=800&q=80',
      description: 'Монета часів Римської імперії. Має патину та незначні потертості. Цінний історичний артефакт.',
    ),
    const CollectionItem(
      id: 'uah-1918',
      name: 'Українська гривня 1918',
      year: 1918,
      price: 28000,
      status: ItemStatus.exchange,
      condition: 'Добрий',
      imageUrl: 'https://images.unsplash.com/photo-1526304640581-d334cdbbf45e?auto=format&fit=crop&w=800&q=80',
      description: 'Рідкісна гривня УНР 1918 року. Добре збереглися написи та герб. Цікавить обмін на монети XIX ст.',
    ),
  ],
};

List<CollectionItem> cloneCollectionItems(String title) {
  final items = sampleCollections[title] ?? sampleCollections.values.first;
  return List<CollectionItem>.from(items);
}
