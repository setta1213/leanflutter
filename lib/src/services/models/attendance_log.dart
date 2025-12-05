class AttendanceLog {
  final String empId;
  final String fullName;
  final String workDate;
  final String checkIn;
  final String checkOut;
  final String status;

  AttendanceLog({
    required this.empId,
    required this.fullName,
    required this.workDate,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });

  factory AttendanceLog.fromJson(Map<String, dynamic> json) {
    return AttendanceLog(
      empId: json['controller_id'].toString(),
      fullName: json['full_name']?.toString() ?? '',

      workDate: json['work_date'].toString(),
      checkIn: json['check_in_time']?.toString() ?? "-",
      checkOut: json['check_out_time']?.toString() ?? "-",
      status: json['status'].toString(),
    );
  }
}
