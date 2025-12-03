import 'package:flutter/material.dart';
import 'login_controller.dart';
import 'login_widgets.dart';
import 'login_background.dart';
import 'login_success_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late LoginController controller;

  @override
  void initState() {
    super.initState();
    controller = LoginController(vsync: this);
    controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: controller.animController,
        builder: (_, __) {
          return Stack(
            children: [

              // 🟡 Background animation must be FIRST
              LoginBackground(
                animationValue: controller.animationValue,
                glowValue: controller.glowValue,
              ),

              // 🟡 Body UI
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: LoginBody(controller: controller),
                ),
              ),

              // 🟡 Loading overlay
              if (controller.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFFFFD700)),
                    ),
                  ),
                ),

              // 🟢 Success overlay
              if (controller.showSuccess)
                const LoginSuccessOverlay(),
            ],
          );
        },
      ),
    );
  }
}
