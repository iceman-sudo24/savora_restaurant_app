import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/user_model.dart';

/// Repository handling all authentication and user document operations.
///
/// Responsibilities:
/// - Firebase Auth operations (sign in, register, sign out)
/// - Firestore user document CRUD
/// - Secure storage of auth tokens/role for quick startup checks
///
/// Error handling strategy:
/// All Firebase exceptions are caught and re-thrown as [AppException]
/// with user-friendly messages. The UI layer never sees raw Firebase errors.
class AuthRepository {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FlutterSecureStorage? secureStorage,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  // ── Collection Reference ──
  CollectionReference get _usersRef =>
      _firestore.collection(AppConstants.usersCollection);

  // ── Current Auth State ──

  /// Current Firebase Auth user (null if not signed in).
  fb.User? get currentFirebaseUser => _auth.currentUser;

  /// Stream of auth state changes. Emits null on sign out.
  Stream<fb.User?> get authStateChanges => _auth.authStateChanges();

  /// Whether a user is currently signed in.
  bool get isLoggedIn => _auth.currentUser != null;

  // ── Sign In ──

  /// Authenticates user with email/password, then fetches their Firestore
  /// user document to get the role.
  ///
  /// Returns the [UserModel] on success.
  /// Throws [AppException] on failure.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw AppException.invalidCredentials();
      }

      final userModel = await getUserDocument(credential.user!.uid);
      if (userModel == null) {
        throw AppException.documentNotFound(AppConstants.usersCollection);
      }

      // Cache for quick startup
      await _cacheUserCredentials(userModel);

      return userModel;
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.unknown(e);
    }
  }

  // ── Register ──

  /// Creates a new Firebase Auth user + Firestore user document.
  ///
  /// The [role] parameter must be either 'customer' or 'admin'.
  /// Returns the created [UserModel].
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      // Create Firebase Auth account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw AppException.unknown('Registration failed: no user returned.');
      }

      // Update display name
      await credential.user!.updateDisplayName(name.trim());

      // Create Firestore user document
      final userModel = UserModel(
        uid: credential.user!.uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
        createdAt: DateTime.now(),
      );

      await _usersRef.doc(userModel.uid).set(userModel.toJson());

      // Cache for quick startup
      await _cacheUserCredentials(userModel);

      return userModel;
    } on fb.FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException.unknown(e);
    }
  }

  // ── Sign Out ──

  /// Signs out the current user and clears cached credentials.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _clearCachedCredentials();
    } catch (e) {
      throw AppException.unknown(e);
    }
  }

  // ── User Document Operations ──

  /// Fetches the user document from Firestore.
  /// Returns null if the document doesn't exist.
  Future<UserModel?> getUserDocument(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw _mapFirestoreError(e);
    } catch (e) {
      throw AppException.unknown(e);
    }
  }

  /// Streams real-time updates of the current user's document.
  /// Useful for detecting role changes or profile updates.
  Stream<UserModel?> watchUserDocument(String uid) {
    return _usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// Updates specific fields on the user document.
  Future<void> updateUserDocument(String uid, Map<String, dynamic> data) async {
    try {
      await _usersRef.doc(uid).update(data);
    } on FirebaseException catch (e) {
      throw _mapFirestoreError(e);
    } catch (e) {
      throw AppException.unknown(e);
    }
  }

  // ── Secure Storage (Cached Credentials) ──

  /// Caches uid and role in secure storage for faster app startup.
  /// This lets the router make an instant decision on which screen to show
  /// without waiting for a Firestore read.
  Future<void> _cacheUserCredentials(UserModel user) async {
    await _secureStorage.write(
      key: AppConstants.secureStorageUidKey,
      value: user.uid,
    );
    await _secureStorage.write(
      key: AppConstants.secureStorageRoleKey,
      value: user.role,
    );
  }

  Future<void> _clearCachedCredentials() async {
    await _secureStorage.delete(key: AppConstants.secureStorageUidKey);
    await _secureStorage.delete(key: AppConstants.secureStorageRoleKey);
  }

  /// Reads cached role for quick startup routing.
  /// Returns null if nothing is cached.
  Future<String?> getCachedRole() async {
    return await _secureStorage.read(key: AppConstants.secureStorageRoleKey);
  }

  // ── Error Mapping ──

  /// Maps Firebase Auth error codes to our custom [AppException].
  AppException _mapFirebaseAuthError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AppException.userNotFound();
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-email':
        return AppException.invalidCredentials();
      case 'email-already-in-use':
        return AppException.emailAlreadyInUse();
      case 'weak-password':
        return AppException.weakPassword();
      case 'user-disabled':
        return AppException.userDisabled();
      case 'too-many-requests':
        return AppException.tooManyRequests();
      case 'network-request-failed':
        return AppException.networkError();
      default:
        return AppException.unknown(e);
    }
  }

  /// Maps Firestore errors to our custom [AppException].
  AppException _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return AppException.permissionDenied();
      case 'unavailable':
      case 'deadline-exceeded':
        return AppException.networkError();
      default:
        return AppException.unknown(e);
    }
  }
}

// ── Riverpod Provider ──

/// Global provider for [AuthRepository].
/// Uses a simple Provider (not .autoDispose) since auth should persist
/// for the entire app lifecycle.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});