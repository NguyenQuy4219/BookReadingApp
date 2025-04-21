import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ReadingPage extends StatefulWidget {
  final String bookFileUrl; // PDF URL from PocketBase

  const ReadingPage({super.key, required this.bookFileUrl});

  @override
  _ReadingPageState createState() => _ReadingPageState();
}

class _ReadingPageState extends State<ReadingPage> {
  String? _localFilePath;
  bool _isLoading = true;
  int _currentPage = 0; // Tracks the current page
  int _totalPages = 1; // Total pages in the PDF

  @override
  void initState() {
    super.initState();
    _downloadPDF();
  }

  /// **Downloads the PDF file and saves it locally**
  Future<void> _downloadPDF() async {
    try {
      final response = await http.get(Uri.parse(widget.bookFileUrl));
      print("Downloading PDF from: ${widget.bookFileUrl}");
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File("${dir.path}/book.pdf");
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _localFilePath = file.path;
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load PDF file");
      }
    } catch (e) {
      print("Error downloading PDF: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reading Book")),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator()) // Show loading
              : _localFilePath == null
                  ? const Center(
                      child: Text("Failed to load book.")) // Show error message
                  : PDFView(
                      filePath: _localFilePath!,
                      enableSwipe: true,
                      swipeHorizontal: false,
                      autoSpacing: true,
                      pageSnap: true,
                      fitPolicy: FitPolicy.BOTH,
                      onRender: (pages) {
                        setState(() {
                          _totalPages = pages ?? 1;
                        });
                      },
                      onPageChanged: (page, _) {
                        setState(() {
                          _currentPage = page ?? 0;
                        });
                      },
                    ),
          if (!_isLoading && _localFilePath != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: _totalPages > 1 ? _currentPage / _totalPages : 0,
                    minHeight: 5,
                    color: Colors.blueAccent,
                    backgroundColor: Colors.grey[300],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Page ${_currentPage + 1} / $_totalPages",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
