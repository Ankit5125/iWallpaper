import 'package:flutter/material.dart';
import 'package:iwallpaper/wallpaper.dart';

void main() => runApp(myApp());

class myApp extends StatelessWidget {
  const myApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: WallpaperScreen(),
    );
  }
}
