// lib/pages/home/attendance/attendance_print_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'attendance_print_preview_page.dart';

class AttendancePrintPage extends StatefulWidget {
  const AttendancePrintPage({super.key});

  @override
  State<AttendancePrintPage> createState() => _AttendancePrintPageState();
}

class _AttendancePrintPageState extends State<AttendancePrintPage> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedEmpId = "";
  bool _isLoading = false;
  String _errorMessage = '';

  List<Map<String, dynamic>> employees = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final res = await http.get(
        Uri.parse("https://agenda.bkkthon.ac.th/hr/report/get_employees.php"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (res.statusCode == 200) {
        employees = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        _errorMessage = '';
      } else {
        setState(() {
          _errorMessage = 'ไม่สามารถโหลดข้อมูลพนักงานได้ (รหัส: ${res.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate 
        ? startDate ?? DateTime.now().subtract(const Duration(days: 30))
        : endDate ?? DateTime.now();
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E40AF), // สีน้ำเงินเข้ม
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
           
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
          // ถ้าเลือกวันที่เริ่มต้นหลังจากวันที่สิ้นสุด ให้ปรับวันที่สิ้นสุด
          if (endDate != null && startDate!.isAfter(endDate!)) {
            endDate = startDate;
          }
        } else {
          endDate = picked;
          // ถ้าเลือกวันที่สิ้นสุดก่อนวันที่เริ่มต้น ให้ปรับวันที่เริ่มต้น
          if (startDate != null && endDate!.isBefore(startDate!)) {
            startDate = endDate;
          }
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'ไม่ได้เลือก';
    return DateFormat('dd MMMM yyyy', 'th').format(date);
  }

  void _navigateToPreview() {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณาเลือกวันที่เริ่มต้นและสิ้นสุด'),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AttendancePrintPreviewPage(
          startDate: startDate!.toIso8601String().split("T").first,
          endDate: endDate!.toIso8601String().split("T").first,
          empId: selectedEmpId!,
          companyName: 'บริษัทของคุณ',
          department: 'ทั้งหมด',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFormValid = startDate != null && endDate != null;
    final bool isDateRangeValid = startDate != null && endDate != null && !endDate!.isBefore(startDate!);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'พิมพ์รายงานเข้างาน',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black54),
            onPressed: _loadEmployees,
            tooltip: 'รีเฟรชข้อมูลพนักงาน',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFF1E40AF),
                    strokeWidth: 2,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'กำลังโหลดข้อมูลพนักงาน...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ส่วนหัว
                  _buildHeaderSection(),
                  
                  const SizedBox(height: 32),
                  
                  // ส่วนเลือกช่วงวันที่
                  _buildDateRangeSection(),
                  
                  const SizedBox(height: 32),
                  
                  // ส่วนเลือกพนักงาน
                  _buildEmployeeSelectionSection(),
                  
                  if (_errorMessage.isNotEmpty) 
                    _buildErrorMessage(),
                  
                  const SizedBox(height: 40),
                  
                  // ปุ่มดูตัวอย่าง
                  _buildPreviewButton(isFormValid, isDateRangeValid),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.description_outlined,
          size: 48,
          color: Colors.blue[700],
        ),
        const SizedBox(height: 12),
        const Text(
          'สร้างรายงานการเข้างาน',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'เลือกช่วงวันที่และพนักงานที่ต้องการสร้างรายงาน PDF',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'ช่วงวันที่',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(221, 233, 229, 229),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // วันที่เริ่มต้น
            _buildDateField(
              label: 'วันที่เริ่มต้น',
              date: startDate,
              isStart: true,
            ),
            
            const SizedBox(height: 20),
            
            // วันที่สิ้นสุด
            _buildDateField(
              label: 'วันที่สิ้นสุด',
              date: endDate,
              isStart: false,
            ),
            
            if (startDate != null && endDate != null && endDate!.isBefore(startDate!))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '⚠️ วันที่สิ้นสุดต้องไม่น้อยกว่าวันที่เริ่มต้น',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required bool isStart,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, isStart),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: date == null ? Colors.grey[400] : Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 15,
                        color: date == null ? Colors.grey[500] : Colors.black87,
                        fontWeight: date == null ? FontWeight.normal : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Text(
                    'เลือกวันที่',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmployeeSelectionSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people_alt_outlined, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                const Text(
                  'เลือกพนักงาน',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(221, 247, 241, 241),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'เลือกพนักงานที่ต้องการสร้างรายงาน (หรือเลือกทั้งหมด)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedEmpId,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
                  iconSize: 24,
                  elevation: 4,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedEmpId = newValue ?? "";
                    });
                  },
                  items: [
                    _buildDropdownItem("", "ทั้งหมด", Icons.groups),
                    ...employees.map((e) {
                      final id = e["emp_id"].toString();
                      final name = "${e["first_name"]} ${e["last_name"]}".trim();
                      return _buildDropdownItem(
                        id,
                        "$name (รหัส: $id)",
                        Icons.person_outline,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'เลือก ${selectedEmpId!.isEmpty ? 'ทั้งหมด' : 'เฉพาะพนักงาน'} (${selectedEmpId!.isEmpty ? employees.length : '1'} คน)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String value, String text, IconData icon) {
    return DropdownMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            color: value.isEmpty ? Colors.green[700] : Colors.blue[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: value.isEmpty ? Colors.green[700] : Colors.black87,
                fontWeight: value.isEmpty ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.red[600], size: 18),
            onPressed: () => setState(() => _errorMessage = ''),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewButton(bool isFormValid, bool isDateRangeValid) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          ElevatedButton(
            onPressed: isFormValid && isDateRangeValid ? _navigateToPreview : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E40AF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: const Color(0xFF1E40AF).withOpacity(0.3),
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[500],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.picture_as_pdf_outlined, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'ดูตัวอย่างรายงาน',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (!isDateRangeValid && startDate != null && endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'กรุณาเลือกช่วงวันที่ให้ถูกต้อง',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 13,
                ),
              ),
            ),
          if (!isFormValid)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'กรุณาเลือกวันที่เริ่มต้นและสิ้นสุด',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }
}