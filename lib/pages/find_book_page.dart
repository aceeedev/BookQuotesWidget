import 'package:book_quotes/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_quotes/providers/books.dart';
import 'package:book_quotes/backend/database_helpers.dart';
import 'package:book_quotes/backend/books_api.dart';
import 'package:book_quotes/backend/web_scrapper.dart';
import 'package:book_quotes/models/book.dart';

class FindBookPage extends StatefulWidget {
  const FindBookPage({super.key});

  @override
  State<FindBookPage> createState() => _FindBookPageState();
}

class _FindBookPageState extends State<FindBookPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Book'),
      ),
      body: const SearchForBookForm(),
    );
  }
}

class SearchForBookForm extends StatefulWidget {
  const SearchForBookForm({super.key});

  @override
  State<SearchForBookForm> createState() => _SearchForBookFormState();
}

class _SearchForBookFormState extends State<SearchForBookForm> {
  final myController = TextEditingController();
  List<Text> listOfQuotes = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    myController.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: myController,
            ),
            IconButton(
              onPressed: () async {
                String textInput = myController.text.trim();
                if (textInput != "") {
                  List<Book> books = await getBooks(textInput);

                  // have to check if mounted to use context in an async function
                  if (!mounted) return;
                  context.read<BooksInformation>().setBooks(books);
                }
              }, 
              icon: const Icon(Icons.search),
            ),
            Expanded(
              child: context.watch<BooksInformation>().books.isNotEmpty ? GridView.builder(
                padding: const EdgeInsets.all(15.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                  childAspectRatio: 0.5
                ),
                itemCount: context.read<BooksInformation>().books.length,
                itemBuilder: (context, index) {
                  Book book = context.read<BooksInformation>().books[index];

                  return GestureDetector(
                    onTap: () async {
                      List<String> quotes = await getQuotesFromWeb(book.title);

                      if (quotes.isNotEmpty) {
                        Book dbBook = await AppDatabase.instance.createBook(book);
                        for (String quote in quotes) { 
                          await AppDatabase.instance.createQuote(dbBook.id!, quote);
                        }
                      }

                      if (!mounted) return; // needed bc of buildcontext is in async function
                      Navigator.of(context).pop();
                    },
                    child: Card(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(book.coverUrl),
                          const Spacer(),
                          Text(
                            book.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              'By: ${book.author}',
                              textAlign: TextAlign.center,
                              style:const TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ]
                      ),
                    ),
                  );
                },
              ) : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}