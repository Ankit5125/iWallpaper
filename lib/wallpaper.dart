import 'dart:collection';
import 'dart:convert';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iwallpaper/fullScreen.dart';

class WallpaperScreen extends StatefulWidget {
  const WallpaperScreen({super.key});

  @override
  State<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends State<WallpaperScreen> {
  List images = [];
  List searchedImages = [];
  int page = 1;
  var controller = TextEditingController();
  bool isSearched = false;
  ScrollController scrollController = ScrollController();

  fetchApi() async {
    final response = await http.get(
      Uri.parse("https://api.pexels.com/v1/curated?per_page=80"),
      headers: {
        'Authorization':
            'ivooWpatdKijeKo9vxmOLxrvEu6HD4mmVJfuecjPnnq4PtZefgAcaSN5',
      },
    );

    if (response.statusCode == 200) {
      Map result = jsonDecode(response.body);
      setState(() {
        images = result['photos'];
      });
    } else {
      print("API Error: ${response.statusCode}");
      print("Body: ${response.body}");
    }
  }

  loadmore() async {
    setState(() {
      page++;
    });
    String url = "https://api.pexels.com/v1/curated?per_page=80&page=$page";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization':
            'ivooWpatdKijeKo9vxmOLxrvEu6HD4mmVJfuecjPnnq4PtZefgAcaSN5',
      },
    );

    if (response.statusCode == 200) {
      Map result = jsonDecode(response.body);
      setState(() {
        images.addAll(result['photos']);
      });
    } else {
      print("Load more failed with status: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

  searchImages(String query) async {
    query = query.replaceAll(" ", "%20");

    print("\n\n\n$query\n\n\n");

    final response = await http.get(
      Uri.parse("https://api.pexels.com/v1/search?per_page=80&query=$query"),
      headers: {
        'Authorization':
            'ivooWpatdKijeKo9vxmOLxrvEu6HD4mmVJfuecjPnnq4PtZefgAcaSN5',
      },
    );

    if (response.statusCode == 200) {
      Map result = jsonDecode(response.body);
      setState(() {
        searchedImages = [];
        searchedImages = result['photos'];
      });
    } else {
      print("API Error: ${response.statusCode}");
      print("Body: ${response.body}");
    }
  }

  @override
  void initState() {
    fetchApi();
    super.initState();
  }

  final options = LiveOptions(
    delay: Duration(milliseconds: 500),
    showItemInterval: Duration(milliseconds: 500),
    showItemDuration: Duration(seconds: 1),
    visibleFraction: 0.05,
    reAnimateOnVisibility: false,
  );

  Widget buildAnimatedItem(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) => FadeTransition(
    opacity: Tween<double>(begin: 0, end: 1).animate(animation),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, -0.1),
        end: Offset.zero,
      ).animate(animation),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => Fullscreen(
                    imgURL:
                        isSearched
                            ? searchedImages[index]['src']['large2x']
                            : images[index]['src']['large2x'],
                  ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.network(
            isSearched
                ? searchedImages[index]['src']['tiny']
                : images[index]['src']['tiny'],
            fit: BoxFit.cover,
          ),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  child: LiveGrid.options(
                    controller: scrollController,
                    options: options,
                    itemBuilder: buildAnimatedItem,
                    itemCount:
                        isSearched ? searchedImages.length : images.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      childAspectRatio: 2 / 3,
                      mainAxisSpacing: 6,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => loadmore(),
                child: Container(
                  height: 55,
                  width: double.infinity,
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      'Load More',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 30,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: AnimSearchBar(
                width: MediaQuery.of(context).size.width - 20,
                helpText: "Search Here",
                rtl: true,
                textController: controller,
                onSuffixTap: () {
                  setState(() {
                    controller.clear();
                    isSearched = false;
                  });
                },
                onSubmitted: (query) {
                  searchImages(query);
                  scrollController.animateTo(
                    0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                  setState(() {
                    isSearched = true;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
