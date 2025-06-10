import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

class Fullscreen extends StatefulWidget {
  final String imgURL;
  const Fullscreen({required this.imgURL, super.key});

  @override
  State<Fullscreen> createState() => _FullscreenState();
}

class _FullscreenState extends State<Fullscreen> {
  var wallpaperManager = WallpaperManagerFlutter();

  Future<void> setWallpaper() async {
    var file = await DefaultCacheManager().getSingleFile(widget.imgURL);
    // ignore: unused_local_variable
    bool result = await wallpaperManager.setWallpaper(
      file,
      WallpaperManagerFlutter.homeScreen,
    );

    if (result) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Wallpaper Set Succefull")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error! Please Try Again")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: Image.network(widget.imgURL, fit: BoxFit.fitHeight),
            ),
          ),
          GestureDetector(
            onTap: setWallpaper,
            child: Container(
              height: 60,
              width: double.infinity,
              color: Colors.black,
              child: Center(
                child: Text(
                  'Set Wallpaper',
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
    );
  }
}
