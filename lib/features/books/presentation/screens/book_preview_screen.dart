import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_app_project_bookstore/features/library/domain/entities/bookmark.dart';
import 'package:mobile_app_project_bookstore/features/library/presentation/providers/library_providers.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BookPreviewScreen extends ConsumerStatefulWidget {
  final String bookId;
  final String pdfUrl;
  final String bookTitle;
  final int initialPage;
  final bool isFromLibrary;

  const BookPreviewScreen({
    Key? key,
    required this.bookId,
    required this.pdfUrl,
    required this.bookTitle,
    this.initialPage = 1,
    required this.isFromLibrary,
  }) : super(key: key);

  @override
  ConsumerState<BookPreviewScreen> createState() => _BookPreviewScreenState();
}

class _BookPreviewScreenState extends ConsumerState<BookPreviewScreen> {
  late PdfViewerController _pdfViewerController;
  Timer? _debounce;
  int _totalPages = 0;
  int _currentPage = 0;
  PdfPageLayoutMode _layoutMode = PdfPageLayoutMode.continuous;
  bool _showControls = true;
  double _sliderValue = 1.0;
  bool _isEyeComfortModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _currentPage = widget.initialPage;
    _sliderValue = widget.initialPage.toDouble();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.isFromLibrary && _totalPages > 0) {
      ref.read(updateProgressProvider(
        (bookId: widget.bookId, pageNumber: _currentPage, totalPages: _totalPages),
      ));
    }
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    if (!mounted) return;
    setState(() {
      _currentPage = details.newPageNumber;
      _sliderValue = _currentPage.toDouble();
    });
    if (!widget.isFromLibrary) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted || _totalPages == 0) return;
      ref.read(updateProgressProvider(
        (bookId: widget.bookId, pageNumber: _currentPage, totalPages: _totalPages),
      ));
    });
  }

  void _showAddBookmarkDialog() {
    final labelController = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Add Bookmark on Page $_currentPage',
          style: GoogleFonts.merriweather(),
        ),
        content: TextField(
          controller: labelController,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Bookmark Label (e.g., Chapter 3)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.merriweather()),
          ),
          ElevatedButton(
            onPressed: () {
              if (labelController.text.isNotEmpty) {
                final newBm = Bookmark(
                  pageNumber: _currentPage,
                  label: labelController.text,
                );
                ref.read(addBookmarkProvider((bookId: widget.bookId, bookmark: newBm)));
                Navigator.pop(context);
              }
            },
            child: Text('Save', style: GoogleFonts.merriweather()),
          ),
        ],
      ),
    );
  }

  void _showBookmarksList(List<Bookmark> bookmarks) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Bookmarks',
                  style: GoogleFonts.medievalSharp(
                    textStyle: theme.textTheme.headlineSmall!,
                  ),
                ),
              ),
              if (bookmarks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'No bookmarks yet.',
                      style: GoogleFonts.merriweather(
                        textStyle: theme.textTheme.bodyMedium!,
                      ),
                    ),
                  ),
                ),
              for (final bm in bookmarks)
                ListTile(
                  title: Text(bm.label, style: GoogleFonts.merriweather()),
                  subtitle: Text('Page ${bm.pageNumber}', style: GoogleFonts.merriweather()),
                  onTap: () {
                    _pdfViewerController.jumpToPage(bm.pageNumber);
                    Navigator.pop(context);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () {
                      ref.read(removeBookmarkProvider((bookId: widget.bookId, bookmark: bm)));
                      Navigator.pop(context);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final libraryEntryAsync = ref.watch(libraryEntryProvider(widget.bookId));

    return Scaffold(
      appBar: _showControls
          ? AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Theme.of(context).colorScheme.surface,
                statusBarIconBrightness: Brightness.dark,
              ),
              foregroundColor: Theme.of(context).colorScheme.primary,
              elevation: 0,
              title: Text(
                widget.bookTitle,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.merriweather(
                  textStyle: Theme.of(context).textTheme.titleMedium!,
                ),
              ),
              actions: [
                if (widget.isFromLibrary) ...[
                  IconButton(
                    icon: Image.asset('lib/features/books/assets/social.png', width: 24, height: 24),
                    tooltip: 'Share a Thought',
                    onPressed: () {
                      final citation = {'title': widget.bookTitle, 'pageNumber': _currentPage};
                      context.pushNamed('createPost', extra: citation);
                    },
                  ),
                  IconButton(
                    icon: Image.asset(
                      _isEyeComfortModeEnabled
                          ? 'lib/features/books/assets/sun.png'
                          : 'lib/features/books/assets/moon.png',
                      width: 24,
                      height: 24,
                    ),
                    tooltip: 'Toggle Eye-Comfort Mode',
                    onPressed: () => setState(() => _isEyeComfortModeEnabled = !_isEyeComfortModeEnabled),
                  ),
                  IconButton(
                    icon: Image.asset(
                      _layoutMode == PdfPageLayoutMode.continuous
                          ? 'lib/features/books/assets/scroll.png'
                          : 'lib/features/books/assets/turn-the-pages.png',
                      width: 24,
                      height: 24,
                    ),
                    tooltip: 'Toggle Layout',
                    onPressed: () => setState(() {
                      _layoutMode = _layoutMode == PdfPageLayoutMode.continuous
                          ? PdfPageLayoutMode.single
                          : PdfPageLayoutMode.continuous;
                    }),
                  ),
                  libraryEntryAsync.when(
                    data: (entry) => IconButton(
                      icon: Image.asset('lib/features/books/assets/bookmark.png', width: 24, height: 24),
                      tooltip: 'View Bookmarks',
                      onPressed: () => _showBookmarksList(entry?.bookmarks ?? []),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const Icon(Icons.error),
                  ),
                ],
              ],
            )
          : null,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: SfPdfViewer.network(
          widget.pdfUrl,
          controller: _pdfViewerController,
          pageLayoutMode: _layoutMode,
          onDocumentLoaded: (details) {
            if (!mounted) return;
            setState(() => _totalPages = details.document.pages.count);
            if (widget.initialPage > 1) {
              _pdfViewerController.jumpToPage(widget.initialPage);
            }
          },
          onPageChanged: _onPageChanged,
        ),
      ),
      floatingActionButton: _showControls && widget.isFromLibrary
          ? FloatingActionButton.extended(
              onPressed: _showAddBookmarkDialog,
              label: Text('Bookmark Page', style: GoogleFonts.merriweather()),
              icon: const Icon(Icons.bookmark_add_outlined),
            )
          : null,
      bottomNavigationBar: _showControls && widget.isFromLibrary && _totalPages > 0
          ? BottomAppBar(
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      '$_currentPage / $_totalPages',
                      style: GoogleFonts.merriweather(textStyle: Theme.of(context).textTheme.bodyMedium!),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Slider(
                        value: _sliderValue,
                        min: 1,
                        max: _totalPages > 0 ? _totalPages.toDouble() : 1.0,
                        activeColor: Theme.of(context).colorScheme.primary,
                        inactiveColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                        onChanged: (value) => setState(() => _sliderValue = value),
                        onChangeEnd: (value) => _pdfViewerController.jumpToPage(value.round()),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
