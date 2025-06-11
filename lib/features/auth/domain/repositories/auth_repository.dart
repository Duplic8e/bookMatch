import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;

  Future<UserCredential> createUserWithEmailAndPassword(String email, String password);

  Future<UserCredential> signInWithEmailAndPassword(String email, String password);

  Future<void> signOut();
}
