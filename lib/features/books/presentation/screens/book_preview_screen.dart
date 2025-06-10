import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    super.key,
    required this.bookId,
    required this.pdfUrl,
    required this.bookTitle,
    this.initialPage = 1,
    required this.isFromLibrary,
  });

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
  // ** CHANGE: Renamed for clarity **
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

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), () {
      if (!mounted || _totalPages == 0) return;
      ref.read(updateProgressProvider(
        (bookId: widget.bookId, pageNumber: _currentPage, totalPages: _totalPages),
      ));
    });
  }

  void _showAddBookmarkDialog() {
    // ... (logic remains the same)
    final TextEditingController labelController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Bookmark on Page $_currentPage'),
          content: TextField(
            controller: labelController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Bookmark Label (e.g., Chapter 3)'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.isNotEmpty) {
                  final newBookmark = Bookmark(pageNumber: _currentPage, label: labelController.text);
                  ref.read(addBookmarkProvider((bookId: widget.bookId, bookmark: newBookmark)));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showBookmarksList(List<Bookmark> bookmarks) {
    // ... (logic remains the same)
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Bookmarks', style: Theme.of(context).textTheme.headlineSmall),
              ),
              if (bookmarks.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text('No bookmarks yet.'))),
              ...bookmarks.map((bookmark) => ListTile(
                title: Text(bookmark.label),
                subtitle: Text('Page ${bookmark.pageNumber}'),
                onTap: () {
                  _pdfViewerController.jumpToPage(bookmark.pageNumber);
                  Navigator.of(context).pop();
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    ref.read(removeBookmarkProvider((bookId: widget.bookId, bookmark: bookmark)));
                    Navigator.of(context).pop();
                  },
                ),
              )),
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
      appBar: _showControls ? AppBar(
        title: Text(widget.bookTitle, overflow: TextOverflow.ellipsis),
        actions: [
          if (widget.isFromLibrary) ...[
            IconButton(
              icon: Icon(_isEyeComfortModeEnabled ? Icons.wb_sunny_outlined : Icons.bedtime_outlined),
              tooltip: 'Toggle Eye-Comfort Mode',
              onPressed: () => setState(() => _isEyeComfortModeEnabled = !_isEyeComfortModeEnabled),
            ),
            IconButton(
              icon: Icon(_layoutMode == PdfPageLayoutMode.continuous ? Icons.view_carousel_outlined : Icons.view_day_outlined),
              tooltip: 'Toggle Layout',
              onPressed: () => setState(() => _layoutMode = _layoutMode == PdfPageLayoutMode.continuous ? PdfPageLayoutMode.single : PdfPageLayoutMode.continuous),
            ),
            libraryEntryAsync.when(
              data: (entry) => IconButton(
                icon: const Icon(Icons.bookmark_sharp),
                tooltip: 'View Bookmarks',
                onPressed: () => _showBookmarksList(entry?.bookmarks ?? []),
              ),
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const Icon(Icons.error),
            ),
          ]
        ],
      ) : null,
      body: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          children: [
            SfPdfViewer.network(
              widget.pdfUrl,
              controller: _pdfViewerController,
              pageLayoutMode: _layoutMode,
              onDocumentLoaded: (details) {
                if (!mounted) return;
                setState(() {
                  _totalPages = details.document.pages.count;
                });
                if (widget.initialPage > 1) {
                  _pdfViewerController.jumpToPage(widget.initialPage);
                }
              },
              onPageChanged: _onPageChanged,
            ),
            // ** THE FIX: Use a Sepia Tone overlay instead of a dimming one **
            if (widget.isFromLibrary && _isEyeComfortModeEnabled)
              IgnorePointer(
                child: Container(
                  // A pleasant, warm color for eye comfort.
                  color: const Color(0xFFFBF0D9).withOpacity(0.4),
                  // Using a blend mode can also create interesting effects
                  // blendMode: BlendMode.multiply,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _showControls && widget.isFromLibrary ? FloatingActionButton.extended(
        onPressed: _showAddBookmarkDialog,
        label: const Text('Bookmark Page'),
        icon: const Icon(Icons.bookmark_add_outlined),
      ) : null,
      bottomNavigationBar: _showControls && widget.isFromLibrary && _totalPages > 0 ? BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text('$_currentPage / $_totalPages'),
              Expanded(
                child: Slider(
                  value: _sliderValue,
                  min: 1,
                  max: _totalPages > 0 ? _totalPages.toDouble() : 1.0,
                  onChanged: (value) => setState(() => _sliderValue = value),
                  onChangeEnd: (value) => _pdfViewerController.jumpToPage(value.round()),
                ),
              ),
            ],
          ),
        ),
      ) : null,
    );
  }
}
