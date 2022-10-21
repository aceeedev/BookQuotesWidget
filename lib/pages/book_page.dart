import 'package:flutter/material.dart';
import 'package:book_quotes/models/book.dart';
import 'package:book_quotes/backend/database_helpers.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key, required this.book});
  final Book book;

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  late List<String> quotes;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    getQuotesFromDB();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future getQuotesFromDB() async {
    setState(() => isLoading = true);

    if (widget.book.quotes == null) {
      quotes = await AppDatabase.instance.readAllQuotes(widget.book.id!);
    } else {
      quotes = widget.book.quotes!;
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.book.title), actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Book',
            onPressed: () => showDeleteDialog(),
          ),
        ]),
        body: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      Image.network(
                        widget.book.coverUrl,
                      ),
                      Text(
                        widget.book.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          'By: ${widget.book.author}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: quotes.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(quotes[index]),
                              );
                            }),
                      ),
                    ],
                  )));
  }


  void showDeleteDialog() => showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Confirm delete'),
          content: const Text('Are you sure you want to delete this book? You can always readd the book but you will lose any customizations you added.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                AppDatabase.instance.deleteQuotes(widget.book.id!);
                AppDatabase.instance.deleteBook(widget.book.id!);

                Navigator.pop(context, 'OK');
              },
              child: const Text('Delete'),
            ),
          ],
        ));
}