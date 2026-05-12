import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

/// App entry point.
///
/// Initialization order:
/// 1. Flutter bindings (required before any plugin usage)
/// 2. Firebase initialization (required before any Firebase service)
/// 3. Riverpod ProviderScope (wraps entire app for state management)
/// 4. App widget (MaterialApp.router with theme + routing)
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}