import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:leanflutter/src/services/api_list.dart'; 

class DailyAttendance {
  final String empId;
  final DateTime date;
  final DateTime checkIn;
  final DateTime? checkOut;
  final bool isLate;
  final bool isEarlyLeave;

  DailyAttendance({
    required this.empId,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.isLate,
    required this.isEarlyLeave,
  });
}

// --- ⭐ Attendance Screen ---
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<DailyAttendance> _attendanceList = [];
  Map<String, String> empNames = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // วันที่ที่เลือก
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      await loadEmployees();
      await fetchData();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'ไม่สามารถโหลดข้อมูลได้';
        _isLoading = false;
      });
    }
  }

  Future<void> loadEmployees() async {
    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.API_ATTENDANCE_EMPLOYEE),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        Map<String, String> tempNames = {};

        for (var emp in jsonData) {
          final id = emp['emp_id'].toString();
          final first = emp['first_name']?.toString().trim() ?? '';
          final last = emp['last_name']?.toString().trim() ?? '';
          tempNames[id] = "$first $last".trim();
        }

        if (mounted) {
          setState(() => empNames = tempNames);
        }
      }
    } catch (e) {
      print("ERROR LOAD EMPLOYEE: $e");
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.API_ATTENDANCE));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<DailyAttendance> list = [];

        for (var item in jsonData) {
          final empId = item['emp_id'].toString();
          final dateStr = item['date'];
          final inStr = item['check_in'];
          final outStr = item['check_out'];

          final date = DateTime.parse(dateStr);
          final checkIn = DateTime.parse("$dateStr $inStr");

          DateTime? checkOut;
          if (outStr != null && outStr.toString().isNotEmpty) {
            checkOut = DateTime.parse("$dateStr $outStr");
          }

          bool isLate = checkIn.hour > 8 || (checkIn.hour == 8 && checkIn.minute > 0);
          bool isEarly = checkOut != null && (checkOut.hour < 17);

          list.add(
            DailyAttendance(
              empId: empId,
              date: date,
              checkIn: checkIn,
              checkOut: checkOut,
              isLate: isLate,
              isEarlyLeave: isEarly,
            ),
          );
        }

        if (mounted) {
          setState(() {
            _attendanceList = list;
            _isLoading = false;
            _hasError = false;
          });
        }
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      print("ERROR: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'เกิดข้อผิดพลาดในการโหลดข้อมูล';
        });
      }
    }
  }

  // Filter ข้อมูลตามวันที่เลือก
  List<DailyAttendance> get filteredList {
    final selectedString = DateFormat("yyyy-MM-dd").format(_selectedDate);
    return _attendanceList.where((item) {
      final itemString = DateFormat("yyyy-MM-dd").format(item.date);
      return itemString == selectedString;
    }).toList();
  }

  // เลือกวันที่
  Future<void> _pickDate() async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (newDate != null) {
      setState(() {
        _selectedDate = newDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "บันทึกเข้า-ออกงาน",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.grey, size: 48),
            const SizedBox(height: 16),
            const Text(
              'ไม่สามารถโหลดข้อมูลได้',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadData,
              child: const Text('ลองใหม่'),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.black54,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: Colors.black54,
      child: Column(
        children: [
          // ส่วนเลือกวันที่
          _buildDateHeader(),
          
          const Divider(height: 1, color: Colors.grey),
          
          // รายการข้อมูล
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey, size: 48),
                        const SizedBox(height: 16),
                        const Text(
                          'ไม่มีข้อมูลในวันที่เลือก',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      return _buildAttendanceItem(filteredList[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader() {
    final dateText = DateFormat('dd MMM yyyy', 'th').format(_selectedDate);
    
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.black54, size: 20),
              const SizedBox(width: 8),
              Text(
                dateText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'เปลี่ยนวันที่',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceItem(DailyAttendance att) {
    final fullName = empNames[att.empId] ?? att.empId;
    final inTime = DateFormat('HH:mm').format(att.checkIn);
    final outTime = att.checkOut != null
        ? DateFormat('HH:mm').format(att.checkOut!)
        : "-";

    // กำหนดสีและข้อความสถานะ
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (att.isLate) {
      statusColor = const Color(0xFFDC2626); // สีแดง
      statusText = "มาสาย";
      statusIcon = Icons.access_time_filled;
    } else if (att.isEarlyLeave) {
      statusColor = const Color(0xFFF59E0B); // สีส้ม
      statusText = "กลับก่อน";
      statusIcon = Icons.exit_to_app;
    } else {
      statusColor = const Color(0xFF10B981); // สีเขียว
      statusText = "ปกติ";
      statusIcon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ชื่อพนักงาน
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 12),
          
          // เวลาเข้า-ออก
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeInfo(
                label: 'เข้า',
                time: inTime,
                icon: Icons.login,
                color: Colors.blue[700]!,
              ),
              
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              
              _buildTimeInfo(
                label: 'ออก',
                time: outTime,
                icon: Icons.logout,
                color: Colors.purple[700]!,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // สถานะ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, color: statusColor, size: 16),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeInfo({
    required String label,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}