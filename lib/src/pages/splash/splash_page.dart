import 'dart:math';
import 'package:flutter/material.dart';
import 'package:leanflutter/src/pages/login/login_page.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _rotateY;
  late Animation<double> _scale;

  String fullText = "Bangkokthonburi University";
  String displayText = "";
  int textIndex = 0;

  @override
  void initState() {
    super.initState();

    // Animation Controller (logo)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // 3D Rotation
    _rotateY = Tween<double>(begin: 0, end: pi * 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Scale (zoom)
    _scale = Tween<double>(begin: 0.7, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Start typewriter after 1 second
    Future.delayed(const Duration(milliseconds: 800), () {
      startTyping();
    });

    // To HomePage
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    });
  }

  // Typewriter function
  void startTyping() async {
    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 100)); // ความเร็วตัวอักษร
      setState(() {
        displayText += fullText[i];
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(228, 187, 29, 29),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Logo 3D
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateY(_rotateY.value),
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Image.asset(
                      'assets/images/btu.png',
                      width: 160,
                      height: 160,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Typewriter Text
                Text(
                  displayText,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Color(0xFFFFD700), // Gold
                    fontWeight: FontWeight.bold,
                    fontFamily: "Lobster",
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
