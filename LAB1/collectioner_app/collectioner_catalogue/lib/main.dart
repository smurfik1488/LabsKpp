import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:trezo/theme/app_theme.dart';
import 'package:trezo/screens/auth/welcome_screen.dart';
import 'firebase_options.dart'; // створюється після flutterfire configure
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, //з firebase_options.dart
  );
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const CollectionerCatalogueApp());
}

class CollectionerCatalogueApp extends StatelessWidget {
  const CollectionerCatalogueApp({super.key});

  //аналітика і observer
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Collectioner Catalogue',
      theme: collectionerDarkTheme,
      navigatorObservers: [observer], // 🔹 відстеження переходів між екранами
      home: const WelcomeScreen(),
    );
  }
}
