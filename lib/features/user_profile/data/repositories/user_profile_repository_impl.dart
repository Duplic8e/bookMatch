import 'package:bookmatch/features/user_profile/data/datasources/firestore_user_profile_datasource.dart';
import 'package:bookmatch/features/user_profile/domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirestoreUserProfileDataSource _dataSource;

  UserProfileRepositoryImpl(this._dataSource);

  @override
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required Set<String> preferences,
  }) async {
    await _dataSource.createUserProfile(
      userId: userId,
      email: email,
      preferences: preferences,
    );
  }
}
