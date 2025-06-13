import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/community/domain/entities/community_post.dart';
import 'package:mobile_app_project_bookstore/features/community/providers/community_providers.dart';

class PostCard extends ConsumerWidget {
  final CommunityPost post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authStateChangesProvider).value;
    final isLiked = currentUser != null && post.likedBy.contains(currentUser.uid);
    final isAuthor = currentUser != null && post.authorId == currentUser.uid;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(child: Text(post.authorName.substring(0, 1))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(DateFormat.yMMMd().add_jm().format(post.createdAt), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (isAuthor)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ref.read(communityControllerProvider.notifier).deletePost(post.id),
                  )
              ],
            ),
            const SizedBox(height: 12),
            if (post.bookCitation != null)
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'From "${post.bookCitation!['title']}" (Page ${post.bookCitation!['pageNumber']})',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            Text(post.text, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                    color: isLiked ? Theme.of(context).colorScheme.primary : null,
                  ),
                  onPressed: () => ref.read(communityControllerProvider.notifier).togglePostLike(post.id),
                ),
                Text('${post.likedBy.length}'),
                const SizedBox(width: 24),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () => context.pushNamed('postDetails', pathParameters: {'postId': post.id}),
                ),
                // ** NEW: Display the comment count **
                Text('${post.commentCount}'),
              ],
            )
          ],
        ),
      ),
    );
  }
}
