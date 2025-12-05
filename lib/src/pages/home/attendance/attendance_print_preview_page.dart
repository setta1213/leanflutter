// lib/pages/home/attendance/attendance_print_preview_page.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'attendance_print_service.dart';

class AttendancePrintPreviewPage extends StatefulWidget {
  final String startDate;
  final String endDate;
  final String empId;

  const AttendancePrintPreviewPage({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.empId, required String companyName, required String department,
  });

  @override
  State<AttendancePrintPreviewPage> createState() =>
      _AttendancePrintPreviewPageState();
}

class _AttendancePrintPreviewPageState
    extends State<AttendancePrintPreviewPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ตัวอย่างก่อนพิมพ์"),
        backgroundColor: Colors.blueAccent,
      ),
      body: PdfPreview(
        build: (format) => AttendancePrintService.buildPdf(
          startDate: widget.startDate,
          endDate: widget.endDate,
          empId: widget.empId,
        ),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        pdfFileName: "attendance.pdf",
      ),
    );
  }
}
