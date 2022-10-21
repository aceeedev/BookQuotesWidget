import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

Future<List<String>> getQuotesFromWeb(String title) async {
  String formattedtitle = title.toLowerCase().replaceAll(' ', '+');

  var response = await http.Client().get(Uri.parse('https://www.goodreads.com/quotes/search?commit=Search&page=1&q=$formattedtitle&utf8=%E2%9C%93'));

  if (response.statusCode == 200) {
    var document = parser.parse(response.body);
    try {
      // find last page number
      List<String> a = document.getElementsByTagName('a').map((e) => e.text).toList();

      int lastPageAIndex = a.indexOf('next »') - 1;
      int lastPageNum = int.parse(a[lastPageAIndex]);

      // get quotes on first page
      List<String> quotes = document.getElementsByClassName('quoteText').map((e) => e.text.substring(0, e.text.indexOf('”') + 1)).toList();
      quotes.removeWhere((element) => element == null);

      // get all remaining quotes
      for (var i = 2, continueIterating = true; i < lastPageNum && continueIterating; i++) {
        // get html of next page
        try {
          response = await http.Client().get(Uri.parse('https://www.goodreads.com/quotes/search?commit=Search&page=$i&q=$formattedtitle&utf8=%E2%9C%93'));
          var document = parser.parse(response.body);
          
          List<String> quotesToBeAdded = document.getElementsByClassName('quoteText').map((e) {
            if (e.getElementsByClassName('authorOrTitle').length > 1 && e.getElementsByClassName('authorOrTitle')[1].text.toLowerCase().compareTo(title.toLowerCase()) == 0) {
              return e.text.substring(0, e.text.indexOf('”') + 1);
            }
            return "";
          }).toList();

          quotesToBeAdded.removeWhere((element) => element.compareTo("") == 0);

          if (quotesToBeAdded.length + quotes.length > 100) {
            quotesToBeAdded = quotesToBeAdded.sublist(0, 100 - quotes.length);
          }

          quotes.addAll(quotesToBeAdded);

          if (quotes.length == 100) {
            continueIterating = false;
          }
        } catch (e) {
          // error occurred
          print(e);
        }
      }

      return quotes;
    } catch(e) {
      // error occurred
      print(e);
    }
  } else {
    // error occurred
    throw Exception('Status code is ${response.statusCode}');
  }

  // error occurred
  throw Exception('Something went wrong');
}