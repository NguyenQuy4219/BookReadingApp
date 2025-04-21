import 'package:flutter/material.dart';
import '/models/book.dart';
import '../screen.dart';

class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                FadePageRoute(page: AddBookPage(editBook: book)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  "http://10.0.2.2:8090/api/files/books/${book.id}/${book.bookCover}",
                  height: 250,
                  width: 170,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      size: 100,
                      color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailItem("Title", book.title),
            _buildDetailItem("Author", book.authorName),
            _buildDetailItem("Genre", book.genre),
            _buildDetailItem("Uploaded by", book.uploadedBy),
            const SizedBox(height: 20),
            Text("Description:", style: _sectionTitleStyle()),
            const SizedBox(height: 5),
            Text(book.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  String pdfUrl =
                      "http://10.0.2.2:8090/api/files/books/${book.id}/${book.bookFile}";
                  Navigator.push(
                    context,
                    SlidePageRoute(page: ReadingPage(bookFileUrl: pdfUrl)),
                  );
                },
                icon: const Icon(Icons.menu_book, color: Colors.white),
                label: const Text("Read Book",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _sectionTitleStyle()),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 10),
      ],
    );
  }

  TextStyle _sectionTitleStyle() {
    return const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurpleAccent);
  }
}
