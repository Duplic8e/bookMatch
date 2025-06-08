// lib/features/books/presentation/screens/book_preview_screen.dart
// Keep for potential local file operations if needed in the future
import 'package:flutter/material.dart';
// Still needed if loading from a network URL
// Still potentially useful for caching
// Alias for path package

// **** IMPORT SYNCFUSION PDF VIEWER ****
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class BookPreviewScreen extends StatefulWidget {
  final String pdfUrl;
  final String bookTitle;

  const BookPreviewScreen({
    super.key,
    required this.pdfUrl,
    required this.bookTitle,
  });

  @override
  State<BookPreviewScreen> createState() => _BookPreviewScreenState();
}

class _BookPreviewScreenState extends State<BookPreviewScreen> {
  // For Syncfusion, you might not need to manage the local path as explicitly
  // if you're primarily loading from a URL.
  // String? _localPdfPath; // May not be needed if SfPdfViewer.network handles caching well

  bool _isLoading = true; // Still useful to show a loading indicator initially
  String? _errorMessage;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  PdfViewerController? _pdfViewerController; // Controller for Syncfusion PDF Viewer

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    // With SfPdfViewer.network, the loading is handled by the widget itself.
    // We can set isLoading to false once the widget is built or use its built-in indicators.
    // For simplicity, we'll let SfPdfViewer handle its own loading display for network URLs.
    if (widget.pdfUrl.isEmpty) {
      _errorMessage = "PDF URL is missing.";
      _isLoading = false;
    } else {
      // If it's a network URL, SfPdfViewer handles it directly
      // If it were a local file path, you would use SfPdfViewer.file()
      _isLoading = false; // Assuming SfPdfViewer.network will show its own progress
    }
  }

  // Example of how you might download and then view, if you need more control or offline access:
  /*
  Future<void> _loadAndCachePdf() async {
    if (!widget.pdfUrl.startsWith('http')) {
      setState(() {
        _errorMessage = "Invalid PDF URL format for network loading.";
        _isLoading = false;
      });
      return;
    }
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filename = '${widget.bookTitle.replaceAll(RegExp(r'[^A-Za-z0-9]'), '_')}_preview.pdf';
      final file = File(p.join(dir.path, filename));

      // Optional: Check if file already exists
      if (await file.exists()) {
        setState(() {
          _localPdfPath = file.path;
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        setState(() {
          _localPdfPath = file.path;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookTitle),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: () {
              _pdfViewerController?.firstPage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              _pdfViewerController?.previousPage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              _pdfViewerController?.nextPage();
            },
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: () {
              _pdfViewerController?.lastPage();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error: $_errorMessage'),
          ))
          : widget.pdfUrl.isNotEmpty
          ? SfPdfViewer.network(
        widget.pdfUrl,
        key: _pdfViewerKey,
        controller: _pdfViewerController,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          setState(() {
            _errorMessage = "Failed to load PDF: ${details.description}";
          });
          print("PDF Load Failed: ${details.error} - ${details.description}");
        },
        // You can customize further with other parameters like:
        // canShowScrollHead: true,
        // canShowScrollStatus: true,
        // pageLayoutMode: PdfPageLayoutMode.single,
      )
      // If you were using _localPdfPath for cached files:
      // : _localPdfPath != null
      //     ? SfPdfViewer.file(
      //         File(_localPdfPath!), // Make sure to handle File object
      //         key: _pdfViewerKey,
      //         controller: _pdfViewerController,
      //         onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
      //            setState(() {
      //              _errorMessage = "Failed to load PDF: ${details.description}";
      //            });
      //         },
      //       )
          : const Center(child: Text('PDF URL is not available.')),
    );
  }
}