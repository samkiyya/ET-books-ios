import 'package:book_mobile/constants/size.dart';
import 'package:book_mobile/constants/styles.dart';
import 'package:flutter/material.dart';

class AuthorScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  const AuthorScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    double width = AppSizes.screenWidth(context);
    double height = AppSizes.screenHeight(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Authors", style: AppTextStyles.heading2),
          centerTitle: true,
          backgroundColor: AppColors.color1,
          foregroundColor: AppColors.color6,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(width * 0.0074),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.brown[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: height * 0.009),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Adane Birhanu Gasho",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: width * 0.0185,
                          color: Colors.brown,
                        ),
                      ),
                      Text(
                        "I love writing books and narrating them. Check out my books!",
                        style: TextStyle(fontSize: width * 0.0148),
                      ),
                      SizedBox(height: height * 0.0045),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("9 Books"),
                          const Text("4.56 Stars"),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown),
                            child: const Text("Follow"),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.0045),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              Image.network(book['imageFilePath']),
                              const Text("Book Title"),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
