import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'routing/app_router.dart';

/// Root application widget.
///
/// Uses Riverpod's [ConsumerWidget] to:
/// - Watch [appRouterProvider] for the go_router instance
/// - Apply the Navy/Gold theme
///
/// This is separated from main.dart for cleanliness — main.dart only
/// handles Firebase initialization and ProviderScope setup.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Savora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}