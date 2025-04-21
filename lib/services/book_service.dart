import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/book.dart';
import '/services/pocketbase_client.dart';
import 'package:http/http.dart' as http;

class BookService with ChangeNotifier {
  PocketBase? _pb;
  List<Book> _books = [];

  List<Book> get books => [..._books];

  Future<void> _initPocketBase() async {
    _pb = await getPocketbaseInstance();
  }

  Future<void> fetchBooks() async {
    try {
      if (_pb == null) await _initPocketBase();
      final records = await _pb!.collection('books').getFullList();
      _books = records.map((e) => Book.fromJson(e.data)).toList();
      notifyListeners();
    } catch (e) {
      print("Error fetching books: $e");
    }
  }

  Future<void> addBook(Book book) async {
    try {
      if (_pb == null) await _initPocketBase();
      if (!_pb!.authStore.isValid) {
        throw Exception("User is not authenticated.");
      }

      final user = _pb!.authStore.model;
      final userId = user?.id ?? "";

      if (userId.isEmpty) {
        throw Exception("User ID is missing.");
      }

      // Validate genre
      final validGenres = [
        "Fiction",
        "Mystery",
        "Science Fiction",
        "Fantasy",
        "Non-Fiction",
        "Comedy"
      ];
      if (!validGenres.contains(book.genre)) {
        throw Exception("Invalid genre. Must be one of: $validGenres");
      }

      // Prepare form data
      final formData = <String, dynamic>{
        "name": book.title,
        "author_name": book.authorName,
        "genre": book.genre,
        "description": book.description,
      };

      // Convert File to MultipartFile
      List<http.MultipartFile> files = [];

      if (book.bookCover.isNotEmpty && File(book.bookCover).existsSync()) {
        files.add(
          await http.MultipartFile.fromPath("book_cover", book.bookCover),
        );
      }

      if (book.bookFile.isNotEmpty && File(book.bookFile).existsSync()) {
        files.add(
          await http.MultipartFile.fromPath("book_files", book.bookFile),
        );
      }

      // Upload book to PocketBase
      final response = await _pb!.collection('books').create(
            body: formData,
            files: files,
          );

      if (response.id.isEmpty) {
        throw Exception("Failed to add book to PocketBase.");
      }

      _books.add(Book.fromJson(response.data));
      notifyListeners();
      print("Book added successfully!");
    } catch (e) {
      print("Error adding book: $e");
      throw e;
    }
  }

  /// **Delete a book from PocketBase**
  Future<void> deleteBook(String bookId) async {
    try {
      if (_pb == null) await _initPocketBase();
      await _pb!.collection('books').delete(bookId);

      // Remove book locally
      _books.removeWhere((book) => book.id == bookId);
      notifyListeners();

      print("Book deleted successfully!");
    } catch (e) {
      print("Error deleting book: $e");
      throw e;
    }
  }

  /// **Update book details in PocketBase**
  Future<void> updateBook(Book book) async {
    try {
      if (_pb == null) await _initPocketBase();
      if (!_pb!.authStore.isValid) {
        throw Exception("User is not authenticated.");
      }

      // Prepare updated data
      final updatedData = <String, dynamic>{
        "name": book.title,
        "author_name": book.authorName,
        "genre": book.genre,
        "description": book.description,
      };

      List<http.MultipartFile> files = [];

      if (book.bookCover.isNotEmpty && File(book.bookCover).existsSync()) {
        files.add(
          await http.MultipartFile.fromPath("book_cover", book.bookCover),
        );
      }

      if (book.bookFile.isNotEmpty && File(book.bookFile).existsSync()) {
        files.add(
          await http.MultipartFile.fromPath("book_files", book.bookFile),
        );
      }

      // Update book in PocketBase
      final response = await _pb!.collection('books').update(
            book.id,
            body: updatedData,
            files: files,
          );

      // Update local list
      int index = _books.indexWhere((b) => b.id == book.id);
      if (index != -1) {
        _books[index] = Book.fromJson(response.data);
        notifyListeners();
      }

      print("Book updated successfully!");
    } catch (e) {
      print("Error updating book: $e");
      throw e;
    }
  }
}
