import 'package:flutter/material.dart';
import 'themes/app_theme.dart';
import 'pages/splash/splash_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lean Flutter',
      theme: AppTheme.mainTheme,
      home: const SplashPage(),
    );
  }
}
