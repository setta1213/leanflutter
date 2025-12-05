class Employee {
  final String empId;
  final String firstName;
  final String lastName;

  Employee({
    required this.empId,
    required this.firstName,
    required this.lastName,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      empId: json['emp_id'].toString(),
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  String get fullName => "$firstName $lastName";
}
