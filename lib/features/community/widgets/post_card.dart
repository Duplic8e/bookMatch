import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/community/domain/entities/community_post.dart';
import 'package:mobile_app_project_bookstore/features/community/providers/community_providers.dart';
import 'package:mobile_app_project_bookstore/features/community/providers/comment_providers.dart';

class PostCard extends ConsumerWidget {
  final CommunityPost post;
  const PostCard({Key? key, required this.post}) : super(key: key);

  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme       = Theme.of(context);
    final currentUser = ref.watch(authStateChangesProvider).value;
    final isLiked     = currentUser != null && post.likedBy.contains(currentUser.uid);
    final isAuthor    = currentUser != null && post.authorId == currentUser.uid;

    final commentsAsync = ref.watch(commentsStreamProvider(post.id));
    final authorInitial = post.authorName.isNotEmpty
        ? post.authorName[0].toUpperCase()
        : '?';

    return Card(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: theme.colorScheme.primary.withOpacity(0.2),
        highlightColor: Colors.transparent,
        onTap: () => context.pushNamed(
          'postDetails',
          pathParameters: {'postId': post.id},
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      authorInitial,
                      style: GoogleFonts.merriweather(
                        textStyle: theme.textTheme.titleMedium,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: GoogleFonts.merriweather(
                            textStyle: theme.textTheme.bodyLarge,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          DateFormat.yMMMd().add_jm().format(post.createdAt),
                          style: GoogleFonts.merriweather(
                            textStyle: theme.textTheme.bodySmall,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isAuthor)
                    IconButton(
                      iconSize: _iconSize,
                      icon: Image.asset(
                        'lib/features/community/assets/delete.png',
                        width: _iconSize,
                        height: _iconSize,
                      ),
                      onPressed: () =>
                          ref.read(communityControllerProvider.notifier).deletePost(post.id),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Book citation pill (wood-brown container)
              if (post.bookCitation != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'From "${post.bookCitation!['title']}" '
                    '(Page ${post.bookCitation!['pageNumber']})',
                    style: GoogleFonts.merriweather(
                      textStyle: theme.textTheme.bodySmall,
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),

              // Post text
              Text(
                post.text,
                style: GoogleFonts.merriweather(
                  textStyle: theme.textTheme.bodyMedium,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 12),

              // Action row
              Row(
                children: [
                  // Like button
                  IconButton(
                    iconSize: _iconSize,
                    icon: Image.asset(
                      'lib/features/community/assets/like.png',
                      width: _iconSize,
                      height: _iconSize,
                    ),
                    onPressed: () => ref
                        .read(communityControllerProvider.notifier)
                        .togglePostLike(post.id),
                  ),
                  Text(
                    '${post.likedBy.length}',
                    style: GoogleFonts.merriweather(
                      textStyle: theme.textTheme.bodySmall,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Comment button
                  IconButton(
                    iconSize: _iconSize,
                    icon: Image.asset(
                      'lib/features/community/assets/comments.png',
                      width: _iconSize,
                      height: _iconSize,
                    ),
                    onPressed: () => context.pushNamed(
                      'postDetails',
                      pathParameters: {'postId': post.id},
                    ),
                  ),
                  commentsAsync.when(
                    data: (comments) => Text(
                      '${comments.length}',
                      style: GoogleFonts.merriweather(
                        textStyle: theme.textTheme.bodySmall,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    loading: () => SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    error: (_, __) => Text(
                      '0',
                      style: GoogleFonts.merriweather(
                        textStyle: theme.textTheme.bodySmall,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
