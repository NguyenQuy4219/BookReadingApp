import 'package:flutter/material.dart';
import '../../models/book.dart';
import '../screen.dart';

class BookManager with ChangeNotifier {
  final BookService _bookService = BookService();
  List<Book> _books = [];

  List<Book> get books => [..._books];

  Future<void> fetchBooks() async {
    await _bookService.fetchBooks();
    _books = _bookService.books;
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    await _bookService.addBook(book);
    _books = _bookService.books;
    notifyListeners();
  }

  Future<void> deleteBook(String bookId) async {
    await _bookService.deleteBook(bookId);
    _books.removeWhere((book) => book.id == bookId);
    notifyListeners();
  }
}
