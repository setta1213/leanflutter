import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/employee.dart';
import 'models/attendance_log.dart';

class ApiService {
  static const String base = "https://agenda.bkkthon.ac.th/hr/report";

  // โหลดพนักงานทั้งหมด
  static Future<List<Employee>> fetchEmployees() async {
    final response = await http.get(Uri.parse("$base/get_employees.php"));
    final data = json.decode(response.body);
    return List<Employee>.from(data.map((e) => Employee.fromJson(e)));
  }

  // โหลด Log ตามเงื่อนไข
  static Future<List<AttendanceLog>> fetchLogs({
    required String start,
    required String end,
    required String empId,
  }) async {
    final url = "$base/get_logs.php?start_date=$start&end_date=$end&emp_id=$empId";
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    return List<AttendanceLog>.from(
      data.map((e) => AttendanceLog.fromJson(e)),
    );
  }
}
