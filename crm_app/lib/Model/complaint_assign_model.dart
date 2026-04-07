class ComplaintAssignResponse {
  final bool status;
  final String message;
  final ComplaintAssignData data;

  ComplaintAssignResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ComplaintAssignResponse.fromJson(Map<String, dynamic> json) {
    return ComplaintAssignResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: ComplaintAssignData.fromJson(json['data'] ?? {}),
    );
  }
}


class ComplaintAssignData {
  final String complaintId;
  final String assignedBy;
  final String assignedTo;
  final int assignToAcknowledgement;

  ComplaintAssignData({
    required this.complaintId,
    required this.assignedBy,
    required this.assignedTo,
    required this.assignToAcknowledgement,
  });

  factory ComplaintAssignData.fromJson(Map<String, dynamic> json) {
    return ComplaintAssignData(
      complaintId: json['complaint_id']?.toString() ?? '',
      assignedBy: json['assigned_by']?.toString() ?? '',
      assignedTo: json['assigned_to']?.toString() ?? '',
      assignToAcknowledgement:
      int.tryParse(json['assign_to_acknowledgement']?.toString() ?? '0') ?? 0,
    );
  }
}
