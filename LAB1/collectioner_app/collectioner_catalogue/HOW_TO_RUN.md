# Як запустити проєкт

## Варіант 1: Через IDE (Рекомендовано)

### VS Code:
1. Відкрийте проєкт у VS Code
2. Натисніть `F5` або кнопку "Run" у верхньому меню
3. Або використайте Command Palette (`Ctrl+Shift+P`) → "Flutter: Run"

### Android Studio:
1. Відкрийте проєкт у Android Studio
2. Натисніть кнопку "Run" (зелена стрілка) або `Shift+F10`
3. Оберіть пристрій (емулятор або фізичний пристрій)

## Варіант 2: Через термінал

### Якщо Flutter встановлений:

1. Відкрийте термінал у папці проєкту:
   ```
   cd C:\Users\PC\Desktop\KP\LAB1\collectioner_app\collectioner_catalogue
   ```

2. Встановіть залежності:
   ```bash
   flutter pub get
   ```

3. Перевірте доступні пристрої:
   ```bash
   flutter devices
   ```

4. Запустіть додаток:
   ```bash
   flutter run
   ```

   Або для конкретного пристрою:
   ```bash
   flutter run -d <device-id>
   ```

### Якщо Flutter не встановлений:

1. Завантажте Flutter з [офіційного сайту](https://flutter.dev/docs/get-started/install/windows)
2. Розпакуйте в папку (наприклад, `C:\src\flutter`)
3. Додайте Flutter до PATH:
   - Відкрийте "Змінні середовища" (Environment Variables)
   - Додайте `C:\src\flutter\bin` до змінної PATH
4. Перезапустіть термінал
5. Перевірте встановлення:
   ```bash
   flutter doctor
   ```
6. Виконайте команди з варіанту 2 вище

## Варіант 3: Через Android Studio (для Android)

1. Відкрийте проєкт у Android Studio
2. Створіть емулятор або підключіть фізичний пристрій
3. Натисніть "Run" або `Shift+F10`

## Перед запуском переконайтеся:

1. ✅ Встановлено Flutter SDK
2. ✅ Налаштовано Firebase (див. `FIREBASE_SETUP_INSTRUCTIONS.md`)
3. ✅ Встановлено залежності (`flutter pub get`)
4. ✅ Підключено пристрій або запущено емулятор

## Типові проблеми:

### Помилка: "Flutter not found"
- Додайте Flutter до PATH або використайте IDE

### Помилка: "No devices found"
- Запустіть емулятор або підключіть пристрій
- Перевірте: `flutter devices`

### Помилка: "Firebase not initialized"
- Налаштуйте Firebase (див. `FIREBASE_SETUP_INSTRUCTIONS.md`)

### Помилка: "MissingPluginException"
- Виконайте:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

## Швидкий старт:

Якщо у вас вже налаштовано все:

```bash
cd C:\Users\PC\Desktop\KP\LAB1\collectioner_app\collectioner_catalogue
flutter pub get
flutter run
```

---

**Примітка**: Якщо ви використовуєте IDE (VS Code або Android Studio), найпростіше запустити проєкт через інтерфейс IDE.

