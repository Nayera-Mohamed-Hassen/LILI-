import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:gif/gif.dart';

class RecipeLoading extends StatelessWidget {
  const RecipeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: Center(
          // Center the entire body
          child: Loading1(),
        ),
      ),
    );
  }
}

class Loading1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 390,
        height: 844,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: const Color(0xFFF5EFE7)),
        child: Stack(
          children: [
            // Background circles
            Positioned(
              left: 15,
              top: 242,
              child: Container(
                width: 360,
                height: 360,
                decoration: ShapeDecoration(
                  color: const Color(0xFF1D2345),
                  shape: OvalBorder(),
                ),
              ),
            ),
            Positioned(
              left: 25,
              top: 252,
              child: Container(
                width: 340,
                height: 340,
                decoration: ShapeDecoration(
                  color: const Color(0xFF213555),
                  shape: OvalBorder(),
                ),
              ),
            ),
            Positioned(
              left: 40,
              top: 267,
              child: Container(
                width: 310,
                height: 310,
                decoration: ShapeDecoration(
                  color: const Color(0xFF3E5879),
                  shape: OvalBorder(),
                ),
              ),
            ),
            Positioned(
              left: 60,
              top: 287,
              child: Container(
                width: 270,
                height: 270,
                decoration: ShapeDecoration(
                  color: const Color(0xFF5F738D),
                  shape: OvalBorder(),
                ),
              ),
            ),
            // Fire GIF (without animation interference)
            Positioned(
              left: 90,
              top: 255,
              child: GifView.asset(
                'assets/images/fire.gif',
                height: 200,
                width: 200,
                frameRate: 30,
              ),
            ),
            // Cooking GIF (without animation interference)
            Positioned(
              left: 126,
              top: 319,

              child: Gif(
                fit: BoxFit.cover,
                autostart: Autostart.loop,
                width: 150,
                height: 150,
                fps: 30,
                image: AssetImage('assets/images/cooking.gif'),
              ),
            ),
            // Centered Text
            Positioned(
              left: 69 + 50,
              top: 455, // Adjusted for the positioning of the fire GIF
              child: SizedBox(
                width: 140,
                height: 140,
                child: Text(
                  'loading recipe...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFF5EFE7),
                    fontSize: 35,
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.w400,
                    height: 1.20,
                  ),
                ),
              ),
            ),
            /**** not needed but don't remove it as it affects the GIF ****/
            Visibility(
              visible: false,
              child: Positioned(
                left: 100,
                top: 20,
                child: GifView.asset(
                  'assets/images/fire.gif',
                  height: 200,
                  width: 200,
                  frameRate: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
