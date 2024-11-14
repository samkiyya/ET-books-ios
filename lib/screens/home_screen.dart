import 'package:book/constants/styles.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:book/constants/constants.dart';
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> trendingBooks = [];
  List<dynamic> allBooks = [];
  List<dynamic> audioBooks = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final trendingResponse = await http.get(Uri.parse("https://bookbackend3.bruktiethiotour.com/api/book/last7days"));
      final allBooksResponse = await http.get(Uri.parse("https://bookbackend3.bruktiethiotour.com/api/book/get-all"));
      final audioResponse = await http.get(Uri.parse("https://bookbackend3.bruktiethiotour.com/api/book/audio"));

      if (trendingResponse.statusCode == 200 &&
          allBooksResponse.statusCode == 200 &&
          audioResponse.statusCode == 200) {

        setState(() {
          trendingBooks = jsonDecode(trendingResponse.body)['books'];
          allBooks = jsonDecode(allBooksResponse.body);
          audioBooks = jsonDecode(audioResponse.body);
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: AppColors.color1,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : hasError
              ? Center(child: Text("An error occurred. Please try again."))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trending Books - Horizontal Scroll
                        Text(
                          "Trending Books",
                           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: AppColors.color3),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: trendingBooks.length,
                            itemBuilder: (context, index) {
                              final book = trendingBooks[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsScreen(book: book),
                                  ),
                                ),
                                child: Card(
                                  child: Container(
                                    width: 150,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Image.network(
                                          Network.baseUrl+'/${book['imageFilePath']}',
                                          fit: BoxFit.cover,
                                          height: 100,
                                          width: 150,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(book['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                                              Text("Price: ${book['price']}"),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20),

                        // All Books - Vertical Scroll
                        Text(
                          "All Books",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: AppColors.color3),
                        ),
                        SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: allBooks.length,
                          itemBuilder: (context, index) {
                            final book = allBooks[index];
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsScreen(book: book),
                                ),
                              ),
                              child: Card(
                                color: AppColors.color2,
                                child: ListTile(
                                  leading: Image.network(
                                    'https://bookbackend3.bruktiethiotour.com/${book['imageFilePath']}',
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  ),
                                  title: Text(book['title'],style: TextStyle(color: AppColors.color3),),
                                  subtitle: Text("Price: ${book['price']}"),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),

                        // Audio Books - Horizontal Scroll
                        Text(
                          "Audio Books",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,color: AppColors.color3),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: audioBooks.length,
                            itemBuilder: (context, index) {
                              final audio = audioBooks[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailsScreen(book: audio),
                                  ),
                                ),
                                child: Card(
                                  child: Container(
                                    width: 200,
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(audio['bookTitle'], style: TextStyle(fontWeight: FontWeight.bold)),
                                        Text(audio['episode']),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  DetailsScreen({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network('https://bookbackend3.bruktiethiotour.com/${book['imageFilePath']}'),
            SizedBox(height: 10),
            Text(
              book['title'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text("Price: ${book['price']}"),
            SizedBox(height: 10),
            Text(book['description'] ?? "No description available"),
          ],
        ),
      ),
    );
  }
}
