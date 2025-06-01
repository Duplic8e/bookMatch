import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; // Alias
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookmatch/features/auth/data/datasources/firebase_auth_datasource.dart';
import 'package:bookmatch/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bookmatch/features/auth/domain/repositories/auth_repository.dart'; // Import the UserProfile providers
import 'package:bookmatch/features/user_profile/presentation/providers/user_profile_providers.dart';

// Provider for FirebaseAuth instance (though often used directly in datasource)
// final firebaseAuthProvider = Provider<firebase_auth.FirebaseAuth>((ref) {
//   return firebase_auth.FirebaseAuth.instance;
// });

// Provider for FirebaseAuthDataSource
final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  // If you had the firebaseAuthProvider above, you could pass it:
  // return FirebaseAuthDataSource(firebaseAuth: ref.watch(firebaseAuthProvider));
  return FirebaseAuthDataSource(); // Uses default FirebaseAuth.instance
});

// ... (other providers like firebaseAuthDataSourceProvider, authRepositoryProvider) ...

// Update authRepositoryProvider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuthDataSource = ref.watch(firebaseAuthDataSourceProvider);
  final userProfileRepository = ref.watch(userProfileRepositoryProvider); // Watch the new provider
  return AuthRepositoryImpl(
    firebaseAuthDataSource,
    userProfileRepository, // Pass it here
  );
});
// --- Auth State Notifier ---
// Represents the different states of our authentication process
class AuthScreenState {
  final firebase_auth.User? user;
  final bool isLoading;
  final String? error;

  const AuthScreenState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  // Helper to easily create a new state from the old one
  AuthScreenState copyWith({
    firebase_auth.User? user, // Use alias
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AuthScreenState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// The StateNotifier that will manage the AuthScreenState
class AuthNotifier extends StateNotifier<AuthScreenState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthScreenState()) {
    print("DEBUG: AuthNotifier initialized"); // DEBUG
    // Optional: _initializeUser();
  }

  // void _initializeUser() {
  //   final currentUser = _authRepository.currentUser; // Should be firebase_auth.User?
  //   state = state.copyWith(user: currentUser, isLoading: false);
  // }
  // ... (signUpUser method) ...

  Future<void> signUpUser(String email, String password, Set<String> preferences) async {
    state = state.copyWith(isLoading: true, clearError: true, user: null);
    try {
      final user = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        preferences: preferences,
      );
      state = state.copyWith(isLoading: false, user: user, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), user: null);
    }
  }

  Future<void> signInUser(String email, String password) async {
    print("DEBUG: AuthNotifier - signInUser called with Email: $email"); // DEBUG
    state = state.copyWith(isLoading: true, clearError: true, user: null);
    try {
      print("DEBUG: AuthNotifier - Calling _authRepository.signInWithEmailAndPassword"); // DEBUG
      final user = await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print("DEBUG: AuthNotifier - signInWithEmailAndPassword SUCCESS. User: ${user?.uid}"); // DEBUG
      state = state.copyWith(isLoading: false, user: user, error: null);
    } catch (e, stackTrace) { // Added stackTrace
      print("DEBUG: AuthNotifier - signInWithEmailAndPassword FAILED. Error: $e"); // DEBUG
      print("DEBUG: AuthNotifier - StackTrace: $stackTrace"); // DEBUG
      state = state.copyWith(isLoading: false, error: e.toString(), user: null);
    }
  }

  Future<void> signOutUser() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      print("DEBUG: AuthNotifier - signOutUser called"); // DEBUG
      await _authRepository.signOut();
      print("DEBUG: AuthNotifier - signOut SUCCESS."); // DEBUG
      state = const AuthScreenState(user: null, isLoading: false);
    } catch (e, stackTrace) { // Added stackTrace
      print("DEBUG: AuthNotifier - signOut FAILED. Error: $e"); // DEBUG
      print("DEBUG: AuthNotifier - StackTrace: $stackTrace"); // DEBUG
      state = state.copyWith(isLoading: false, error: "Error signing out: ${e.toString()}");
    }
  }

  // New method to clear error message from UI if needed
  void clearError() {
    if (state.error != null) {
      print("DEBUG: AuthNotifier - Clearing error: ${state.error}"); //DEBUG
      state = state.copyWith(clearError: true);
    }
  }

  // To check initial auth state or listen to changes globally
  // This is a common pattern but we'll use a StreamProvider for global state soon
  // void checkCurrentUser() {
  //   final user = _authRepository.currentUser;
  //   state = state.copyWith(user: user, isLoading: false);
  // }

}

// The AuthNotifier already takes AuthRepository, which will now have the
// UserProfileRepository injected into its implementation.
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthScreenState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

// --- Auth State Stream Provider (for global auth state like logged in/out) ---
// This is different from the AuthScreenState which is for screen-specific operations
final authStateChangesProvider = StreamProvider<firebase_auth.User?>((ref) {
  print("DEBUG: authStateChangesProvider is being set up."); // DEBUG
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges.map((user) { // Add map to see emissions
    print("DEBUG: authStateChangesProvider EMITTED USER: ${user?.uid}"); // DEBUG
    return user;
  });
});

// Provider to get the initial (current) user synchronously
// This can be useful for initial route decisions before the stream emits.
final currentUserProvider = Provider<firebase_auth.User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final user = authRepository.currentUser;
  print("DEBUG: currentUserProvider returning: ${user?.uid}"); // DEBUG
  return user;
});
