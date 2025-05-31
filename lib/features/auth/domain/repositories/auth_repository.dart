import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias

abstract class AuthRepository {
  Future<firebase_auth.User?> signUpWithEmailAndPassword({ // Use alias
    required String email,
    required String password,
    required Set<String> preferences,
  });

  Future<firebase_auth.User?> signInWithEmailAndPassword({ // Use alias
    required String email,
    required String password,
  });

  Future<void> signOut();

  Stream<firebase_auth.User?> get authStateChanges; // Use alias
  firebase_auth.User? get currentUser; // Use alias
}