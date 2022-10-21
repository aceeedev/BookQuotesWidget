import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:book_quotes/models/book.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('book_quotes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const boolType = 'BOOLEAN NOT NULL';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    // create book table
    await db.execute('''
CREATE TABLE $tableBooks (
  ${BookFields.id} $idType,
  ${BookFields.isbn} $textType,
  ${BookFields.title} $textType,
  ${BookFields.author} $textType,
  ${BookFields.coverUrl} $textType
  )
''');

    // create quote table
    await db.execute('''
CREATE TABLE quotes (
  _id $idType,
  bookId $integerType,
  quote $textType
  )
''');
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

  // book db functions
  Future<Book> createBook(Book book) async {
    final db = await instance.database;

    final id = await db.insert(tableBooks, book.toJson());
    return book.copy(id: id);
  }

  Future<Book> readBook(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableBooks,
      columns: BookFields.values,
      where: '${BookFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      Book book = Book.fromJson(maps.first);
      List<String> quotes = readAllQuotes(book.id!) as List<String>;
      book = book.copy(quotes: quotes);

      return book;
    } else {
      throw Exception('ID $id not found');
    }
  }

  /// Returns a list of all the books in the database
  Future<List<Book>> readAllBooks() async {
    final db = await instance.database;

    String orderBy = '${BookFields.id} ASC';
    final result = await db.query(tableBooks, orderBy: orderBy);

    return result.map((json) => Book.fromJson(json)).toList();
  }

  Future<int> updateBook(Book book) async {
    final db = await instance.database;

    return db.update(
      tableBooks,
      book.toJson(),
      where: '${BookFields.id} = ?',
      whereArgs: [book.id],
    );
  }

  Future<int> deleteBook(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableBooks,
      where: '${BookFields.id} = ?',
      whereArgs: [id],
    );
  }

  // quote db functions

  Future<String> createQuote(int bookId, String quote) async {
    final db = await instance.database;

    await db.insert('quotes', {
      'bookId': bookId,
      'quote': quote,
    });
    return quote;
  }

  Future<int> deleteQuotes(int bookId) async {
    final db = await instance.database;

    return await db.delete(
      'quotes',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );
  }

  /// Returns a list of all the quotes from an bookID in the database
  Future<List<String>> readAllQuotes(int bookId) async {
    final db = await instance.database;

    final result = await db.query(
      'quotes',
      where: 'bookId = ?',
      whereArgs: [bookId],
    );

    if (result.isNotEmpty) {
      return result.map((json) => json['quote'] as String).toList();
    } else {
      throw Exception('ID $bookId not found');
    }
  }
}
