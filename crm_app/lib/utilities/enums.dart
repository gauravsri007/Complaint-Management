
enum ComplaintStatus {
  open("Open"),
  // acknowledged("Acknowledged"),
  resolved("Resolved"),
  break_down("Break Down"),
  running_with_issue("Running With Issue");

  final String value;
  const ComplaintStatus(this.value);

  /// Convert string → enum
  static ComplaintStatus fromString(String value) {
    return ComplaintStatus.values.firstWhere(
          (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => ComplaintStatus.open,
    );
  }

  /// Convert enum → string
  String get string => value;
}

// extension StatusText on ComplaintStatus {
//   String get label {
//     switch (this) {
//       case ComplaintStatus.open:
//         return "Open";
//       case ComplaintStatus.break_down:
//         return "Break down";
//       case ComplaintStatus.acknowledged:
//         return "Acknowledged";
//       case ComplaintStatus.resolved:
//         return "Resolved";
//       case ComplaintStatus.running_with_issue:
//         return "Running with issue";
//     }
//   }
// }

enum UserRole {
  systemAdmin(1, 'System Admin'),
  manager(9, 'Manager'),
  supervisor(14, 'Supervisor'),
  serviceEngineer(8, 'Service Engineer');

  final int id;
  final String label;

  const UserRole(this.id, this.label);

  /// Convert role id → enum
  static UserRole? fromId(int id) {
    for (final role in UserRole.values) {
      if (role.id == id) return role;
    }
    return null;
  }

  /// Convert string id → enum (API safety)
  static UserRole? fromIdString(String? id) {
    if (id == null) return null;
    final parsed = int.tryParse(id);
    if (parsed == null) return null;
    return fromId(parsed);
  }
}
