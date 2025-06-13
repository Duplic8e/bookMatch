import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/community/domain/entities/comment.dart';
import 'package:mobile_app_project_bookstore/features/community/models/comment_model.dart';

// Provider for the comments sub-collection of a specific post
final commentsCollectionProvider = Provider.family<CollectionReference, String>((ref, postId) {
  return FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments');
});

// Provider to stream comments for a post
final commentsStreamProvider = StreamProvider.autoDispose.family<List<Comment>, String>((ref, postId) {
  final collection = ref.watch(commentsCollectionProvider(postId));
  return collection.orderBy('createdAt', descending: false).snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => CommentModel.fromFirestore(doc)).toList();
  });
});

// Provider for comment actions
final commentControllerProvider = Provider((ref) {
  return CommentController(ref);
});

class CommentController {
  final Ref _ref;
  CommentController(this._ref);

  Future<void> addComment({required String postId, required String text}) async {
    final user = _ref.read(authStateChangesProvider).value;
    if (user == null) throw Exception('User not logged in');

    final newComment = CommentModel(
      id: '', // Firestore will generate
      postId: postId,
      authorId: user.uid,
      authorName: user.displayName ?? 'Anonymous',
      text: text,
      createdAt: DateTime.now(),
    );

    final collection = _ref.read(commentsCollectionProvider(postId));
    await collection.add(newComment.toFirestore());
  }
}
