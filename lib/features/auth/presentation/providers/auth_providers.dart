import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:mobile_app_project_bookstore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mobile_app_project_bookstore/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_app_project_bookstore/features/user_profile/presentation/providers/user_profile_providers.dart';

// 1. Datasource Provider
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource(FirebaseAuth.instance);
});

// 2. Repository Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(firebaseAuthDataSourceProvider);
  return AuthRepositoryImpl(dataSource: dataSource);
});

// 3. Provider to get the current user object
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateChangesProvider).value;
});

// 4. Provider to watch auth state changes
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

// A raw stream provider specifically for the router
final authStateStreamProvider = Provider<Stream<User?>>((ref) {
  return ref.read(authRepositoryProvider).authStateChanges;
});

// 5. Auth State Notifier Provider
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthScreenState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final createUserProfile = ref.watch(createUserProfileProvider);
  return AuthNotifier(
    authRepository: authRepository,
    createUserProfile: createUserProfile,
  );
});

class AuthScreenState {
  final bool isLoading;
  final String? error;
  final User? user;

  AuthScreenState({this.isLoading = false, this.error, this.user});

  AuthScreenState copyWith({bool? isLoading, String? error, User? user}) {
    return AuthScreenState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Allow setting error to null
      user: user,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthScreenState> {
  final AuthRepository authRepository;
  final Future<void> Function({
  required String uid,
  required String email,
  required String displayName,
  required List<String> favoriteGenres,
  }) createUserProfile;

  AuthNotifier({
    required this.authRepository,
    required this.createUserProfile,
  }) : super(AuthScreenState()) {
    _init();
  }

  void _init() {
    authRepository.authStateChanges.listen((user) {
      state = state.copyWith(user: user, isLoading: false);
    });
  }

  // ** FIX: Added clearError method back in **
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  Future<void> signInUser(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await authRepository.signInWithEmailAndPassword(email, password);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signUpUser(String email, String password, String displayName, List<String> favoriteGenres) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final userCredential = await authRepository.createUserWithEmailAndPassword(email, password);
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(displayName);
        await createUserProfile(
          uid: userCredential.user!.uid,
          email: email,
          displayName: displayName,
          favoriteGenres: favoriteGenres,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOutUser() async {
    state = state.copyWith(isLoading: true);
    try {
      await authRepository.signOut();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
