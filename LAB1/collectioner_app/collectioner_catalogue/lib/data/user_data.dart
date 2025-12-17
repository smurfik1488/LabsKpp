// lib/data/user_data.dart

class UserData {
  static const String userName = 'Андрій Коваленко';
  static const String userHandle = '@andrii_kovalenko';
  static const String userBio =
      'Колекціонер із досвідом понад 10 років. Шукаю цікаві обміни та продажі!';
  static const String userLocation = 'Київ, Україна';
  static const String userRegistrationDate = '3 березня 2023';

  static const int collectionsCount = 4;
  static const int itemsCount = 222;
  static const int tradesCount = 12;

  static const List<Map<String, dynamic>> collections = [
    {
      'title': 'Антикварні монети',
      'type': 'Монети',
      'count': 47,
      'image':
          'https://images.unsplash.com/photo-1581921898576-6c9c4ff8e2b2?auto=format&fit=crop&w=400&q=80'
    },
    {
      'title': 'Світові марки',
      'type': 'Марки',
      'count': 132,
      'image':
          'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=400&q=80'
    },
    {
      'title': 'Рідкісні банкноти',
      'type': 'Банкноти',
      'count': 28,
      'image':
          'https://images.unsplash.com/photo-1526304640581-380d1990a112?auto=format&fit=crop&w=400&q=80'
    },
    {
      'title': 'Ювілейні монети',
      'type': 'Монети',
      'count': 15,
      'image':
          'https://images.unsplash.com/photo-1600267165505-5c6b4d92e7b1?auto=format&fit=crop&w=400&q=80'
    },
  ];
}
