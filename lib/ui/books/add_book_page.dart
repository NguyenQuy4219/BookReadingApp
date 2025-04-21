import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '/models/book.dart';
import '../screen.dart';

class AddBookPage extends StatefulWidget {
  final Book? editBook;

  const AddBookPage({super.key, this.editBook});

  @override
  _AddBookPageState createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _authorName;
  late String _description;
  String? _selectedGenre;
  File? _bookFile;
  File? _bookCover;

  final List<String> _genres = [
    'Fiction',
    'Mystery',
    'Science Fiction',
    'Fantasy',
    'Non-Fiction',
    'Comedy'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editBook != null) {
      _title = widget.editBook!.title;
      _authorName = widget.editBook!.authorName;
      _description = widget.editBook!.description;
      _selectedGenre = widget.editBook!.genre;
    } else {
      _title = '';
      _authorName = '';
      _description = '';
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() => _bookFile = File(result.files.single.path!));
    }
  }

  Future<void> _pickImage() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() => _bookCover = File(result.files.single.path!));
    }
  }

  Future<void> _saveBook() async {
    if (!_formKey.currentState!.validate() || _selectedGenre == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields!')),
      );
      return;
    }

    _formKey.currentState!.save();
    final authManager = Provider.of<AuthManager>(context, listen: false);
    final user = authManager.user;

    if (user == null || user.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated. Please log in.')),
      );
      return;
    }

    final bookService = Provider.of<BookService>(context, listen: false);
    try {
      if (widget.editBook != null) {
        final updatedBook = widget.editBook!.copyWith(
          title: _title,
          authorName: _authorName,
          description: _description,
          genre: _selectedGenre!,
          bookCover: _bookCover?.path ?? widget.editBook!.bookCover,
          bookFile: _bookFile?.path ?? widget.editBook!.bookFile,
        );
        await bookService.updateBook(updatedBook);
      } else {
        final newBook = Book(
          id: '',
          title: _title,
          authorName: _authorName,
          description: _description,
          genre: _selectedGenre!,
          bookCover: _bookCover?.path ?? '',
          bookFile: _bookFile?.path ?? '',
          uploadedBy: user.id,
        );
        await bookService.addBook(newBook);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.editBook != null
              ? 'Book updated successfully!'
              : 'Book added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.editBook != null ? 'Edit Book' : 'Add Book')),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.lightBlue[50],
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _buildInputBox(
                            child: TextFormField(
                              initialValue: _title,
                              decoration:
                                  const InputDecoration(labelText: 'Title'),
                              validator: (value) =>
                                  value!.isEmpty ? 'Enter a title' : null,
                              onSaved: (value) => _title = value!,
                            ),
                          ),
                          _buildInputBox(
                            child: TextFormField(
                              initialValue: _authorName,
                              decoration: const InputDecoration(
                                  labelText: 'Author Name'),
                              validator: (value) =>
                                  value!.isEmpty ? 'Enter author name' : null,
                              onSaved: (value) => _authorName = value!,
                            ),
                          ),
                          _buildInputBox(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                  labelText: 'Select Genre'),
                              value: _selectedGenre,
                              items: _genres
                                  .map((genre) => DropdownMenuItem(
                                        value: genre,
                                        child: Text(genre),
                                      ))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedGenre = value),
                              validator: (value) => value == null
                                  ? 'Please select a genre'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 180,
                      height: 220,
                      margin: const EdgeInsets.only(left: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _bookCover != null
                          ? Image.file(_bookCover!, fit: BoxFit.cover)
                          : const Icon(Icons.image,
                              size: 80, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildLargeInputBox(
                child: TextFormField(
                  initialValue: _description,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a description' : null,
                  onSaved: (value) => _description = value!,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image, size: 18),
                    label: const Text("Pick Cover",
                        style: TextStyle(fontSize: 12)),
                    onPressed: _pickImage,
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.file_upload, size: 18),
                    label: Text(
                        _bookFile == null ? 'Pick PDF File' : 'PDF Selected'),
                    onPressed: _pickFile,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveBook,
                child:
                    Text(widget.editBook != null ? 'Update Book' : 'Save Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputBox({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueAccent, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildLargeInputBox({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueAccent, width: 1),
      ),
      child: child,
    );
  }
}
