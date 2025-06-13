import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app_project_bookstore/features/community/models/comment_model.dart';
import 'package:mobile_app_project_bookstore/features/community/models/community_post_model.dart';

class FirestoreCommunityPostDataSource {
  final FirebaseFirestore _firestore;

  FirestoreCommunityPostDataSource() : _firestore = FirebaseFirestore.instance;

  CollectionReference get _postsRef => _firestore.collection('posts');

  CollectionReference _commentsRef(String postId) => _postsRef.doc(postId).collection('comments');

  Future<List<QueryDocumentSnapshot<Object?>>> getPosts({DocumentSnapshot? lastDoc, int limit = 10}) async {
    Query query = _postsRef.orderBy('createdAt', descending: true).limit(limit);
    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }
    final snapshot = await query.get();
    return snapshot.docs;
  }

  Future<void> addPost(CommunityPostModel post) {
    return _postsRef.add(post.toMap());
  }

  Future<void> deletePost(String postId) async {
    // In a real app, you might use a batch write or Cloud Function to delete sub-collections
    return _postsRef.doc(postId).delete();
  }

  Future<void> togglePostLike({required String postId, required String userId}) async {
    final docRef = _postsRef.doc(postId);
    final doc = await docRef.get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      final List<dynamic> likes = data?['likedBy'] ?? [];

      if (likes.contains(userId)) {
        await docRef.update({'likedBy': FieldValue.arrayRemove([userId])});
      } else {
        await docRef.update({'likedBy': FieldValue.arrayUnion([userId])});
      }
    }
  }

  // ** NEW: Method to add a comment and increment the count **
  Future<void> addComment({required String postId, required CommentModel comment}) async {
    final postRef = _postsRef.doc(postId);
    final commentRef = _commentsRef(postId).doc();

    return _firestore.runTransaction((transaction) async {
      transaction.set(commentRef, comment.toFirestore());
      transaction.update(postRef, {'commentCount': FieldValue.increment(1)});
    });
  }
}
