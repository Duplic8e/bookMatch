import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookmatch/features/user_profile/data/datasources/firestore_user_profile_datasource.dart';
import 'package:bookmatch/features/user_profile/data/repositories/user_profile_repository_impl.dart';
import 'package:bookmatch/features/user_profile/domain/repositories/user_profile_repository.dart';

// Provider for FirestoreUserProfileDataSource
final firestoreUserProfileDataSourceProvider =
    Provider<FirestoreUserProfileDataSource>((ref) {
      return FirestoreUserProfileDataSource();
    });

// Provider for UserProfileRepository
final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final dataSource = ref.watch(firestoreUserProfileDataSourceProvider);
  return UserProfileRepositoryImpl(dataSource);
});

// You might also create a StateNotifier here if you need to manage
// the state of loading/saving user profiles, similar to AuthNotifier.
// For now, we'll call the repository method directly.
