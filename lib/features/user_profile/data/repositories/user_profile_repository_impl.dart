import 'package:mobile_app_project_bookstore/features/user_profile/data/datasources/firestore_user_profile_datasource.dart';
import 'package:mobile_app_project_bookstore/features/user_profile/domain/repositories/user_profile_repository.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final FirestoreUserProfileDataSource dataSource;

  UserProfileRepositoryImpl({required this.dataSource});

  @override
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required List<String> favoriteGenres,
  }) {
    return dataSource.createUserProfile(
      uid: uid,
      email: email,
      displayName: displayName,
      favoriteGenres: favoriteGenres,
    );
  }
}
