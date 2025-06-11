import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app_project_bookstore/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:mobile_app_project_bookstore/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Stream<User?> get authStateChanges => dataSource.authStateChanges;

  @override
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password) {
    return dataSource.createUserWithEmailAndPassword(email, password);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) {
    return dataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<void> signOut() {
    return dataSource.signOut();
  }
}
