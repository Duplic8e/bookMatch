import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class FirebaseAuthDataSource {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthDataSource({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  Future<firebase_auth.User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      // Consider more specific error handling based on e.code
      print("FirebaseAuthException on sign up: ${e.message} (code: ${e.code})");
      throw Exception(e.message ?? 'An unknown authentication error occurred.');
    } catch (e) {
      print("Unknown exception on sign up: $e");
      throw Exception('An unknown error occurred during sign up.');
    }
  }

  Future<firebase_auth.User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("FirebaseAuthException on sign in: ${e.message} (code: ${e.code})");
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential' || e.code == 'INVALID_LOGIN_CREDENTIALS') { // Added common new code
        throw Exception('Invalid email or password.');
      }
      throw Exception(e.message ?? 'An unknown authentication error occurred.');
    } catch (e) {
      print("Unknown exception on sign in: $e");
      throw Exception('An unknown error occurred during sign in.');
    }
  }

  Future<void> signOut() async {
    try {
      print("FirebaseAuthDataSource: Attempting to sign out.");
      await _firebaseAuth.signOut();
      print("FirebaseAuthDataSource: Sign out successful.");
    } catch (e) {
      print("Unknown exception on sign out: $e");
      // Depending on app requirements, you might rethrow or handle differently
    }
  }

  // --- ENSURE THESE ARE EXACTLY AS FOLLOWS ---
  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;
  // --- END OF CHECK ---
}
