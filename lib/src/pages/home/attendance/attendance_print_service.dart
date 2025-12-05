// lib/pages/home/attendance/attendance_print_service.dart
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class AttendancePrintService {
  static const baseUrl = "https://agenda.bkkthon.ac.th/hr/report/";

  static Future<Uint8List> buildPdf({
    required String startDate,
    required String endDate,
    required String empId, // “” = ทั้งหมด
  }) async {
    final pdf = pw.Document();

    final font = pw.Font.ttf(
      await rootBundle.load("assets/fonts/THSarabun.ttf"),
    );
    final fontSymbol = pw.Font.ttf(
      await rootBundle.load("assets/fonts/Dejavusans.ttf"),
    );

    // โหลดรายชื่อพนักงาน
    final empRes = await http.get(Uri.parse("${baseUrl}get_employees.php"));
    final employeeList = List<Map<String, dynamic>>.from(
      jsonDecode(empRes.body),
    );

    // กรองเฉพาะคน (ถ้าเลือก)
    final targetEmployees = empId.isEmpty
        ? employeeList
        : employeeList.where((e) => e["emp_id"].toString() == empId).toList();

    for (var emp in targetEmployees) {
      final id = emp["emp_id"].toString();
      final name = "${emp["first_name"]} ${emp["last_name"]}";

      final logUrl =
          "${baseUrl}get_logs.php?start_date=$startDate&end_date=$endDate&emp_id=$id";
      final logRes = await http.get(Uri.parse(logUrl));
      final logs = List<Map<String, dynamic>>.from(jsonDecode(logRes.body));

      // คำนวณวันขาดงาน
      final workDates = logs.map((e) => e["work_date"]).toSet();
      final missing = <String>[];

      DateTime cursor = DateTime.parse(startDate);
      final endD = DateTime.parse(endDate);

      while (!cursor.isAfter(endD)) {
        final d = cursor.toIso8601String().split("T").first;
        if (!workDates.contains(d)) missing.add(d);
        cursor = cursor.add(const Duration(days: 1));
      }

      // เพิ่มหน้า PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (context) => [
            pw.Text(
              "รายงานเข้า-ออกงานพนักงาน",
              style: pw.TextStyle(font: font, fontSize: 22),
            ),

            pw.SizedBox(height: 10),

            pw.Text(
              "ชื่อพนักงาน: $name",
              style: pw.TextStyle(font: font, fontSize: 16),
            ),

            pw.Text(
              "ช่วงวันที่: $startDate ถึง $endDate",
              style: pw.TextStyle(font: font, fontSize: 16),
            ),

            pw.SizedBox(height: 15),

            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: "✔ ",
                          style: pw.TextStyle(
                            font: fontSymbol,
                            fontSize: 16,
                            color: PdfColors.green,
                          ),
                        ),
                        pw.TextSpan(
                          text: "มาทำงาน: ${workDates.length} วัน",
                          style: pw.TextStyle(
                            font: font, // ฟอนต์ไทย
                            fontSize: 16,
                            color: PdfColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.RichText(
                    text: pw.TextSpan(
                      children: [
                        pw.TextSpan(
                          text: "X ",
                          style: pw.TextStyle(
                            font: fontSymbol,
                            fontSize: 16,
                            color: PdfColors.red,
                          ),
                        ),
                        pw.TextSpan(
                          text:
                              "ขาดงาน: ${missing.isEmpty ? "-" : missing.join(", ")}",
                          style: pw.TextStyle(
                            font: font, // ฟอนต์ไทย
                            fontSize: 16,
                            color: PdfColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 20),

            pw.Table.fromTextArray(
              headerStyle: pw.TextStyle(
                font: font,
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: pw.TextStyle(font: font, fontSize: 8),
              headers: ["วันที่", "เข้า", "ออก", "สถานะ"],
              data: logs
                  .map(
                    (e) => [
                      e["work_date"],
                      e["check_in_time"] ?? "-",
                      e["check_out_time"] ?? "-",
                      convertStatus(e["status"]),
                    ],
                  )
                  .toList(),
              border: pw.TableBorder.all(color: PdfColors.grey),
            ),
          ],
        ),
      );
    }

    return pdf.save();
  }

  static String convertStatus(String? s) {
    switch (s) {
      case "LATE":
        return "สาย";
      case "NORMAL":
        return "ปกติ";
      case "NO_OUT":
        return "ขาดลงเวลาออก";
      case "NO_IN":
        return "ขาดลงเวลาเข้า";
      default:
        return s ?? "-";
    }
  }
}
