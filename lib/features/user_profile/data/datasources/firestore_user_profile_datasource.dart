import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreUserProfileDataSource {
  final FirebaseFirestore _firestore;

  FirestoreUserProfileDataSource(this._firestore);

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
    required List<String> favoriteGenres,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'favoriteGenres': favoriteGenres,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error creating user profile in Firestore: $e');
      rethrow;
    }
  }
}
