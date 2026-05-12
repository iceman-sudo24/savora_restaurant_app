import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/app_exception.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

// ── Auth State ──

/// Represents the overall authentication state of the app.
/// The UI consumes this to decide which screen to show and
/// whether to display loading indicators.
sealed class AuthState {
  const AuthState();
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateAuthenticated extends AuthState {
  final UserModel user;
  const AuthStateAuthenticated(this.user);
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateError extends AuthState {
  final AppException exception;
  const AuthStateError(this.exception);
}

// ── Auth Notifier ──

/// Manages authentication state using Riverpod's [AsyncNotifier].
///
/// This notifier:
/// - Handles login, register, sign out operations
/// - Exposes the current [UserModel] when authenticated
/// - Preserves error state so the UI can display error messages
///
/// IMPORTANT: We use [AsyncNotifier] instead of plain [Notifier] because
/// auth operations are inherently async, and we want the UI to properly
/// handle loading states without memory leaks from manual setState calls.
class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    // On initialization, check if user is already signed in.
    final repo = ref.read(authRepositoryProvider);

    if (repo.isLoggedIn) {
      final uid = repo.currentFirebaseUser!.uid;
      final user = await repo.getUserDocument(uid);
      return user;
    }

    return null;
  }

  /// Sign in with email and password.
  /// Returns null on success, or the [AppException] on failure.
  ///
  /// IMPORTANT: We do NOT set state to AsyncLoading/AsyncError here.
  /// Doing so triggers the go_router provider to rebuild, which causes
  /// the router to re-evaluate redirects and bounce the user back to
  /// login/splash. The screens handle their own loading spinners.
  Future<AppException?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.signIn(email: email, password: password);
      state = AsyncData(user); // Only set state on SUCCESS
      return null;
    } on AppException catch (e) {
      return e; // Return error directly — don't touch state
    }
  }

  /// Register a new user with the given role.
  /// Returns null on success, or the [AppException] on failure.
  Future<AppException?> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final repo = ref.read(authRepositoryProvider);
      final user = await repo.register(
        name: name,
        email: email,
        password: password,
        role: role,
      );
      state = AsyncData(user); // Only set state on SUCCESS
      return null;
    } on AppException catch (e) {
      return e; // Return error directly — don't touch state
    }
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.signOut();
    state = const AsyncData(null);
  }

  /// Get the current user's role, or null if not authenticated.
  String? get currentRole => state.valueOrNull?.role;

  /// Whether the current user is an admin.
  bool get isAdmin => state.valueOrNull?.isAdmin ?? false;

  /// Whether the current user is a customer.
  bool get isCustomer => state.valueOrNull?.isCustomer ?? false;
}

/// Global auth state provider.
/// The UI watches this to reactively update based on auth state.
final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);

// ── Derived Providers ──

/// Whether the user is currently authenticated.
/// Useful for route guards and conditional UI.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.valueOrNull != null;
});

/// The current user's role, or null if not authenticated.
final userRoleProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.valueOrNull?.role;
});

/// Whether the current user is an admin.
final isAdminProvider = Provider<bool>((ref) {
  return ref.watch(userRoleProvider) == 'admin';
});