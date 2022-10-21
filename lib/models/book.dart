const String tableBooks = 'books';

class BookFields {
  static final List<String> values = [
    id, 
    isbn, 
    title, 
    author, 
    coverUrl, 
    quotes, 
  ];

  static const String id = '_id';
  static const String isbn = 'isbn';
  static const String title ='title';
  static const String author = 'author';
  static const String coverUrl = 'coverUrl';
  static const String quotes = 'quotes';
}

class Book {
  final int? id;
  final String isbn;
  final String title;
  final String author;
  final String coverUrl;
  final List<String>? quotes;

  const Book({
    this.id,
    required this.isbn,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.quotes,
  });

  Book copy({
    int? id,
    String? isbn,
    String? title,
    String? author,
    String? coverUrl,
    List<String>? quotes,
  }) =>
    Book(
      id: id ?? this.id,
      isbn: isbn ?? this.isbn,
      title: title ?? this.title,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      quotes: quotes ?? this.quotes,
    );

  Map<String, Object?> toJson() => {
    BookFields.id: id,
    BookFields.isbn: isbn,
    BookFields.title: title,
    BookFields.author: author,
    BookFields.coverUrl: coverUrl
  };

  /// use when json is from sql db
  static Book fromJson(Map<String, Object?> json) => Book(
    id: json[BookFields.id] as int?,
    isbn: json[BookFields.isbn] as String,
    title: json[BookFields.title] as String,
    author: json[BookFields.author] as String,
    coverUrl: json[BookFields.coverUrl] as String,
    quotes: null,
  );

  /// used when json is from open library api
  static Book fromJsonApi(Map<String, dynamic> json) => Book(
    id: null,
    isbn: json['isbn'].first,
    title: json['title'],
    author: json['author_name'].first,
    coverUrl: 'https://covers.openlibrary.org/b/ID/${json['cover_i']}-M.jpg',
    quotes: [],
  );
}