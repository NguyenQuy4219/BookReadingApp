import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screen.dart';

class BookOverviewScreen extends StatefulWidget {
  static const routeName = '/books';

  const BookOverviewScreen({super.key});

  @override
  State<BookOverviewScreen> createState() => _BookOverviewScreenState();
}

class _BookOverviewScreenState extends State<BookOverviewScreen> {
  late Future<void> _fetchBooksFuture;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _fetchBooksFuture =
        Provider.of<BookManager>(context, listen: false).fetchBooks();
  }

  Future<void> _refreshBooks() async {
    setState(() {
      _fetchBooksFuture =
          Provider.of<BookManager>(context, listen: false).fetchBooks();
    });
    await _fetchBooksFuture;
  }

  @override
  Widget build(BuildContext context) {
    final bookManager = Provider.of<BookManager>(context);
    final filteredBooks = bookManager.books
        .where((book) =>
            book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            book.authorName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 My Library',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor:
            _isDarkMode ? Colors.brown[900] : Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Provider.of<AuthManager>(context, listen: false).logout(context);
            },
          ),
        ],
      ),
      backgroundColor: _isDarkMode ? Colors.brown[800] : Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Search your books...',
                filled: true,
                fillColor: _isDarkMode ? Colors.brown[700] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Card(
                    color: _isDarkMode ? Colors.brown[700] : Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: book.bookCover.isNotEmpty
                            ? Image.network(
                                "http://10.0.2.2:8090/api/files/books/${book.id}/${book.bookCover}",
                                width: 60,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.menu_book,
                                size: 60, color: Colors.grey),
                      ),
                      title: Text(book.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text("By: ${book.authorName}",
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            color: Colors.grey),
                        onPressed: () {
                          Navigator.push(context,
                              FadePageRoute(page: BookDetailPage(book: book)));
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, FadePageRoute(page: const AddBookPage()))
              .then((_) => _refreshBooks());
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Book"),
        backgroundColor:
            _isDarkMode ? Colors.brown[700] : Colors.deepPurpleAccent,
      ),
    );
  }
}
