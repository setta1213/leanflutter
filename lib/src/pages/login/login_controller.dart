import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:leanflutter/src/pages/home/home_page.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_list.dart';

class LoginController extends ChangeNotifier {
  late AnimationController animController;
  late Animation<double> fade;
  late Animation<double> slide;
  late Animation<Color?> gradient;

  bool obscure = true;
  bool isLoading = false;
  bool showSuccess = false;

  double glowValue = 0.0;
  Timer? glowTimer;
  

  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  LoginController({required TickerProvider vsync}) {
    animController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    );

    fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeInOut),
    );

    slide = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(parent: animController, curve: Curves.easeOut),
    );

    gradient = ColorTween(
      begin: const Color(0xFF1A1A1A),
      end: const Color(0xFF000000),
    ).animate(animController);

    Future.delayed(const Duration(milliseconds: 300), () {
      animController.forward();
    });

    _startGlowTimer();
  }

  double get animationValue => animController.value;

  // Glow Animation
  void _startGlowTimer() {
    glowTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      glowValue = 1.0;
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 600), () {
        glowValue = 0.0;
        notifyListeners();
      });
    });
  }

  // Shake Animation (failed login)
  void shake() {
    // You can expand this later
  }

  // Login API
  Future<void> login(BuildContext context) async {
    final username = userCtrl.text.trim();
    final password = passCtrl.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _snack(context, "กรุณากรอกข้อมูลให้ครบ", false);
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      var url = Uri.parse(ApiEndpoints.API_LOGIN);

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (data["status"] == "success") {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data["token"]);
        await prefs.setString("user", jsonEncode(data["user"]));

        showSuccess = true;
        notifyListeners();

        Future.delayed(const Duration(milliseconds: 1200), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        });

      } else {
        shake();
        _snack(context, data["message"], false);
      }

    } catch (e) {
      shake();
      _snack(context, "เกิดข้อผิดพลาด: $e", false);
    }

    isLoading = false;
    notifyListeners();
  }

  void _snack(BuildContext context, String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color.fromARGB(221, 232, 224, 224),
      ),
    );
  }
  // 📝 ฟังก์ชันหลักที่รับค่า success (bool) เพื่อกำหนดรูปแบบ
// 📌 ปรับปรุงฟังก์ชันเดิมของคุณ
// ต้องติดตั้ง rflutter_alert ก่อน:
// flutter pub add rflutter_alert



// void _snack(BuildContext context, String s, bool bool) {
//   Alert(
//     context: context,
//     type: AlertType.success, // <-- สไตล์ Success
//     title: s, // <-- ชื่อเรื่อง
//     desc: "ข้อมูลการตั้งค่าของคุณถูกจัดเก็บเรียบร้อยแล้ว", // <-- ข้อความหลัก
    
//     // ปุ่ม
//     buttons: [
//       DialogButton(
//         onPressed: () => Navigator.pop(context), // ปิด Dialog
//         color: Colors.green,
//         child: const Text(
//           "ตกลง",
//           style: TextStyle(color: Colors.white, fontSize: 20),
//         ), // สีปุ่ม
//       )
//     ],
//   ).show();
// }



  @override
  void dispose() {
    userCtrl.dispose();
    passCtrl.dispose();
    glowTimer?.cancel();
    animController.dispose();
    super.dispose();
  }
}
