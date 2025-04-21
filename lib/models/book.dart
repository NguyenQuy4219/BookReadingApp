class Book {
  final String id;
  final String title;
  final String authorName;
  final String bookCover;
  final String bookFile;
  final String uploadedBy;
  final String genre;
  final String description;

  Book({
    required this.id,
    required this.title,
    required this.authorName,
    required this.bookCover,
    required this.bookFile,
    required this.uploadedBy,
    required this.genre,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": title,
      "author_name": authorName,
      "book_cover": bookCover,
      "book_files": bookFile,
      "uploaded_by": uploadedBy,
      "genre": genre,
      "description": description,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['name'] ?? '',
      authorName: json['author_name'] ?? '',
      bookCover: json['book_cover'] ?? '',
      bookFile: json['book_files'] ?? '',
      uploadedBy: json['uploaded_by'] ?? '',
      genre: json['genre'] ?? '',
      description: json['description'] ?? '',
    );
  }
  Book copyWith({
    String? id,
    String? title,
    String? authorName,
    String? bookCover,
    String? bookFile,
    String? uploadedBy,
    String? genre,
    String? description,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      authorName: authorName ?? this.authorName,
      bookCover: bookCover ?? this.bookCover,
      bookFile: bookFile ?? this.bookFile,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      genre: genre ?? this.genre,
      description: description ?? this.description,
    );
  }
}
