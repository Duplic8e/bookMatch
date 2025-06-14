import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';  // for context.pop()
import 'package:google_fonts/google_fonts.dart';

import 'package:mobile_app_project_bookstore/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile_app_project_bookstore/features/community/providers/community_providers.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? bookCitation;

  const CreatePostScreen({Key? key, this.bookCitation}) : super(key: key);

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final authorName = ref.read(authStateChangesProvider).value?.displayName ?? 'Anonymous';
    await ref.read(communityControllerProvider.notifier).addPost(
      text: text,
      authorName: authorName,
      bookCitation: widget.bookCitation,
    );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.primary,
        elevation: 0,
        title: Text(
          'Create a Post',
          style: GoogleFonts.medievalSharp(textStyle: theme.textTheme.titleLarge!),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              textStyle: GoogleFonts.merriweather(textStyle: theme.textTheme.titleSmall!),
            ),
            child: const Text('POST'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.bookCitation != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sharing a thought from "${widget.bookCitation!['title']}" '
                  '(Page ${widget.bookCitation!['pageNumber']})',
                  style: GoogleFonts.merriweather(textStyle: theme.textTheme.bodySmall!),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ← Fixed-height input box
            SizedBox(
              height: 200,
              child: TextField(
                controller: _controller,
                minLines: null,
                maxLines: null,
                expands: false,
                style: GoogleFonts.merriweather(textStyle: theme.textTheme.bodyMedium!),
                decoration: InputDecoration(
                  hintText: 'Share your thoughts…',
                  hintStyle: GoogleFonts.merriweather(
                    textStyle: theme.textTheme.bodyMedium!.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
