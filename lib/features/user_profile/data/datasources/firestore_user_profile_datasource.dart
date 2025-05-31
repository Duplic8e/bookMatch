import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUserProfileDataSource {
  final FirebaseFirestore _firestore;

  FirestoreUserProfileDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String userId,
    required String email, // Good to store email for easier querying if needed
    required Set<String> preferences,
    // You can add other fields like displayName, photoUrl (if you collect them)
  }) async {
    try {
      // Create a document with the user's UID as the document ID
      await _firestore.collection('users').doc(userId).set({
        'uid': userId,
        'email': email,
        'preferences': preferences.toList(), // Firestore stores Sets as Arrays
        'createdAt': FieldValue.serverTimestamp(), // Good practice to store creation time
        // 'displayName': '', // Initialize if you plan to use it
        // 'photoUrl': '',   // Initialize if you plan to use it
      });
    } on FirebaseException catch (e) {
      // Handle potential Firestore errors (e.g., permissions)
      print("FirebaseException when creating user profile: ${e.message} (code: ${e.code})");
      throw Exception('Failed to create user profile: ${e.message}');
    } catch (e) {
      print("Unknown exception when creating user profile: $e");
      throw Exception('An unknown error occurred while creating the user profile.');
    }
  }

// TODO: Add methods to getUserProfile, updateUserProfile, etc.
// Future<Map<String, dynamic>?> getUserProfile(String userId) async { ... }
}