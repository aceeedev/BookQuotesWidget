import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:book_quotes/models/book.dart';

Future<List<Book>> getBooks(String title) async {
  String formattedtitle = title.toLowerCase().replaceAll(' ', '+');

  var response = await http.Client().get(Uri.parse('https://openlibrary.org/search.json?title=$formattedtitle'));

  if (response.statusCode == 200) {
    Map<String, dynamic> json = jsonDecode(response.body);

    if (json['error'] != null) {
      throw Exception('Error: ${json['error']}');
    }

    List<dynamic> booksJson = json['docs'];
    List<Book> books = [];
    for (var book in booksJson) {
      if (book['isbn'] != null && book['author_name'] != null && book['id_goodreads'] != null && book['cover_i'] != null) books.add(Book.fromJsonApi(book));
    }

    return books;
  } else {
    throw Exception('Response code was not 200, was ${response.statusCode}');
  }
}