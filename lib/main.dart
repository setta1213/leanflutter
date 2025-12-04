import 'package:flutter/material.dart';
// 1. เพิ่ม Import นี้
import 'package:intl/date_symbol_data_local.dart'; 
import 'src/app.dart';

// 2. เปลี่ยน void main() เป็น async
void main() async {
  // 3. เพิ่มบรรทัดนี้ เพื่อโหลดข้อมูลภาษาไทย (th) ก่อนเริ่มแอป
  // ต้องมีบรรทัดนี้ ไม่งั้นจะเจอ error LocaleDataException
  await initializeDateFormatting('th', null);

  runApp(const App());
}