import 'package:flutter/material.dart';
import 'package:book_quotes/models/book.dart';

class BooksInformation with ChangeNotifier{
  List<Book> _books = [];
  List<String> _quotes = [];

  List<Book> get books => _books;
  List<String> get quotes => _quotes;

  void setBooks(List<Book> newBooks) {
    _books = newBooks;
    notifyListeners();
  }

  void deleteAllBooks() {
    _books = [];
    notifyListeners();
  }

  void setQuotes(List<String> newQuotes) {
    _quotes = newQuotes;
    notifyListeners();
  }
}