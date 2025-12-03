import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_controller.dart';

class LoginBody extends StatelessWidget {
  final LoginController controller;
  const LoginBody({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Transform.translate(
          offset: Offset(0, controller.slide.value * 1.2),
          child: Opacity(
            opacity: controller.fade.value,
            child: Image.asset(
              "assets/images/btu.png",
              width: 140,
              height: 140,
            ),
          ),
        ),

        const SizedBox(height: 30),

        Text(
          "เข้าสู่ระบบ",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFD700),
            shadows: [
              Shadow(
                blurRadius: 20,
                color: const Color(0xFFFFD700).withOpacity(0.6),
              )
            ],
          ),
        ),

        const SizedBox(height: 40),

        _field(controller, "Username", Icons.person_outline, false,),
        const SizedBox(height: 20),
        _field(controller, "Password", Icons.lock_outline, true),

        const SizedBox(height: 40),

        _button(context, controller),
      ],
    );
  }
}

Widget _field(LoginController c, String label, IconData icon, bool pass) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    margin: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.03),
          Colors.white.withOpacity(0.01),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 25,
          spreadRadius: 0,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.white.withOpacity(0.05),
          blurRadius: 2,
          spreadRadius: 0,
          offset: const Offset(0, 1),
        ),
      ],
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
    ),
    child: Focus(
      onFocusChange: (hasFocus) {
        // You can add focus animation logic here
      },
      child: TextField(
        controller: pass ? c.passCtrl : c.userCtrl,
        obscureText: pass ? c.obscure : false,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: const Color(0xFFFFD700),
        cursorWidth: 2.5,
        cursorRadius: const Radius.circular(2),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.transparent,
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          floatingLabelStyle: GoogleFonts.poppins(
            color: const Color(0xFFFFD700),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFFEC8B),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(
                icon,
                color: Colors.black87,
                size: 20,
              ),
            ),
          ),
          suffixIcon: pass
              ? Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: IconButton(
                      onPressed: () {
                        // c.togglePasswordVisibility();
                      },
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          c.obscure
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          key: ValueKey<bool>(c.obscure),
                          color: Colors.white70,
                          size: 22,
                        ),
                      ),
                      splashRadius: 20,
                      hoverColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Color(0xFFFFD700),
              width: 2.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 10,
          ),
          // Floating label transformation
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          // Add subtle hint text
          hintText: 'Type here...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.25),
            fontSize: 14,
          ),
        ),
      ),
    ),
  );
}

Widget _button(BuildContext context, LoginController c) {
  return Material(
    elevation: 8,
    borderRadius: BorderRadius.circular(30),
    color: Colors.transparent,
    child: InkWell(
      onTap: () => c.login(context),
      borderRadius: BorderRadius.circular(30),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white.withOpacity(0.1),
          border: Border.all(
            color: const Color(0xFFFFD700).withOpacity(0.5),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 36),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.login_rounded,
                color: Colors.black,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "เข้าสู่ระบบ",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: c.isLoading ? 20 : 0,
              child: c.isLoading
                  ? CircularProgressIndicator(
                      strokeWidth: 2,
                      color: const Color(0xFFFFD700),
                    )
                  : null,
            ),
          ],
        ),
      ),
    ),
  );
}