import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trezo/repositories/collection_items_repository.dart';
import 'package:trezo/repositories/collections_repository.dart';
import 'package:trezo/repositories/storage_repository.dart';
import 'package:trezo/screens/auth/welcome_screen.dart';
import 'package:trezo/theme/app_theme.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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

  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<CollectionsRepository>(
          create: (_) => FirestoreCollectionsRepository(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
          ),
        ),
        Provider<CollectionItemsRepository>(
          create: (_) => FirestoreCollectionItemsRepository(
            firestore: FirebaseFirestore.instance,
            auth: FirebaseAuth.instance,
          ),
        ),
        Provider<StorageRepository>(
          create: (_) => FirebaseStorageRepository(
            storage: FirebaseStorage.instance,
            auth: FirebaseAuth.instance,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Collectioner Catalogue',
        theme: collectionerDarkTheme,
        navigatorObservers: [observer],
        home: const WelcomeScreen(),
      ),
    );
  }
}
