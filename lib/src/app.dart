import 'package:flutter/material.dart';
import 'package:leanflutter/src/pages/splash/splash_page.dart';
// import 'pages/auth/auth_check_page.dart';
import 'themes/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.mainTheme,
      home: SplashPage(),   // ← จุดเริ่มใหม่
    );
  }
}
