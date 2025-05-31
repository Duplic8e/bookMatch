import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:mobile_app_project_bookstore/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:mobile_app_project_bookstore/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app_project_bookstore/features/user_profile/domain/repositories/user_profile_repository.dart'; // Make sure this import is correct

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _firebaseAuthDataSource;
  final UserProfileRepository _userProfileRepository; // Assuming you still have this

  AuthRepositoryImpl(
    this._firebaseAuthDataSource,
    this._userProfileRepository, // Assuming you still have this
  );

  @override
  Future<firebase_auth.User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required Set<String> preferences,
  }) async {
    final firebaseUser = await _firebaseAuthDataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (firebaseUser != null) {
      try {
        await _userProfileRepository.createUserProfile(
          userId: firebaseUser.uid,
          email: email,
          preferences: preferences,
        );
      } catch (e) {
        print("Error creating user profile in Firestore: $e. User ${firebaseUser.uid} is signed up in Auth.");
        // Decide how to handle this: rethrow, log, or attempt cleanup.
        // For now, the user is signed up in Auth, but their profile might be missing in Firestore.
      }
    }
    return firebaseUser;
  }
  @override
  Future<firebase_auth.User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuthDataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuthDataSource.signOut();
  }

  // --- ENSURE THESE MATCH THE GETTERS IN THE DATASOURCE ---
  @override
  Stream<firebase_auth.User?> get authStateChanges =>
      _firebaseAuthDataSource.authStateChanges;

  @override
  firebase_auth.User? get currentUser => _firebaseAuthDataSource.currentUser;
  // --- END OF CHECK ---
}
