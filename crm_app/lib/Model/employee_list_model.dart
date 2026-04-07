class EmployeeResponse {
  final bool status;
  final String message;
  final List<Employee> data;

  EmployeeResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? "",
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => Employee.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
      "data": data.map((e) => e.toJson()).toList(),
    };
  }
}

class Employee {
  final String userId;
  final String roleId;
  final String name;
  final String email;
  final String role;

  Employee({
    required this.userId,
    required this.roleId,
    required this.name,
    required this.email,
    required this.role,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      userId: json['user_id'] ?? "",
      roleId: json['roleId'] ?? "",
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      role: json['role'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "roleId": roleId,
      "name": name,
      "email": email,
      "role": role,
    };
  }
}
