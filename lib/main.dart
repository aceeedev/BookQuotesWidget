import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_quotes/app.dart';
import 'package:book_quotes/providers/books.dart';


void main() {
  return runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BooksInformation()),
      ],
      child: const MaterialApp(
        home: MyApp(),
        debugShowCheckedModeBanner: false,
      ),
    ),
  );
}
