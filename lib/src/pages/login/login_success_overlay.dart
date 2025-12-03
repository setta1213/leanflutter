import 'package:flutter/material.dart';

class LoginSuccessOverlay extends StatelessWidget {
  const LoginSuccessOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.7),
        child: const Center(
          child: Icon(
            Icons.check_circle,
            color: Colors.greenAccent,
            size: 100,
          ),
        ),
      ),
    );
  }
}
