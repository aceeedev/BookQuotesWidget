import 'package:book_quotes/pages/book_page.dart';
import 'package:flutter/material.dart';
import 'package:book_quotes/pages/find_book_page.dart';
import 'package:book_quotes/models/book.dart';
import 'package:book_quotes/backend/database_helpers.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late List<Book> books;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshBooks();
  }

  @override
  void dispose() {
    AppDatabase.instance.close();

    super.dispose();
  }

  Future refreshBooks() async {
    setState(() => isLoading = true);

    this.books = await AppDatabase.instance.readAllBooks();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : books.isEmpty
                ? const Text(
                    'No Books',
                  )
                : buildBooks(),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const FindBookPage(),
            ));

            refreshBooks();
          }),
    );
  }

  Widget buildBooks() => GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5.0,
          mainAxisSpacing: 5.0,
          childAspectRatio: 0.5),
      itemCount: books.length,
      itemBuilder: (context, index) {
        Book book = books[index];

        return Card(
          child: GestureDetector(
            onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => BookPage(book: book),
                ));

            refreshBooks();
            },
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Image.network(
                book.coverUrl,
              ),
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
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ]),
          ),
        );
      });
}
