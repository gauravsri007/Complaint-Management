
class ComplaintCountResponse {
  final bool status;
  final int assignedComplaints;
  final int unassignedComplaints;
  final int resolvedComplaints;

  ComplaintCountResponse({
    required this.status,
    required this.assignedComplaints,
    required this.unassignedComplaints,
    required this.resolvedComplaints,
  });

  factory ComplaintCountResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintCountResponse(
      status: json['status'] ?? false,
      assignedComplaints:
      int.tryParse(json['assigned_complaints'].toString()) ?? 0,
      unassignedComplaints:
      int.tryParse(json['unassigned_complaints']?.toString() ?? '0') ?? 0,
      resolvedComplaints:
      int.tryParse(json['resolved_complaints']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "assigned_complaints": assignedComplaints,
      "unassigned_complaints": unassignedComplaints,
      "resolved_complaints": resolvedComplaints,
    };
  }
}