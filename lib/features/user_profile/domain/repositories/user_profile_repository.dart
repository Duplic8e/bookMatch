abstract class UserProfileRepository {
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required List<String> favoriteGenres,
  });
}
