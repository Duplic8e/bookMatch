abstract class UserProfileRepository {
  Future<void> createUserProfile({
    required String userId,
    required String email,
    required Set<String> preferences,
  });
// Future<UserProfile?> getUserProfile(String userId);
// Future<void> updateUserProfile(String userId, Map<String, dynamic> data);
}